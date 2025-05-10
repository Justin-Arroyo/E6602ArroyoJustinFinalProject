close all; clear
filepath = "digitalizing_F100_model\state_space_models\Basic-Set_5.xlsx";
A = readmatrix(filepath, "Sheet", "A");
B = readmatrix(filepath, "Sheet", "B");
C = readmatrix(filepath, "Sheet", "C");
D = readmatrix(filepath, "Sheet", "D");
BasicSet_5 = ss(A,B,C,D);

% Define time vector (e.g., 0 to 10 seconds, sampled at 0.01s)
t = 0:0.01:5;

% Define input: constant input vector [300; 0; 0; 0; 0] repeated for all time steps
u = repmat([315; 0; 0; 0; 0], 1, length(t))';
for i=1:10
    u(i,:) = [0, 0, 0, 0, 0];
end

% Simulate the system response
[y, t_out, x] = lsim(BasicSet_5, u, t);

% figure
% plot(t, u(:,1))
% ylabel(["Fuel Flow", "\DeltaWFMB - lb/hr"])

% figure
% plot(t, x(:,3))
% ylabel(["Burner Pressure", "\DeltaP_{t3} - psia"])

% figure
% plot(t, x(:,11))
% string = "\DeltaT_{t4} - " + char(176) + "R";
% ylabel(["Turbine Inlet", "Temperature,", string])

% figure
% plot(t, y(:,4))
% ylabel(["Fan Stall Margin," "\DeltaSMAF"])

figureHandle = figure;
set(figureHandle, 'Units', 'pixels', 'Position', [100, 100, 835, 800]);
% Top subplot: Fuel Flow input
subplot(4,1,1);
grid on
plot(t, u(:,1));
ylim([0, 400])
yticks([0, 100, 200, 300, 400])
ylabel(["Fuel Flow", "\DeltaWFMB - lb/hr"]);
xticks([0, 1, 2, 3, 4, 5])

% 2nd subplot: Burner Pressure (state x3)
subplot(4,1,2);
grid on
plot(t, x(:,3));
ylim([0, 7.5])
yticks([0, 2.5, 5, 7.5])
ylabel(["Burner Pressure", "\DeltaP_{t3} - psia"]);
xticks([0, 1, 2, 3, 4, 5])

% 3rd subplot: Turbine Inlet Temperature (state x11)
subplot(4,1,3);
grid on
plot(t, x(:,11));
string = "\DeltaT_{t4} - " + char(176) + "R";
ylim([0, 75])
yticks([0, 25, 50, 75])
ylabel(["Turbine Inlet", "Temperature, ", string]);
xticks([0, 1, 2, 3, 4, 5])

% 4th subplot: Output y4 - Fan Stall Margin
subplot(4,1,4);
grid on
plot(t, y(:,4));
ylabel(["Fan Stall Margin", "\DeltaSMAF"]);
ylim([-0.001, 0.004])
yticks([-0.001, 0, 0.001, 0.002, 0.003, 0.004])
xlabel('Time - sec');
xticks([0, 1, 2, 3, 4, 5])

exportgraphics(figureHandle, 'my_figure.png', 'Resolution', 100);