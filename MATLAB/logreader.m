% logreader.m
% Use this script to read data from your micro SD card

clear;
%clf;

filenum = '016'; % file number for the data you want to read
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

t = linspace(0, size(A02,1)/sampRate, size(A02,1))';

figure
plot(A02)

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

figure
plot(rollingT,rollingRPS, LineWidth = 1.5)
xlabel('Time (s)', FontSize = AxisSize)
ylabel('RPS (Hz)', FontSize = AxisSize)
title('RPS (Hz) vs Time (s)', FontSize = TitleSize)

windSpeed = rollingRPS.*2.34+0.453;

figure
plot(rollingT,windSpeed, LineWidth=1.5)
xlabel('Time (s)', FontSize = AxisSize)
ylabel('Wind Speed (m/s)', FontSize = AxisSize)
title('Wind Speed (m/s) vs Time (s)', FontSize = TitleSize)

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


R2 = 47;
Rf = 3;
Rn = 1; 
Rg = 10;
Rp = 15;

rCalculate = @(V) ((Rg*Rn*(-5 + V) + Rp*(5*Rf + Rn*V))*R2)/(5*Rf*Rg - Rn*(Rg*(-5 + V) + Rp*V));
    % tempCalculate


A1 = 0.001613;
B1 = 0.0008417;
C1 = -0.0001501;
D1 = 1.277e-05;

tCalculate1 = @(R) 1/(A1+B1*log(R)+C1*(log(R)^2)+D1*(log(R)^3));

% f4 = 
% 
%      General model:
%      f4(R) = 1/(a+b*log(R)+c*(log(R)^2)+d*(log(R)^3))
%      Coefficients (with 95% confidence bounds):
%        a =    0.001613  (-0.005507, 0.008732)
%        b =   0.0008417  (-0.004255, 0.005938)
%        c =  -0.0001501  (-0.001364, 0.001064)
%        d =   1.277e-05  (-8.362e-05, 0.0001092)


A2 = 0.001613;
B2 = 0.0008417;
C2 = -0.0001501;
D2 = 1.277e-05;

% f4 = 
% 
%      General model:
%      f4(R) = 1/(a+b*log(R)+c*(log(R)^2)+d*(log(R)^3))
%      Coefficients (with 95% confidence bounds):
%        a =    0.002966  (-0.003358, 0.00929)
%        b =  -0.0001104  (-0.00464, 0.00442)
%        c =   7.385e-05  (-0.001006, 0.001153)
%        d =  -4.871e-06  (-9.042e-05, 8.068e-05)

tCalculate2 = @(R) 1/(A2+B2*log(R)+C2*(log(R)^2)+D2*(log(R)^3));

R1 = arrayfun(@(V) rCalculate(V), temp1VFiltered);
T1 = arrayfun(@(R) tCalculate1(R), R1)-273.15;

R2 = arrayfun(@(V) rCalculate(V), temp2VFiltered);
T2 = arrayfun(@(R) tCalculate2(R), R2)-273.15;


figure
plot(t,T2, LineWidth = 1.5)
hold on
plot(t,T1, LineWidth = 1.5)
% xlim([100 250])
title('Converted Temperature Data (°C) vs. Time (s)', FontSize=TitleSize)
xlabel('Time (s)', FontSize=AxisSize)
ylabel('Temperature (°C)', FontSize=AxisSize)
legend('Water', 'Air')

% figure
% plot(t,T2)
% hold on
% % plot(t, temp2V)
% title(['Thermistor 2'])

figure
plot(t,A03, LineWidth = 1.5)
title(['Weather Vane'])