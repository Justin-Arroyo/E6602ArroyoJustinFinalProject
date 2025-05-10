function [sys, A_Luen] = luenberger(A, B, C, D, K, L)
    n = size(A,1);
    m = size(B,2);
    p = size(C,1);
    A_Luen = [A B*K; -L*C A+L*C+B*K];
    B_Luen = [B; zeros(size(B))];
    C_Luen = [C zeros(size(C))];
    sys = ss(A_Luen, B_Luen, C_Luen, D);
end