% this is a follow up file that takes information like area of intereset
% from a prvious analysis
clear

bAreaOfInteresetActive = false; %apply area of interest


addpath("Scripts")
addpath("submodules/matlab-tools")
binMapFolder = "Results/";

% Get a list of all files in the folder
fileList = dir(fullfile(binMapFolder, '*.mat'));
binMapCnt = size(fileList,1);

MapX = [50, 200];
MapY = [50, 170];

%setup data for relevant statistics
binCntSummary = zeros(binMapCnt+1,1);
binMapBinDataArray=cell(1,binMapCnt);
binMapBinDataArrayUnfiltered=cell(1,binMapCnt);
avPenRates = zeros(binMapCnt+1,1);


% penrate calc for first 10 is wrong
avPenRates(4:6) = [29 41.2 49.9];

%% extract data
for dataSize=1:binMapCnt

    binMapName = fileList(dataSize).name;
        
    areaOfInterest = [105, 135, 100, 130]; %x1 x2 y1 y2

    % analyseSingleBinmap(binMapFolder+binMapName,osmDataName,MapX,MapY,bIsStaticOcculsionScenario, maxBinValue)
    load(binMapFolder+binMapName);

    if bAreaOfInteresetActive
        areaOfInterest = areaOfInterest - [MapX(1) MapX(1) MapY(1) MapY(1)];
    else
        areaOfInterest(1) = 1;
        areaOfInterest(2) = size(binmap,1);
        areaOfInterest(3) = 1;
        areaOfInterest(4) = size(binmap,2);
    end

    for xIter = areaOfInterest(1):areaOfInterest(2)
        for yIter = areaOfInterest(3):areaOfInterest(4)   
            
            binCntSummary(dataSize+1) = binCntSummary(dataSize+1)+binmap(xIter,yIter);
            % end of single bin evaluation
        end
        % pause(0.0001) 
        % end of column evaluation
    end
    
    % get the statistics of each binmap
    binStatData = reshape(binmap,1,[]);
    binStatDataNoZeros = binStatData(binStatData~=0);
    
    binMapBinDataArrayUnfiltered{dataSize} = binStatDataNoZeros;
    % removeWorstOutliers
    outlierTheshold = max(binStatData)*0.01;
    
    dataAboveThreshold = binStatDataNoZeros(binStatDataNoZeros >= outlierTheshold);
    
    binMapBinDataArray{dataSize} = dataAboveThreshold;

    % get penrates real:
    if (dataSize==3 || dataSize==4 || dataSize==5)
        %nop
    else
        avPenRates(dataSize+1) = median(ts_AVPenetrationRate); 
    end

end

%% plot statistics

% figure('units','normalized','outerposition',[0 0 1 1]) % left screen if applicable
figure('units','normalized','outerposition',[0 0 1 1]) % left screen if applicable



plot(avPenRates, binCntSummary)
font_size = 25;

% Add labels to x and y axis
xlabel('percentage steps', 'FontName', 'Times','FontSize',font_size)
ylabel('Number of observations', 'FontName', 'Times','FontSize',font_size)

% Set the current axes font to Times New Roman
set(gca, 'FontName', 'Times')
ax = gca;
ax.FontSize = font_size;  
grid on

%% analyse detection per second on average

% aimsunDataName = "aimsunData/dynamicOcclusionScenario.xml";
% aimsunData = xml2struct(aimsunDataName);
% from the xml we know the simulations last time frame is <FRAME TIME="00:30:05.100">
% simTime=<FRAME TIME="00:30:05.100">
simTime = duration(0,30, 5, 100); % 30 minutes, 5 second, 100 milliseconds
% minutes(simTime)
seconds(simTime)



% figure('units','normalized','outerposition',[0 0 1 1]) % left screen if applicable
figure('units','normalized','outerposition',[0 0 1 1]) % left screen if applicable

%% highest observation bin

% get observations per second 
observationRate = binCntSummary' /seconds(simTime)

subplot(2,2,1)
plot(avPenRates, observationRate)
font_size = 25;
% Add labels to x and y axis
title("highest observation bin")
xlabel('percentage steps', 'FontName', 'Times','FontSize',font_size)
ylabel('observationRate', 'FontName', 'Times','FontSize',font_size)

% Set the current axes font to Times New Roman
set(gca, 'FontName', 'Times')
ax = gca;
ax.FontSize = font_size;  
grid on

% get observations per second on average
observationRate = binCntSummary' /seconds(simTime)

subplot(2,2,2)
plot(avPenRates, observationRate)
font_size = 25;
% Add labels to x and y axis
title("highest observation bin")
xlabel('percentage steps', 'FontName', 'Times','FontSize',font_size)
ylabel('observationRate', 'FontName', 'Times','FontSize',font_size)

% Set the current axes font to Times New Roman
set(gca, 'FontName', 'Times')
ax = gca;
ax.FontSize = font_size;  
grid on


%%
figure('units','normalized','outerposition',[0 0 1 1]) % left screen if applicable

%% bin counts
subplot(2,2,1)
title("outlier filtered")
hold on;
for iter = 1:binMapCnt
    % Plot the boxplots
    boxplot(binMapBinDataArray{iter}, 'positions', [iter]);
end
% Set the x-axis labels
xticks([1:binMapCnt]);
xticklabels({'10%', '20%', '30%', '40%', '50%', '60%', '70%', '80%', '90%', '100%'});
% Set the title and labels
title('Boxplot Comparison');
ylabel('Observations');
% Release the hold
hold off;
%% bin counts raw
subplot(2,2,2)
hold on;
title("outlier unfiltered")
for iter = 1:binMapCnt
    % Plot the boxplots
    boxplot(binMapBinDataArrayUnfiltered{iter}, 'positions', [iter]);
