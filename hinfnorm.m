function g = hinfnorm(A, B, C, D)
    n = size(A,1);
    m = size(B,2);
    p = size(C,1);
    tol = 1e-6;
    cvx_begin sdp
        variable X(n,n) symmetric
        variable g
        subject to
            % g <= 1e9;
            X >= tol * eye(n);
            LMI = [A'*X + X*A,       X*B,        C';
                   B'*X,            -g*eye(5), D';
                   C,               D,          -g*eye(5)];
            LMI <= -tol * eye(size(LMI)); 
    cvx_end

end