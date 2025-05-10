function g = hinfoutputcontrol(A,B1,B2,C1,C2,D11,D12,D21,D22)
    % couldn't get dimensions to work out in calculations AK BK CK and DK

    tol = 1e-4;

    cvx_begin sdp
        variable X1(16,16) symmetric
        variable Y1(16,16) symmetric
        variable An(16,16) 
        variable Bn(16,5)
        variable Cn(4,16)
        variable Dn(4,5)
        variable g
       
        subject to
            g <= .09;
            [Y1 eye(16); eye(16) X1] >= tol * eye(2*16);
            c11 = A*Y1' + Y1*A' + B2*Cn + Cn'*B2';
            c21 = A' + An + (B2*Dn*C2)';
            c22 = X1*A + A'*X1 + Bn*C2 + C2'*Bn';
            c31 = (B1 + B2*Dn*D21)';
            c32 = (X1*B1 + Bn*D21)';
            c33 = -g*eye(1);
            c41 = C1*Y1 + D12*Cn;
            c42 = C1 + D12*Dn*C2;
            c43 = D11 + D12*Dn*D21;
            c44 = -g*eye(5);
            LMI_matrix = [c11 c21' c31' c41';
                          c21 c22 c32' c42';
                          c31 c32 c33 c43';
                          c41 c42 c43 c44];
            LMI_matrix <= -tol * eye(size(LMI_matrix));
    cvx_end

    % X2 = eye(16)-X1*Y1;
    % Y2T = eye(16)';
    % step3 = inv([X2 X1*B2; zeros(4,16) eye(4)]) * ...
    %        ([An Bn; Cn Dn] - [X1*A*Y1 zeros(16,5); zeros(4,16) zeros(4,5)]) * ...
    %        inv([Y2T zeros(16,5); C2*Y1 eye(5)]);
    % AK2 = step3(1:16, 1:16);
    % BK2 = step3(1:16, 18:end); % only the last few rows ?? 
    % CK2 = step3(17:end, 1:16);
    % DK2 = step3(17:end, 18:end);
    % common = eye(4) + DK2*D22;
    % DK = inv(common)*DK2;
    % CK = common*CK2;
    % BK = BK2*common;
    % AK = AK2 - BK*inv(common)*D22*CK;
end