end
% Set the x-axis labels
xticks([1:binMapCnt]);
xticklabels({'10%', '20%', '30%', '40%', '50%', '60%', '70%', '80%', '90%', '100%'});
% Set the title and labels
title('Boxplot Comparison');
ylabel('Observations');
% Release the hold
hold off;

%% observations per second


subplot(2,2,3)
hold on;
title("outlier unfiltered")
for iter = 1:binMapCnt
    % Plot the boxplots
    observationRate = binMapBinDataArrayUnfiltered{iter} /seconds(simTime);

    temp = boxplot(observationRate, 'positions', [iter]);
end
% Set the x-axis labels
xticks([1:binMapCnt]);
xticklabels({'10%', '20%', '30%', '40%', '50%', '60%', '70%', '80%', '90%', '100%'});
% Set the title and labels
title('Boxplot Comparison');
ylabel('Observations/s');
% Release the hold
hold off;

%%

subplot(2,2,4)
hold on;
title("outlier unfiltered")
max_observer_var = zeros (1,11);
median_observer_var = zeros (1,11);
mean_observer_var = zeros (1,11);
for iter = 1:binMapCnt
    % Plot the boxplots
    observationRate = binMapBinDataArrayUnfiltered{iter} /seconds(simTime);

    max_observer_var(iter+1)=max(observationRate);
    median_observer_var(iter+1)=median(observationRate);
    mean_observer_var(iter+1)=mean(observationRate);
end
plot(avPenRates,median_observer_var)
% Set the x-axis labels
xticks([1:binMapCnt+1]);
xticklabels({'0%','10%', '20%', '30%', '40%', '50%', '60%', '70%', '80%', '90%', '100%'});
% Set the title and labels
title('Boxplot Comparison');
ylabel('Observations/s');
% Release the hold
hold off;

%% for latex:

coordinates_str = 'coordinates {';
for i = 1:length(avPenRates)
    coordinates_str = [coordinates_str sprintf('(%0.4f,%0.4f)', avPenRates(i), median_observer_var(i))];
    if i ~= length(avPenRates)
        coordinates_str = [coordinates_str ' '];
    end
end
coordinates_str = [coordinates_str '}'];

disp(coordinates_str);



%%

figure
hold on;
title("outlier unfiltered")
max_observer_var = zeros (1,binMapCnt+1);
median_observer_var = zeros (1,binMapCnt+1);
mean_observer_var = zeros (1,binMapCnt+1);
for iter = 1:binMapCnt
    % Plot the boxplots
    observationRate = binMapBinDataArrayUnfiltered{iter} /seconds(simTime);

    max_observer_var(iter+1)=max(observationRate);
    median_observer_var(iter+1)=median(observationRate);
    mean_observer_var(iter+1)=mean(observationRate);
end
plot(avPenRates,max_observer_var,'x')
% plot(1:10, diff(median_observer_var))

% solve(diff(median_observer_var),'MaxDegree',2)

% Set the x-axis labels
% xticks([1:avPenRates);
% xticklabels({'0%','10%', '20%', '30%', '40%', '50%', '60%', '70%', '80%', '90%', '100%'});
% Set the title and labels
title('Boxplot Comparison');
ylabel('Observations/s');
% Release the hold
hold off;


%% evalaute function for median 

%% polyfit solution on median
close all

% Define the data points
% x = linspace(0, 100, binMapCnt+1);   % x-coordinates
x = avPenRates';
y = median_observer_var;    % y-coordinates

% Perform the polynomial curve fit
degree = 6; % Specify the degree of the polynomial
coefficients = polyfit(x, y, degree);

% Generate x values for plotting the fitted curve
xfit = linspace(min(x), max(x), 100);
% coefficients=[0,coefficients(2),coefficients(3)]
yfit = polyval(coefficients, xfit);

% Plot the original data points and the fitted curve
plot(x, y, 'o');        % Plot data points
hold on;
plot(xfit, yfit);       % Plot fitted curve
hold off;

% Display the fitted coefficients
disp(0005);

fitData = [xfit', yfit'];
data = [x', y'];

dlmwrite('fittingDataPoints2.csv', data, 'delimiter', '\t');
dlmwrite('FittedCurve2.csv', fitData, 'delimiter', '\t');

%% polyfit solution on max
close all

% Define the data points
% x = linspace(0, 100, binMapCnt+1);   % x-coordinates
x = avPenRates';
y = max_observer_var;    % y-coordinates

% Perform the polynomial curve fit
degree = 6; % Specify the degree of the polynomial
coefficients = polyfit(x, y, degree);

% Generate x values for plotting the fitted curve
xfit = linspace(min(x), max(x), 100);
% coefficients=[0,coefficients(2),coefficients(3)]
yfit = polyval(coefficients, xfit);

% Plot the original data points and the fitted curve
plot(x, y, 'o');        % Plot data points
hold on;
plot(xfit, yfit);       % Plot fitted curve
hold off;

% Display the fitted coefficients
disp(0005);

fitData = [xfit', yfit'];
data = [x', y'];

dlmwrite('fittingDataPoints2max.csv', data, 'delimiter', '\t');
dlmwrite('FittedCurve2max.csv', fitData, 'delimiter', '\t');





%% get LOS


% divided in 5 aras resulting in target penetration rates
LOS_steps = linspace(0,max_observer_var(end),6);


y_val = LOS_steps(5); % Replace this with your desired y-value

x = find_x_for_y(coefficients, y_val);
disp(x);



