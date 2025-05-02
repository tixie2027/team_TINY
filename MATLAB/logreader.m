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

TitleSize = 16;
AxisSize = 14;
Width = 1.5;

t = linspace(0, size(A02,1)/sampRate, size(A02,1))';

% figure
% plot(A02)

revolutionTimes = [];

for i = 2:length(A02)
    if A02(i) == 1023 && A02(i-1) == 0
        revolutionTimes(end+1) = t(i);
    end
end

windowSize = 15;
deltaT = diff(revolutionTimes);
rps = 1./deltaT;
rollingRPS = movmean(rps, windowSize);
rollingT = revolutionTimes(2:end) - deltaT / 2;

% figure
% plot(rollingT,rollingRPS, LineWidth = Width)
% xlabel('Time (s)', FontSize = AxisSize)
% ylabel('RPS (Hz)', FontSize = AxisSize)
% title('RPS (Hz) vs Time (s)', FontSize = TitleSize)

% Slope
beta1 = 2.3364;
% Y-intercet
beta0 = 0.4529;

% Uncertainty in slope
lambdaBeta1 = 0.2561;

% Uncertainty in intercept
lambdaBeta0 = 0.2819;

windSpeed = rollingRPS.*beta1 + beta0;

lambdaWindSpeedUncertainty = sqrt( ...
    (rollingRPS .* lambdaBeta1).^2 + ... % from slope
    lambdaBeta0^2);               % from intercept

figure
plot(rollingT,windSpeed, LineWidth=1.5)
hold on
shade(rollingT,windSpeed+lambdaWindSpeedUncertainty,'--w', ...
      rollingT,windSpeed-lambdaWindSpeedUncertainty,'--w', ...
      'FillType', [1 2;2 1], ...
      'LineWidth',0.01, ...
      'FillAlpha',0.2, ...
      'FillColor', [0 0.4470 0.7410])
% plot(rollingT,windSpeed+lambdaWindSpeedUncertainty, '-.', LineWidth=1.5)
% plot(rollingT,windSpeed-lambdaWindSpeedUncertainty, '--', LineWidth=1.5)
xlabel('Time (s)', FontSize = AxisSize)
ylabel('Wind Speed (m/s)', FontSize = AxisSize)
title('Wind Speed (m/s) vs Time (s)', FontSize = TitleSize)
yline(5.8,'-',LineWidth=Width+0.5, DisplayName='Approximate "Ground Truth" Measurement of 5.8 m/s', Color="Red");
legend('Measured Wind Speed', ...
        '', ...
        '', ...
        'Error Bounds on Measured Wind Speed', ...
        'Approximate ""Ground Truth"" Measurement of 5.8 m/s', FontSize=AxisSize-2)

% filename = "windTunnel.mat";
% save(filename, 'A02', 't')

slope = (3.0-0.3)/(1023-0);
intercept = 3.0 - 1023*slope;

A00 = double(A00);
A01 = double(A01);

cutoffFrequency = sampRate/100; 

temp1Filtered = lowpass(double(A00), cutoffFrequency, sampRate);
temp2Filtered = lowpass(double(A01), cutoffFrequency, sampRate);

temp1VFiltered = temp1Filtered*slope + intercept;
temp2VFiltered = temp2Filtered*slope + intercept;

temp1V = A00*slope + intercept;
temp2V = A01*slope + intercept;

% rCalculate = @(V) ((Rg*Rn*(-5 + V) + Rp*(5*Rf + Rn*V))*R2)/(5*Rf*Rg - Rn*(Rg*(-5 + V) + Rp*V));
    % tempCalculate

% Incase of calculating temperature using Steinhart-Hart coefficients

% A1 = 0.001613;
% B1 = 0.0008417;
% C1 = -0.0001501;
% D1 = 1.277e-05;
% lambdaA1 = (0.008732+0.005507)/2;
% lambdaB1 = (0.005938+0.004255)/2;
% lambdaC1 = (0.001064+0.001364)/2;
% lambdaD1 = (0.0001092+8.362e-05)/2;

% f4 = 
% 
%      General model:
%      f4(R) = 1/(a+b*log(R)+c*(log(R)^2)+d*(log(R)^3))
%      Coefficients (with 95% confidence bounds):
%        a =    0.001613  (-0.005507, 0.008732)
%        b =   0.0008417  (-0.004255, 0.005938)
%        c =  -0.0001501  (-0.001364, 0.001064)
%        d =   1.277e-05  (-8.362e-05, 0.0001092)


% A2 = 0.001613;
% B2 = 0.0008417;
% C2 = -0.0001501;
% D2 = 1.277e-05;
% lambdaA2 = (0.00929+0.003358)/2;
% lambdaB2 = (0.00442+0.00464)/2;
% lambdaC2 = (0.001153+0.001006)/2;
% lambdaD2 = (8.068e-05+9.042e-05)/2;

% f4 = 
% 
%      General model:
%      f4(R) = 1/(a+b*log(R)+c*(log(R)^2)+d*(log(R)^3))
%      Coefficients (with 95% confidence bounds):
%        a =    0.002966  (-0.003358, 0.00929)
%        b =  -0.0001104  (-0.00464, 0.00442)
%        c =   7.385e-05  (-0.001006, 0.001153)
%        d =  -4.871e-06  (-9.042e-05, 8.068e-05)

