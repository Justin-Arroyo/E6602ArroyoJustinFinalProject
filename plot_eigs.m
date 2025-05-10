function plot_eigs(varargin)
% plot_eigs(A1, A2, A3, A4)
% Plots eigenvalues of up to 4 A matrices on the same complex plane

colors = ['b', 'r', 'g', 'm']; % blue, red, green, magenta
markers = ['o', 's', 'd', '^']; % circle, square, diamond, triangle
labels = {}; % Initialize labels

figure;
hold on;

for k = 1:length(varargin)
    A = varargin{k};
    eigs_A = eig(A);
    scatter(real(eigs_A), imag(eigs_A), 100, markers(k), 'filled', 'MarkerFaceColor', colors(k));
    labels{end+1} = ['Matrix ' num2str(k)];
end

% Draw axes
xline(0, 'k--');
yline(0, 'k--');

% Styling
grid on;
xlabel('Real Axis');
ylabel('Imaginary Axis');
legend(labels, 'Location', 'best');
% title('Eigenvalue Comparison');
hold off;

xlim padded
ylim padded

end
