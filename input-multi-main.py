import os
os.environ["OMP_NUM_THREADS"] = "4"
import subprocess
import sys

# Folder containing matrix images
image_folder = "matrix_images"

# Get a list of all image files
image_files = [f for f in os.listdir(image_folder) if f.endswith(".png")]

# Get the correct Python executable path
python_executable = sys.executable  # This ensures we use the Python from the current environment

# Process each image using the updated script
for image in image_files:
    image_path = os.path.join(image_folder, image)
    print(f"Processing {image_path}...")
    subprocess.run([python_executable, "transcribe.py", image_path])