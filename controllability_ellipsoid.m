function controllability_ellipsoid(A,B)
    Wc = lyap(A, B*B');
    [V, D] = eig(Wc);
    
    eigenvalues = diag(D); 
    [eigenvalues_sorted, sort_idx] = sort(eigenvalues, 'descend');
    V_sorted = V(:, sort_idx);
    
    % asked chatgpt for a nice display
    disp('Eigenvalues (sorted):');
    disp(eigenvalues_sorted);

    disp('Corresponding eigenvectors:');
    disp(V_sorted);

    for i = 1:length(eigenvalues_sorted)
        fprintf('\nMode %d (eigenvalue = %.4e):\n', i, eigenvalues_sorted(i));
        [~, dominant_state] = max(abs(V_sorted(:, i)));
        fprintf('  Dominant state: x_%d\n', dominant_state);
    end
    
    % not sure if this is valid but I wanted to see all the states sorted
    % from most to least controllable.
    state_scores = zeros(size(V,1),1);
    
    % sum up eigenvalue * (eigenvector component)^2 
    for i = 1:length(eigenvalues)
        state_scores = state_scores + eigenvalues(i) * (V(:,i).^2);
    end
    
    % sort from most to least controllable
    [state_scores_sorted, idx_sorted] = sort(state_scores, 'descend');
    
    % again asked chatgpt to make a nice results display
    disp('States sorted by controllability (based on eigenvalues and eigenvectors):');
    for i = 1:length(state_scores_sorted)
        fprintf('State x_%d: %.4e\n', idx_sorted(i), state_scores_sorted(i));
    end
end