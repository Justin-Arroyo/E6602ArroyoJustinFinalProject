clear; close all;
filepath = "state_space_models\Basic-Set_5.xlsx";
% filepath = "state_space_models\Group-2_9.xlsx";
A = readmatrix(filepath, "Sheet", "A");
B = readmatrix(filepath, "Sheet", "B");
C = readmatrix(filepath, "Sheet", "C");
D = readmatrix(filepath, "Sheet", "D");
n = size(A,1);
m = size(B,2);
p = size(C,1);
% if separating out fuel flow from other inputs
B1 = B(:, 1);
B2 = B(:, 2:5);
C1 = C(2:end, :); % i don't want change in thrust to be minimized
D11 = D(2:end, 1);
D12 = D(2:end, 2:5);

%% luenberger observer
% alphaC = 2; betaC = 10000;
% K = pole_placement_controller(A, B, alphaC, betaC);
% 
% alphaO = 10; betaO = 1000;
% L = pole_placement_observer(A, C, alphaO, betaO);
% 
% [sys, A_Luen] = luenberger(A, B, C, D, K, L);
% 
% t = linspace(0, .5, 1000)';
% u = zeros(length(t), m);
% x0 = [10*ones(n,1); zeros(n,1)];
% [y, t, x] = lsim(sys, u, t, x0);
% 
% figure
% subplot(1,2,1)
% hold on
% plot(t, x(:,5))
% plot(t, x(:,16+5))
% hold off
% ylabel('Augmentor Pressure x_5')
% xlabel('Time - sec')
% legend('Actual', 'Estimate')
% 
% subplot(1,2,2)
% hold on
% plot(t, x(:,16))
% plot(t, x(:,16+16))
% hold off
% xlabel('Time - sec')
% ylabel('Duct Exit Temperature x_{16}')
% legend('Actual', 'Estimate')

% % new figure
% plot_eigs(A,A_Luen)
% xlim([-10,0])
%% hinf control and nice plots
[g, F, sys_cl] = hinfcontrol(A,B1,B2,C1,D11,D12);

% Time vector and disturbance input
t = 0:0.01:10;
w = zeros(size(t));       % Step input for fuel flow
w(100:end) = 30;

% Simulate open-loop state trajectory under disturbance input
sys_ol = ss(A, B1, eye(size(A)), 0);  % Full state output
[~, ~, x_states] = lsim(sys_ol, w, t);

% Compute control inputs: u = F x
u_control = (F * x_states')';  % dimensions: time x 4

% --- Plot Control Inputs + Disturbance ---
figure;
plot(t, u_control, 'LineWidth', 1.5); hold on;
plot(t, w, 'k--', 'LineWidth', 1.2);  % plot disturbance
% title('Control Inputs and Disturbance Input (Fuel Flow)');
xlabel('Time (s)');
ylabel('Amplitude');
legend({'Nozzle Area (ft^2)','Inlet Vane Position (deg)','Compressor Vane Position (deg)','Bleed Flow (%)','Fuel Flow (lb/hr)'}, 'Location', 'best');
grid on;

% --- Simulate Closed-loop Output Response ---
% Your sys_cl maps disturbance w → regulated outputs y.
% But those outputs are still all 5; controller just doesn't regulate y1.
sys_y = ss(A + B2*F, B1, C, D(:,1));  % Full system outputs for analysis
[y_cl, ~, ~] = lsim(sys_y, w, t);

% --- Plot All Outputs ---
figure;
subplot(3,2,1);
plot(t, w, 'k', 'LineWidth', 1.5);
title('Disturbance Input (w)');
ylabel('w');
grid on;

output_labels = { ...
    'Thrust', ...
    'Airflow', ...
    'Inlet Temperature', ...
    'Fan Stall Margin', ...
    'Compressor Stall Margin'};

for i = 1:5
    subplot(3,2,i+1);
    plot(t, y_cl(:, i), 'LineWidth', 1.5);
    title(output_labels{i});
    ylabel(output_labels{i});
    xlabel('Time (s)');
    grid on;
end

% --- Plot State 9 Over Time ---
figure;
plot(t, x_states(:,9), 'b', 'LineWidth', 1.5);
title('State 9 Over Time');
xlabel('Time (s)');
ylabel('State 9 Value');
grid on;
