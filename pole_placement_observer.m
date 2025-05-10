function L = pole_placement_observer(A, C, alpha, beta)
    n = size(A,1);
    p = size(C,1);
    cvx_begin sdp
        variable P(n,n) symmetric
        variable Y(p,n)
        P >= eye(n);
        A'*P + P*A + C'*Y + Y'*C + 2*alpha*P <= -eye(n);
        A'*P + P*A + C'*Y + Y'*C + 2*beta*P >= eye(n);
    cvx_end
    
    L = P^(-1)*Y';
end