% tCalculate2 = @(R) 1/(A2+B2*log(R)+C2*(log(R)^2)+D2*(log(R)^3));
% tCalculate1 = @(R) 1/(A1+B1*log(R)+C1*(log(R)^2)+D1*(log(R)^3));

R0 = 47;
B = 4050;
lambdaR0 = R0*0.01;
lambdaB = B*0.01;
T0 = 25+ 273.15;

Rd1 = 46.92;
Rf1 = 2.960;
Rn1 = 0.990; 
Rg1 = 9.8;
Rp1 = 15.05;

R1 = arrayfun(@(V) rCalculate(V, Rg1, Rn1, Rp1, Rf1, Rd1), temp1VFiltered);

for i = 1:length(R1)
       lambdaR1(i) = propagateRUncertainty(temp1VFiltered(i), Rg1, Rn1, Rp1, Rf1, Rd1); 
end

% Steinhart-hart method
% T1 = arrayfun(@(R) tCalculate(A1, B1, C1, D1, R), R1)-273.15;

% Simple
T1 = arrayfun(@(R) tCalculate(B, T0, R0, R), R1)-273.15;

for i = 1:length(T1)
       % Steinhart-hart method
       % lambdaT1(i) = propagateTUncertainty(A1, B1, C1, D1, R1(i), ...
       %     lambdaA1, lambdaB1, lambdaC1, lambdaD1, lambdaR1(i));

       % Simple equation
       lambdaT1(i) = propagateTUncertainty(B, R0, T0, R1(i), lambdaB, lambdaR0, lambdaR1(i));
end

Rd2 = 46.92;
Rf2 = 2.960;
Rn2 = 0.990; 
Rg2 = 9.8;
Rp2 = 15.05;

R2 = arrayfun(@(V) rCalculate(V, Rg2, Rn2, Rp2, Rf2, Rd2), temp2VFiltered);

for i = 1:length(R2)
       lambdaR2(i) = propagateRUncertainty(temp2VFiltered(i), Rg2, Rn2, Rp2, Rf2, Rd2); 
end

% Steinhart-hart method
% T1 = arrayfun(@(R) tCalculate(A1, B1, C1, D1, R), R1)-273.15;

% Simple
T2 = arrayfun(@(R) tCalculate(B, T0, R0, R), R2)-273.15;

tCalculate(B, T0, R0, 96.52034468)-273.15

for i = 1:length(T2)
       % Steinhart-hart method
       % lambdaT1(i) = propagateTUncertainty(A1, B1, C1, D1, R1(i), ...
       %     lambdaA1, lambdaB1, lambdaC1, lambdaD1, lambdaR1(i));

       % Simple equation
       lambdaT2(i) = propagateTUncertainty(B, R0, T0, R2(i), lambdaB, lambdaR0, lambdaR2(i));
end

xconf = [t t(end:-1:1)];
yconf = [T1-lambdaT1' fliplr(T1(end:-1:1)+lambdaT1')];

% figure
% plot(t,T1, LineWidth = Width)
% hold on
% plot(t,T1+lambdaT1', '-.', LineWidth = Width, Color = "#D95319")
% plot(t,T1-lambdaT1', '--', LineWidth = Width, Color = "#EDB120")


figure
plot(t,T1, LineWidth = Width)
hold on
shade(t,T1+lambdaT1','--w', ...
      t,T1-lambdaT1','--w', ...
      'FillType', [1 2;2 1], ...
      'LineWidth',0.01, ...
      'FillAlpha',0.2, ...
      'FillColor', [0 0.4470 0.7410])
title('Converted Temperature Data (°C) vs. Time (s) - Air', FontSize=TitleSize)
yline(15.1,'-',LineWidth=Width+0.5, DisplayName="Ground Truth Measurement of 15.2°C", Color="Red");
xlabel('Time (s)', FontSize=AxisSize)
ylabel('Temperature (°C)', FontSize=AxisSize)
legend('Measured Temperature', ...
        '', ...
        '', ...
        'Error Bounds on Measured Temperature', ...
        'Ground Truth Measurement of 15.2°C', FontSize=AxisSize-2)
xlim([28 360])

figure
hold on
plot(t,T2, LineWidth = Width)
shade(t,T2+lambdaT2','--w', ...
      t,T2-lambdaT2','--w', ...
      'FillType', [1 2;2 1], ...
      'LineWidth',0.01, ...
      'FillAlpha',0.2, ...
      'FillColor', [0 0.4470 0.7410])
title('Converted Temperature Data (°C) vs. Time (s) - Water', FontSize=TitleSize)
yline(16.0,'-',LineWidth=Width+0.5, DisplayName="Ground Truth Measurement of 16.0°C", Color = "Red");
xlabel('Time (s)', FontSize=AxisSize)
ylabel('Temperature (°C)', FontSize=AxisSize)
xlim([28 360])
legend('Measured Temperature', ...
        '', ...
        '', ...
        'Error Bounds on Measured Temperature', ...
        'Ground Truth Measurement of 16.0°C', FontSize=AxisSize-2)

figure
    plot(t,A03, LineWidth = Width)
title('Weather Vane')