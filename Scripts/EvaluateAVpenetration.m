%% Usage:
% define the penetration rate and choose the aimsun Data File you want to
% check
AVpentrationrate = 0.5;

usePlot = false;

%% add path
% clear
addpath("Scripts/")
addpath("submodules/matlab-tools/")

%% Evaluate

initialFolder = 'aimsunData';
[filename, filepath] = uigetfile(fullfile(initialFolder, '*.xml'), 'Select .xml File');
aimsunDataName = fullfile(filepath, filename);


fprintf('Parsing XML Data... \n');

% parse data names and load
aimsunData = xml2struct(aimsunDataName);


%% Evaluation boundaries 
[ts_AVPenetrationRate, ts_CarCount] = getAVpentrationRate(AVpentrationrate, usePlot,aimsunData);

%% plot the results


% Specify the figure size in pixels
figureWidth = 1200;
figureHeight = 400;

% Create the figure
fig = figure('Position', [100, 100, figureWidth, figureHeight]);

% Plot the time series
plot(ts_AVPenetrationRate.Time/60, ts_AVPenetrationRate.Data,'LineWidth', 1.5, 'MarkerSize', 1, 'LineStyle','-')

grid on;
grid minor
box on;

% Set plot labels and title
xlabel('Time [minutes]', 'FontName', 'Times','FontSize',15)
ylabel('AV Penetration Rate [%]', 'FontName', 'Times','FontSize',15)

% Set the current axes font to Times New Roman
set(gca, 'FontName', 'Times')
ax = gca;
ax.FontSize = 15;  % Font Size of 15

% Set x and y limits
xlim([0, max(ts_AVPenetrationRate.Time)/60])
ylim([28, 35])


% Adjust plot appearance
ax2 = gca;
ax2.FontSize = 20;
ax2.YColor = 'k'; % Set color for the right y-axis labels

print("Results/Figures/penetration_plot.eps", '-depsc2');

