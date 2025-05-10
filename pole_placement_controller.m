function K = pole_placement_controller(A, B, alpha, beta)
    n = size(A,1);
    m = size(B,2);
    cvx_begin sdp
        variable X(n,n) symmetric
        variable L(m,n)
    
        X >= eye(n);
        [A B] * [X; L] + [X L'] * [A'; B'] + 2*alpha*X <= -eye(n);
        [A B] * [X; L] + [X L'] * [A'; B'] + 2*beta*X >= eye(n);
        % learned to do the nonstrict inequality from
        % Boyd (and the error message)
        % https://stanford.edu/class/ee363/notes/lmi-cvx.pdf
    cvx_end
    
    K = L*X^-1;
end