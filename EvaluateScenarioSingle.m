%% add path
clear
addpath("Scripts/")
addpath("submodules/matlab-tools/")

%% Evaluate

initialFolder = 'Results';
[filename, filepath] = uigetfile(fullfile(initialFolder, '*.mat'), 'Select .mat File');
BinMapFileName = fullfile(filepath, filename);


% Evaluation boundaries
MapX = [-190, -100];
MapY = [-200, -20];

% osm Data Source
osmDataName = "osmData/arcis_theresien_crossing.osm.mat";
bIsStaticOcculsionScenario = true; % for parked vehicles

% BinMapFileName = "Results/binmap_AV.mat";
analyseSingleBinmap(BinMapFileName,osmDataName,MapX,MapY,bIsStaticOcculsionScenario);