%% RUN manual evaluation of the Static Occlusion Scenario:
clear
addpath("Scripts")
addpath("submodules/matlab-tools")
addpath("submodules/intersections/")

%% Generate osm files

osmFileName = 'osmData/arcis_theresien_crossing.osm';
origin = [48.15071807746543, 11.57141995642991, 10];
LTP_OffsetX = -243.035323045;
LTP_OffsetY = -200.647376497;
bIsStaticOcculsionScenario = true;
readOSM(osmFileName, origin, LTP_OffsetX, LTP_OffsetY,bIsStaticOcculsionScenario);

%% Run data analysis
close all

% Evaluation boundaries
MapX = [-190, -100];
MapY = [-200, -20];

% Simulation parameters
av_percentage = 0.1;
FoV = 30;
visualize = true;
visualizeDebug = true;

% Data Sources
aimsunData = 'aimsunData/staticOcclusionScenario_ShortTest.xml';
osmDataName = "osmData/arcis_theresien_crossing.osm.mat";

% Start analysis
analyseData(av_percentage,FoV,visualize,aimsunData,osmDataName,MapX,MapY,bIsStaticOcculsionScenario, visualizeDebug);

%% Run binmap evaluation

BinMapFileName = "temp/binmap_AV"+num2str(av_percentage*100)+"_FOV"+num2str(FoV)+".mat";
% Create a full-screen figure 
figure('units','normalized','outerposition',[0 0 1 1])
analyseSingleBinmap(BinMapFileName,osmDataName,MapX,MapY,bIsStaticOcculsionScenario,-1);