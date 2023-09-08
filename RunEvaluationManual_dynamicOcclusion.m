%% RUN manual evaluation of the dynamic occlusion Scenario:
clear
addpath("Scripts")
addpath("submodules/matlab-tools")
addpath("submodules/intersections/")

%% Generate osm files

osmFileName = 'osmData/geotheplatz.osm';
origin = [48.12864, 11.55673, 10];
LTP_OffsetX = 0;
LTP_OffsetY =0;
bIsStaticOcculsionScenario = false; % for parked vehicles

readOSM(osmFileName, origin, LTP_OffsetX, LTP_OffsetY,bIsStaticOcculsionScenario);

%% Run data analysis
close all

% Evaluation boundaries
MapX = [50, 200];
MapY = [50, 170];
% Simulation parameters
av_percentage = 0.1;
FoV = 30;
visualize = true;
visualizeDebug = false;

% Data Sources
aimsunData = 'aimsunData/dynamicOcclusionScenario_ShortTest.xml';
osmDataName = "osmData/geotheplatz.osm.mat";

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


% Start analysis
analyseData(av_percentage,FoV,visualize,aimsunData,osmDataName,MapX,MapY,bIsStaticOcculsionScenario, visualizeDebug)

%% Run binmap evaluation

BinMapFileName = "temp/binmap_AV"+num2str(av_percentage*100)+"_FOV"+num2str(FoV)+".mat";
% Create a full-screen figure 
figure('units','normalized','outerposition',[0 0 1 1])
analyseSingleBinmap(BinMapFileName,osmDataName,MapX,MapY,bIsStaticOcculsionScenario,-1);
figure('units','normalized','outerposition',[0 0 1 1])
analyseSingleBinmapObservationRate(BinMapFileName,osmDataName,MapX,MapY,bIsStaticOcculsionScenario,-1,occlusionThresholdPercentage, outlierThresholdPercentage,validThreshold);



