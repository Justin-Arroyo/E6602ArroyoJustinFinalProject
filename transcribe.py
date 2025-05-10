import os
os.environ["OMP_NUM_THREADS"] = "1"
import cv2
import numpy as np
import sys
import re
import pandas as pd
from sklearn.cluster import KMeans

output_folder = r"C:\Users\Justin Arroyo\Documents\for_school_project\xlsx"
template_dir = "templates/"  # Folder with templates for digits, decimal points, and minus signs

# Character-specific thresholds - lower threshold for problematic characters
char_thresholds = {
    "2": 0.45,  # Lower threshold for "2" to catch more potential matches
    #".": 0.65,  # Higher threshold for "." to avoid false positives
    "-": 0.65,  # Higher threshold for "-" to avoid false positives
    #"+": 0.6,
    "default": 0.6  # Default threshold for other characters
}

# Check for filename argument
if len(sys.argv) != 2:
    print("Usage: python process_matrix.py <image_filename>")
    exit()

image_filename = sys.argv[1]  # Get filename from command-line argument

# Load the row image
row_img = cv2.imread(image_filename, cv2.IMREAD_GRAYSCALE)
if row_img is None:
    print(f"Error: Could not load image {image_filename}")
    exit()

# Enhanced preprocessing for input image
# Apply adaptive thresholding to better handle faded characters
adaptive_thresh = cv2.adaptiveThreshold(row_img, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
                                       cv2.THRESH_BINARY_INV, 11, 2)

# Additional morphological operations to enhance character shapes
kernel = np.ones((2, 2), np.uint8)
morph_img = cv2.morphologyEx(adaptive_thresh, cv2.MORPH_CLOSE, kernel)

# Extract the number of rows from the filename (assuming format like 'Basic-Set_1_A1_16rows.png')
n_row_match = re.search(r"(\d+)rows", image_filename)
if n_row_match:
    n_rows = int(n_row_match.group(1))
else:
    print(f"Error: Could not determine row count from filename {image_filename}")
    exit()
    
# Create a copy for visualization
vis_img = cv2.cvtColor(row_img, cv2.COLOR_GRAY2BGR)

# Load character templates
templates = {}
for filename in os.listdir(template_dir):
    if filename.endswith(".png"):
        char = filename.split(".")[0]  # Character name from filename (e.g., "1", "2", "-", ".")
        if char == "dot":
            char = "."
        elif char == "2_2":
            char = "2"
        
        template = cv2.imread(os.path.join(template_dir, filename), cv2.IMREAD_GRAYSCALE)
        if template is None:
            print(f"Error: Could not load template {filename}")
            continue
            
        # Enhanced preprocessing for templates
        _, template = cv2.threshold(template, 128, 255, cv2.THRESH_BINARY_INV)
        # Apply morphological closing to enhance template shapes
        template = cv2.morphologyEx(template, cv2.MORPH_CLOSE, kernel)
        templates[char] = template

# Store all potential detections with their confidence scores
all_potential_detections = []

# Match each template
for char, template in templates.items():
    w, h = template.shape[::-1]
    
    # Use character-specific threshold
    threshold = char_thresholds.get(char, char_thresholds["default"])
    
    # Try matching against both the binary and morphologically enhanced images
    # This gives us more chances to catch faded characters
    for input_img in [adaptive_thresh, morph_img]:
        res = cv2.matchTemplate(input_img, template, cv2.TM_CCOEFF_NORMED)
        loc = np.where(res >= threshold)
        
        # Get all matches for this template
        for pt in zip(*loc[::-1]):  # Convert to (x, y) format
            # Store (x, y, width, height, character, confidence_score)
            all_potential_detections.append((pt[0], pt[1], w, h, char, res[pt[1], pt[0]]))

# Sort all detections by confidence score (highest first)
all_potential_detections.sort(key=lambda x: x[5], reverse=True)

# Apply cross-template non-maximum suppression
final_detections = []
while all_potential_detections:
    best = all_potential_detections.pop(0)
    final_detections.append(best)
    
    # Remove all overlapping detections (regardless of character)
    non_overlapping = []
    for detection in all_potential_detections:
        # Calculate overlap
        x1, y1, w1, h1 = best[0], best[1], best[2], best[3]
        x2, y2, w2, h2 = detection[0], detection[1], detection[2], detection[3]
        
        # Calculate intersection area
        x_overlap = max(0, min(x1 + w1, x2 + w2) - max(x1, x2))
        y_overlap = max(0, min(y1 + h1, y2 + h2) - max(y1, y2))
        intersection_area = x_overlap * y_overlap
        
        # Calculate smaller rectangle area for IoU
        min_area = min(w1 * h1, w2 * h2)
        overlap_ratio = intersection_area / min_area
        
        # If overlap is small enough, keep the detection
        if overlap_ratio < 0.25:  # Adjust threshold as needed
            non_overlapping.append(detection)
    
    all_potential_detections = non_overlapping

