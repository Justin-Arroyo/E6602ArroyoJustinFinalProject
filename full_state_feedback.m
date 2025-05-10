function K = full_state_feedback(A, B)
    n = size(A,1);
    m = size(B,2);
    cvx_begin sdp
        variable X(n,n) symmetric
        variable L(m,n)
    
        X >= eye(n);
        [A B] * [X; L] + [X L'] * [A'; B'] <= -eye(n);
    cvx_end

    K = L*X^-1;
end