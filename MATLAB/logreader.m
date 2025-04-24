% logreader.m
% Use this script to read data from your micro SD card

clear;
%clf;

filenum = '105'; % file number for the data you want to read
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
sampRate = 10;
%% Process your data here

t = linspace(0, 3018/sampRate, 3018)';
figure
plot(t,A02)
% xlim([15 40])
% ylim([0 1200])
% figure
% plot(A02)
% ylim([0 1200])
% xlabel('Sample number')
% ylabel('Teensy unit')
% title(['y-acceleration vs time'])

revolutionTimes = [];

for i = 2:length(A02)
    if A02(i) == 1023 && A02(i-1) == 0
        revolutionTimes(end+1) = t(i);
    end
end

windowSize = 25;
deltaT = diff(revolutionTimes);
rps = 1./deltaT;
rollingRPS = movmean(rps, windowSize);
rollingT = revolutionTimes(2:end) - deltaT / 2;

figure
plot(rollingT,rollingRPS)
xlabel('Time (s)')
ylabel('RPS (Hz)')
title(['y-acceleration vs time'])