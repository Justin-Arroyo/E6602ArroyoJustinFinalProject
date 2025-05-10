function observability_ellipsoid(A, C)
    Wo = lyap(A', C'*C);
    [V, D] = eig(Wo);
    
    eigenvalues = diag(D); 
    [eigenvalues_sorted, sort_idx] = sort(eigenvalues, 'descend');
    V_sorted = V(:, sort_idx);
    
    % % asked chatgpt for a nice display
    % disp('Eigenvalues (sorted):');
    % disp(eigenvalues_sorted);
    % 
    % disp('Corresponding eigenvectors:');
    % disp(V_sorted);
    % 
    % for i = 1:length(eigenvalues_sorted)
    %     fprintf('\nMode %d (eigenvalue = %.4e):\n', i, eigenvalues_sorted(i));
    %     [~, dominant_state] = max(abs(V_sorted(:, i)));
    %     fprintf('  Dominant state: x_%d\n', dominant_state);
    % end
    
    % see controllability_ellipsoid() for comments
    state_scores = zeros(size(V,1),1);
    
    for i = 1:length(eigenvalues)
        state_scores = state_scores + eigenvalues(i) * (V(:,i).^2);
    end
    
    [state_scores_sorted, idx_sorted] = sort(state_scores, 'descend');
    
    disp('States sorted by observability (based on eigenvalues and eigenvectors):');
    for i = 1:length(state_scores_sorted)
        fprintf('State x_%d: %.4e\n', idx_sorted(i), state_scores_sorted(i));
    end
end