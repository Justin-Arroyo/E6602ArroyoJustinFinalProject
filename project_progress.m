clear; close all
filepath = "digitalizing_F100_model\state_space_models\Group-2_10.xlsx";
A = readmatrix(filepath, "Sheet", "A");
B = readmatrix(filepath, "Sheet", "B");

n = 16; m = 5;
cvx_begin sdp
    variable X(n,n) symmetric
    variable L(m,n)

    X >= eye(n);
    [A B] * [X; L] + [X L'] * [A'; B'] <= -eye(n);
    % learned to do the nonstrict inequality from
    % Boyd (and the error message)
    % https://stanford.edu/class/ee363/notes/lmi-cvx.pdf
cvx_end

K = L*X^-1;

eig(A+B*K);

A_eigvals = eig(A); % Compute eigenvalues
ABK_eigvals = eig(A+B*K);

% Plot eigenvalues in the complex plane
figure
hold on
scatter(real(A_eigvals), imag(A_eigvals), 50, 'filled')
scatter(real(ABK_eigvals), imag(ABK_eigvals), 50, 'filled')
xline(0, 'k--') % Dashed black line for the imaginary axis
yline(0, 'k--') % Dashed black line for the real axis
hold off
legend('Eigenvalues of A', 'Eigenvalues of A+BK', 'Location', 'northwest')
grid on
xlabel('Real Part')
ylabel('Imaginary Part')
% axis equal

figure
hold on
scatter(real(A_eigvals), imag(A_eigvals), 50, 'filled')
scatter(real(ABK_eigvals), imag(ABK_eigvals), 50, 'filled')
xline(0, 'k--') % Dashed black line for the imaginary axis
yline(0, 'k--') % Dashed black line for the real axis
hold off
legend('Eigenvalues of A', 'Eigenvalues of A+BK', 'Location', 'northwest')
grid on
xlabel('Real Part')
xlim([-50 50])
ylim([-20 20])
ylabel('Imaginary Part')
% axis equal

