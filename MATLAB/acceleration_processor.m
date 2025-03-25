%% Tian Xie, tixie@hmc.edu, 1/31/2025

plot(accelX*0.0103)       %% plot accelX with the IMU offset

hold on     %% adding Y and Z axis on one plot

%% adding Y and Z axis
plot(accelY*0.0103)
plot(accelZ*0.0103)

%% labels for X and Y axis, adding a title and legend for the graph
xlabel('Sample number (N)')
ylabel('Acceleration (M/s^2)')
title('Figure 1: Acceleration (M/s^2) vs Sample number (N)')
legend('accelX','accelY','accelZ')
xlim([1100 1500])		% limit x-axis from 1100-1500 sample numbers
ylim([-15 30])

hold off    
