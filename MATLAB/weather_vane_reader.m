% logreader.m
% Use this script to read data from your micro SD card

clear;
%clf;

filenum = '018'; % file number for the data you want to read
infofile = strcat('INF', filenum, '.TXT');
datafile = strcat('LOG', filenum, '.BIN');

%% map from datatype to length in bytes
dataSizes.('float') = 4;
dataSizes.('ulong') = 4;
dataSizes.('int') = 4;
dataSizes.('int32') = 4;
dataSizes.('uint8') = 1;
dataSizes.('uint16') = 2;
dataSizes.('char') = 1;
dataSizes.('bool') = 1;

%% read from info file to get log file structure
fileID = fopen(infofile);
items = textscan(fileID,'%s','Delimiter',',','EndOfLine','\r\n');
fclose(fileID);
[ncols,~] = size(items{1});
ncols = ncols/2;
varNames = items{1}(1:ncols)';
varTypes = items{1}(ncols+1:end)';
varLengths = zeros(size(varTypes));
colLength = 256;
for i = 1:numel(varTypes)
    varLengths(i) = dataSizes.(varTypes{i});
end
R = cell(1,numel(varNames));

%% read column-by-column from datafile
fid = fopen(datafile,'rb');
for i=1:numel(varTypes)
    %# seek to the first field of the first record
    fseek(fid, sum(varLengths(1:i-1)), 'bof');
    
    %# % read column with specified format, skipping required number of bytes
    R{i} = fread(fid, Inf, ['*' varTypes{i}], colLength-varLengths(i));
    eval(strcat(varNames{i},'=','R{',num2str(i),'};'));
end
fclose(fid);
sampT = 99*10^-3;
sampRate = 1/sampT;

%% Process your data here

% initial setup
t = linspace(0, size(A02,1)/sampRate, size(A02,1))';
a = A03;
N = length(A03);
Fs = sampRate;

% fourier transform and inverse: applied low pass filter
X = fftshift(fft(a));
f = Fs * (-N/2 : N/2 - 1) / N;
X_filtered = X;
X_filtered(abs(f) > 0.1) = 0;
A03_filtered = ifft(ifftshift(X_filtered));

% plot the raw data vs transformed data
figure;
plot(t, A03);
hold on;
plot(t, A03_filtered, 'LineWidth', 2);
title('Weather Vane!')
legend('Raw data', 'Filtered data');
xlabel('Time (s)')
ylabel('Raw Teensy voltage reading')

% our time of interest: find its average and standard deviation. Change accordingly
range_idx = (t >= 130) & (t <= 240);
avg_A03 = mean(real(A03_filtered(range_idx)));
std_A03 = std(single(A03_filtered(range_idx)));
disp(['Average A03 between t = 130 and 240: ', num2str(avg_A03)]);
disp(['Std A03: ', num2str(std_A03)]);

% heading of our robot from IMU, only need STD
figure
plot(headingIMU)
title('heading')

% heading of the weather vane
relative_heading = single((real(A03_filtered) - 316) * 360 / 1000);
relative_heading_uncer = single(std_A03 * 360 / (2*1000)) * ones(size(relative_heading), 'single');
figure
plot(relative_heading)

% actual wind heading by combining values
actual_wind = headingIMU - relative_heading;
range_id = (750 <= (1:length(actual_wind))) & ((1:length(actual_wind)) <= 2500);

% average, STD, and 
avg_wind_dir = mean(actual_wind(range_id));
IMU_uncer = std(headingIMU(range_id));

% wind uncertainty = IMU heading uncertainty + weather vane heading uncertainty
actual_wind_uncer = sqrt(abs(IMU_uncer)^2 + abs(relative_heading_uncer(end))^2); 
time = linspace(0, length(A03), length(A03));

figure
plot(actual_wind, 'o', 'MarkerSize', 4, 'LineWidth', 1.5);
shade(time, actual_wind+actual_wind_uncer, time, actual_wind-actual_wind_uncer, 'FillType', [1 2;2 1]);
disp(['Average wind dir: ', num2str(avg_wind_dir)]);
title("angle relative to North (CW) with uncertainties")


% Angle from north in degrees
angle_deg = avg_wind_dir+180;
theta = deg2rad(angle_deg); % Convert to radians

% Uncertainty in degrees
uncertainty_deg = 4.359824180603027;
uncertainty_rad = deg2rad(uncertainty_deg);

% Convert to MATLAB coordinates: 0 = North (Y+), CCW positive
theta_shifted = pi/2 - theta;

% Unit circle
theta_circle = linspace(0, 2*pi, 200);
x_circle = cos(theta_circle);
y_circle = sin(theta_circle);

% Arrow endpoint
x_arrow = cos(theta_shifted);
y_arrow = sin(theta_shifted);

% Uncertainty arc
theta_arc = linspace(theta_shifted - uncertainty_rad, theta_shifted + uncertainty_rad, 100);
x_arc = [0, cos(theta_arc), 0];
y_arc = [0, sin(theta_arc), 0];

% Plot
figure;
hold on;
fill(x_arc, y_arc, [1, 0.8, 0.8], 'EdgeColor', 'none'); % Light red uncertainty wedge
plot(x_circle, y_circle, 'b'); % Unit circle
quiver(0, 0, x_arrow, y_arrow, 0, 'r', 'LineWidth', 2, 'MaxHeadSize', 0.3); % Arrow
plot(x_arrow, y_arrow, 'ro'); % Arrow tip

% Appearance
axis equal;
grid on;
box off; % Hide bounding box but keep tick labels
xlabel('X');
ylabel('Y');
title(sprintf('Wind direction at %.1f° ± %.2f° from North (Y-axis)', angle_deg, uncertainty_deg/2));
hold off;
