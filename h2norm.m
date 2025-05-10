function [H2_norm_obs, H2_norm_ctrl, H2_norm_LMI_obs, H2_norm_LMI_ctrl]= h2norm(A,B,C)
    n = size(A,1);
    m = size(B,2);
    p = size(C,1);

    % Question 3: 1.
    W_o = lyap(A', C'*C);
    H2_norm_obs = sqrt(trace(B'*W_o*B));
    
    % Question 3: 2.
    W_c = lyap(A, B*B');
    H2_norm_ctrl = sqrt(trace(C*W_c*C'));
    
    % Question 3: 3.
    tol = 0;
    cvx_begin sdp
        variable Y(n,n) symmetric
        variable g
        minimize( g )
        subject to
            Y >= tol*eye(n);
            trace(B'*Y*B) <= g - tol;
            A'*Y + Y*A + C'*C <= -tol*eye(n);
    cvx_end
    
    H2_norm_LMI_obs = sqrt(g);
    
    % Question 3: 4.
    cvx_begin sdp
        variable X(n,n) symmetric
        variable g
        minimize( g )
        subject to
            X >= tol*eye(n);
            trace(C*X*C') <= g-tol;
            A*X + X*A' + B*B' <= -tol*eye(n);
    cvx_end
    
    H2_norm_LMI_ctrl = sqrt(g);
end