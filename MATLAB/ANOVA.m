load("012.mat")
T1_0930 = T1;
T1_0930 = T1_0930(1100:2100);
T2_0930 = T2;
T2_0930 = T2_0930(1100:2100);

load("016.mat")
T1_1150 = T1;
T1_1150 = T1_1150(1200:2200);
T2_1150 = T2;
T2_1150 = T2_1150(1200:2200);

load("017.mat")
T1_1210 = T1;
T1_1210 = T1_1210(1050:2050);
T2_1210 = T2;
T2_1210 = T2_1210(1050:2050);

load("018.mat")
T1_1230 = T1;
T1_1230 = T1_1230(750:1750);
T2_1230 = T2;
T2_1230 = T2_1230(750:1750);

load("019.mat")
T1_1255 = T1;
T1_1255 = T1_1255(1000:2000);
T2_1255 = T2;
T2_1255 = T2_1255(1000:2000);

load("021.mat")
T1_1400 = T1;
T1_1400 = T1_1400(1200:2200);
T2_1400 = T2;
T2_1400 = T2_1400(1200:2200);

load("022.mat")
T1_1420 = T1;
T1_1420 = T1_1420(1300:2300);
T2_1420 = T2;
T2_1420 = T2_1420(1300:2300);

TitleSize = 16;
AxisSize = 14;
Width = 1.5;

air = [T1_0930 T1_1150 T1_1210 T1_1230 T1_1255 T1_1400 T1_1420];
[p,tbl,stats] = anova1(air);

% Customize the box plot
xlabel('Time Group', 'FontSize',AxisSize);
ylabel('Temperature', 'FontSize',AxisSize);
title('Air Temperature (\circC) vs. Time', 'FontSize',TitleSize);

% Access the current axes
ax = gca;

ax.XAxis.FontSize = AxisSize-2;  % Set font size for the x-axis numbers
ax.YAxis.FontSize = AxisSize-2;  % Set font size for the y-axis numbers

timeGroups = {"09:30AM", "11:50AM", "12:10PM", "12:30PM", "12:55PM", "02:00PM", "02:20PM"};
xticklabels(timeGroups);

% Find the box plot objects
h = findobj(ax, 'Type', 'box');

% Modify the line width for each box (making it thicker)
for i = 1:length(h)
    h(i).LineWidth = Width; 
end

% Modify the whisker lines to make them thicker
whiskers = findobj(ax, 'Type', 'line');
for i = 1:length(whiskers)
    whiskers(i).LineWidth = Width;
end

% Modify the median lines to make them thicker
medians = findobj(ax, 'Type', 'line', 'Tag', 'Median');
for i = 1:length(medians)
    medians(i).LineWidth = Width;
end

% Modify the outlier markers to make them thicker (scatter points)
outliers = findobj(ax, 'Type', 'scatter');
for i = 1:length(outliers)
    outliers(i).LineWidth = Width;
end

water = [T2_0930 T2_1150 T2_1210 T2_1230 T2_1255 T2_1400 T2_1420];
[p,tbl,stats] = anova1(water);

% Customize the box plot
xlabel('Time Group', 'FontSize',AxisSize);
ylabel('Temperature', 'FontSize',AxisSize);
title('Water Temperature (\circC) vs. Time', 'FontSize',TitleSize);

% Access the current axes
ax = gca;

ax.XAxis.FontSize = AxisSize-2;  % Set font size for the x-axis numbers
ax.YAxis.FontSize = AxisSize-2;  % Set font size for the y-axis numbers

timeGroups = {"09:30AM", "11:50AM", "12:10PM", "12:30PM", "12:55PM", "02:00PM", "02:20PM"};
xticklabels(timeGroups);

% Find the box plot objects
h = findobj(ax, 'Type', 'box');

% Modify the line width for each box (making it thicker)
for i = 1:length(h)
    h(i).LineWidth = Width; 
end

% Modify the whisker lines to make them thicker
whiskers = findobj(ax, 'Type', 'line');
for i = 1:length(whiskers)
    whiskers(i).LineWidth = Width;
end

% Modify the median lines to make them thicker
medians = findobj(ax, 'Type', 'line', 'Tag', 'Median');
for i = 1:length(medians)
    medians(i).LineWidth = Width;
end

% Modify the outlier markers to make them thicker (scatter points)
outliers = findobj(ax, 'Type', 'scatter');
for i = 1:length(outliers)
    outliers(i).LineWidth = Width;
end

dataMatrix = [T1_0930, T1_1150, T1_1210, T1_1230, T1_1255, T1_1400, T1_1420];

nGroups = size(dataMatrix, 2);
alpha = 0.05;
nComparisons = nchoosek(nGroups, 2);
alphaBonferroni = alpha / nComparisons;

fprintf('Pairwise t-tests with Bonferroni correction (AIR) (alpha = %.5f):\n\n', alphaBonferroni);

for i = 1:nGroups-1
    for j = i+1:nGroups
        group1 = dataMatrix(:, i);
        group2 = dataMatrix(:, j);
        
        [h, p, ci, stats] = ttest2(group1, group2, 'Alpha', alphaBonferroni);
        
        fprintf('Group %d vs Group %d\n', i, j);
        fprintf('  h = %d (0 = no difference, 1 = significant difference)\n', h);
        fprintf('  p-value = %.4f\n', p);
        fprintf('  %.1f%% CI = [%.4f, %.4f]\n', (1-alphaBonferroni)*100, ci(1), ci(2));
        fprintf('  t-statistic = %.4f\n', stats.tstat);
        fprintf('  Degrees of Freedom = %.4f\n\n', stats.df);
    end
end

dataMatrix = [T2_0930, T2_1150, T2_1210, T2_1230, T2_1255, T2_1400, T2_1420];

nGroups = size(dataMatrix, 2);
alpha = 0.05;
nComparisons = nchoosek(nGroups, 2);
alphaBonferroni = alpha / nComparisons;

fprintf('Pairwise t-tests with Bonferroni correction (WATER) (alpha = %.5f):\n\n', alphaBonferroni);

for i = 1:nGroups-1
    for j = i+1:nGroups
        group1 = dataMatrix(:, i);
        group2 = dataMatrix(:, j);
        
        [h, p, ci, stats] = ttest2(group1, group2, 'Alpha', alphaBonferroni);
        
        fprintf('Group %d vs Group %d\n', i, j);
        fprintf('  h = %d (0 = no difference, 1 = significant difference)\n', h);
        fprintf('  p-value = %.4f\n', p);
        fprintf('  %.1f%% CI = [%.4f, %.4f]\n', (1-alphaBonferroni)*100, ci(1), ci(2));
        fprintf('  t-statistic = %.4f\n', stats.tstat);
        fprintf('  Degrees of Freedom = %.4f\n\n', stats.df);
    end
end