# Group detections by row
# First, analyze y-coordinates to detect distinct rows
y_coords = [det[1] for det in final_detections]

# Convert to numpy array for clustering
y_coords_array = np.array(y_coords).reshape(-1, 1)

# Apply K-means clustering
kmeans = KMeans(n_clusters=n_rows, random_state=0).fit(y_coords_array)

# Get cluster centers (row y-positions) and sort them by vertical position (top to bottom)
row_centers = kmeans.cluster_centers_.flatten()
sorted_center_indices = np.argsort(row_centers)

# Get row assignments for each detection
row_assignments = kmeans.labels_

# Group detections by row
rows = [[] for _ in range(n_rows)]
for i, det in enumerate(final_detections):
    row_idx = row_assignments[i]
    rows[row_idx].append(det)

# Create a mapping from original row indices to sorted row indices
row_mapping = {orig_idx: sorted_idx for sorted_idx, orig_idx in enumerate(sorted_center_indices)}

# Create sorted rows
sorted_rows = [None] * n_rows
for orig_idx, row in enumerate(rows):
    sorted_idx = row_mapping[orig_idx]
    sorted_rows[sorted_idx] = row

# Sort each row by x-coordinate
for i in range(n_rows):
    sorted_rows[i].sort(key=lambda x: x[0])

# NEW: Post-processing function to fix common errors
def post_process_row(row_chars):
    # Define pattern for valid position of "." and "-"
    processed_chars = row_chars.copy()
    
    for i, (char, _) in enumerate(processed_chars):
        # Rule 1: If "." or "-" is surrounded by digits, it's likely correct
        if char in [".", "-"]:
            # Check if this is a valid position for these characters
            has_digit_before = (i > 0 and processed_chars[i-1][0].isdigit())
            has_digit_after = (i < len(processed_chars)-1 and processed_chars[i+1][0].isdigit())
            
            # If not in a valid position (for a typical numeric matrix), consider it might be a "2"
            if not (has_digit_before or has_digit_after):
                processed_chars[i] = ("2", processed_chars[i][1])  # Replace with "2" but keep confidence
    
    return processed_chars

# Process and format rows
transcribed_rows = []
formatted_rows = []

for i, row in enumerate(sorted_rows):
    # Comment out post-processing for now
    # processed_row = post_process_row([(det[4], det[5]) for det in row])
    # row_text = ''.join([char for char, _ in processed_row])
    
    # Use direct extraction instead
    row_text = ''.join([det[4] for det in row])
    transcribed_rows.append(row_text)
    
    # Function to format a row with commas
    def format_row_with_commas(row_text):
        formatted_row = ""
        digit_count = 0
        dot_count = 0
        i = 0

        while i < len(row_text):
            char = row_text[i]
            formatted_row += char

            if char == ".":
                dot_count += 1
            if char.isdigit():  # Count digits
                digit_count += 1
            
            # If we've reached 4 digits and the next character isn't 'E', insert a comma
            if dot_count == 1 and digit_count == 1 and char == "0":
                formatted_row += ","
                digit_count = 0
                dot_count = 0
            elif char == "E":  # Handle scientific notation
                # Move ahead 3 more places (E and the exponent sign/digits)
                if i + 3 < len(row_text):
                    formatted_row += row_text[i + 1] + row_text[i + 2] + row_text[i + 3]
                    i += 3  # Skip those characters
                formatted_row += ","
                digit_count = 0 
                dot_count = 0
            elif digit_count == 4 and dot_count == 1:
                next_char = row_text[i + 1] if i + 1 < len(row_text) else ""
                if next_char != "E":
                    formatted_row += ","
                    digit_count = 0
                    dot_count = 0

            i += 1  # Move to the next character
        
        # Remove trailing comma if present
        if formatted_row.endswith(','):
            formatted_row = formatted_row[:-1]
            
        return formatted_row
    
    # Apply formatting
    formatted_row = format_row_with_commas(row_text)
    formatted_rows.append(formatted_row)

# # Save visualization image with detections
# for det in final_detections:
#     x, y, w, h, char, _ = det
#     color = (0, 255, 0) if char != "2" else (0, 0, 255)  # Green for normal, red for "2"
#     cv2.rectangle(vis_img, (x, y), (x + w, y + h), color, 1)
#     cv2.putText(vis_img, char, (x, y-5), cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 1)

# vis_output_path = f"{os.path.splitext(image_filename)[0]}_detection.png"
# cv2.imwrite(vis_output_path, vis_img)

image_base_name = os.path.basename(image_filename)
output_formatted_xlsx = f"{os.path.splitext(image_base_name)[0]}_formatted.xlsx"
output_path = os.path.join(output_folder, output_formatted_xlsx)

# Convert strings into lists
data = [row.split(',') for row in formatted_rows]

# Create a DataFrame
df = pd.DataFrame(data)

# Write to an Excel file
df.to_excel(output_path, index=False, header=False)

print("Excel file has been created successfully.")
# print(f"Detection visualization saved to {vis_output_path}")