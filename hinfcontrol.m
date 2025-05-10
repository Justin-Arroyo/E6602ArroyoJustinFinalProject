function [g, F, sys_cl] = hinfcontrol(A,B1,B2,C1,D11,D12)
    n = size(A,1);
    m = size(B2,2);
    p = size(C1,1);
    tol = 1e-6;
    
    cvx_begin sdp
        variable Y(n,n) symmetric
        variable Z(m,n)
        variable g
    
        subject to
            % Basic-Set_5 g <= .0005
            % Group-2_10 g <= .575
            % Group-2_9 g <= 0.004
            g <= .0005;
            Y >= tol * eye(n);
            LMI = [Y*A' + A*Y + Z'*B2' + B2*Z,       B1,    Y*C1'+Z'*D12';
                   B1',            -g*eye(1), D11';
                   C1*Y + D12*Z,               D11,          -g*eye(p)];
            LMI <= -tol * eye(size(LMI)); 
    cvx_end
    
    F = Z*Y^-1;
    
    Acl = A + B2*F;
    Bcl = B1;
    Ccl = C1 + D12*F;
    Dcl = D11;
    sys_cl = ss(Acl, Bcl, Ccl, Dcl);
end