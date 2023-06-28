%% RUN manual evaluation of the dynamic occlusion Scenario:
clear
addpath("Scripts")
addpath("submodules/matlab-tools")

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
av_percentage = 0.01;
FoV = 30;
visualize = true;
visualizeDebug = false;

% Data Sources
aimsunData = 'aimsunData/dynamicOcclusionScenario_ShortTest.xml';
osmDataName = "osmData/geotheplatz.osm.mat";

% Start analysis
analyseData(av_percentage,FoV,visualize,aimsunData,osmDataName,MapX,MapY,bIsStaticOcculsionScenario, visualizeDebug)

%% Run binmap evaluation

BinMapFileName = "Results/binmap_AV30_FOV30.mat"
% Create a full-screen figure 
figure('units','normalized','outerposition',[0 0 1 1])
analyseSingleBinmap(BinMapFileName,osmDataName,MapX,MapY,bIsStaticOcculsionScenario,-1);
