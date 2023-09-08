%% add path
clear
addpath("Scripts/")
addpath("submodules/matlab-tools/")
addpath("osmData/")

%% Note: 
% Make sure to setup the correct falg for the dynamic and static scenario
% respectively
bIsStaticOcculsionScenario = false; % for parked vehicles/static scenario

%% Evaluate

initialFolder = 'Results';
[filename, filepath] = uigetfile(fullfile(initialFolder, '*.mat'), 'Select .mat File');
BinMapFileName = fullfile(filepath, filename);


%% Evaluation boundaries 

if bIsStaticOcculsionScenario
    % arcis_theresienstraße/static sceanrio
    MapX = [-190, -100];
    MapY = [-200, -20];

    % osm Data Source
    osmDataName = "osmData/arcis_theresien_crossing.osm.mat";

else
    % goetheplatz/dynamic scenario
    MapX = [50, 200];
    MapY = [50, 170];


    % osm Data Source
    osmDataName = "osmData/geotheplatz.osm.mat";

end

% -=Filter main bin=-
% only bins that have at least 50 percent of the maximum value are valid to
% be considered. We check the bin that is currenly in the center and being
% checked against its adjacent bins
validThreshold = 0;

% -=Filter adjacent bin=-
% Here we check the bin that is adjacent to the one that is being checked
% the percentage measured to the maximum bin value to be counted as
% occlusion. We consider an area that must have a very high visibility to
% achieve a suitable difference. If the bin value is at least at this
% percenatage compared to the maxium bin value we consider it.
outlierThresholdPercentage = 0;

% -= Bin difference=-
% the difference threshold as percentage value measured to the maximum bin
% value of the binning map. if the difference between two bins is at least
% this percentage it is considered as occlusion spot
% Greater value means less spots
occlusionThresholdPercentage = 8;

areaOfInterest = [105, 135, 100, 130]; %x1 x2 y1 y2
%%
% Create a full-screen figure 
figure('units','normalized','outerposition',[0 0 1 1])
analyseSingleBinmap(BinMapFileName,osmDataName,MapX,MapY,bIsStaticOcculsionScenario,-1,occlusionThresholdPercentage, outlierThresholdPercentage,validThreshold,areaOfInterest);
figure('units','normalized','outerposition',[0 0 1 1])
analyseSingleBinmapObservationRate(BinMapFileName,osmDataName,MapX,MapY,bIsStaticOcculsionScenario,-1,occlusionThresholdPercentage, outlierThresholdPercentage,validThreshold,areaOfInterest);

% saveas(gcf,"Results/Figures/100res.png")
% saveas(gcf,"Results/"+binMapName+"_01.eps",'epsc')
% print("Results/"+binMapName+"_02.pdf", '-dpdf', '-r300');
% print("Results/Figures/100res.eps", '-depsc2');