% Analyzing section by section:
clear
load("windTunnel.mat")

figure
plot(A02)
hold on
xline(631.2121212, LineWidth=1.5, Color='red')
xline(1268.989899, LineWidth=1.5, Color='red')
xline(2021.111111, LineWidth=1.5, Color='red')
xline(2779.191919, LineWidth=1.5, Color='red')
xline(3566.262626, LineWidth=1.5, Color='red')
xline(4364.646465, LineWidth=1.5, Color='red')
xline(5127.373737, LineWidth=1.5, Color='red')
xline(5127.373737, LineWidth=1.5, Color='red')
xline(5749.494949, LineWidth=1.5, Color='red')
xlabel("Time (s)")
ylabel("Signal")

section1 = A02(745:1154, 1);
t1 = t(745:1154, 1);

revolutionTimes1 = [];

for i = 2:length(section1)
    if section1(i) == 1023 && section1(i-1) == 0
        revolutionTimes1(end+1) = t1(i);
    end
end

deltaT1 = diff(revolutionTimes1);
rps1 = mean(1./deltaT1)

section2 = A02(1443:1897, 1);
t2 = t(1443:1897, 1);

revolutionTimes2 = [];

for i = 2:length(section2)
    if section2(i) == 1023 && section2(i-1) == 0
        revolutionTimes2(end+1) = t2(i);
    end
end

deltaT2 = diff(revolutionTimes2);
rps2 = mean(1./deltaT2)

section3 = A02(2287:2510, 1);
t3 = t(2287:2510, 1);

revolutionTimes3 = [];

for i = 2:length(section3)
    if section3(i) == 1023 && section3(i-1) == 0
        revolutionTimes3(end+1) = t3(i);
    end
end

deltaT3 = diff(revolutionTimes3);
rps3 = mean(1./deltaT3)

section4 = A02(2987:3420, 1);
t4 = t(2987:3420, 1);

revolutionTimes4 = [];

for i = 2:length(section4)
    if section4(i) == 1023 && section4(i-1) == 0
        revolutionTimes4(end+1) = t4(i);
    end
end

deltaT4 = diff(revolutionTimes4);
rps4 = mean(1./deltaT4)

section5 = A02(3818:4074, 1);
t5 = t(3818:4074, 1);

revolutionTimes5 = [];

for i = 2:length(section5)
    if section5(i) == 1023 && section5(i-1) == 0
        revolutionTimes5(end+1) = t5(i);
    end
end

deltaT5 = diff(revolutionTimes5);
rps5 = mean(1./deltaT5)

revolutionTimes = [];

for i = 2:length(A02)
    if A02(i) == 1023 && A02(i-1) == 0
        revolutionTimes(end+1) = t(i);
    end
end

windowSize = 20;
deltaT = diff(revolutionTimes);
rps = 1./deltaT;
rollingRPS = movmean(rps, windowSize);
rollingT = revolutionTimes(2:end) - deltaT / 2;

figure
plot(rollingT,rollingRPS)
xlabel('Time (s)')
ylabel('RPS (Hz)')
title('RPS (Hz) vs Time (s)')