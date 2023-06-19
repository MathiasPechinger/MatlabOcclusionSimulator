%% add path
clear
addpath("Scripts/")
addpath("submodules/matlab-tools/")

%% Evaluate

initialFolder = 'Results';
[filename, filepath] = uigetfile(fullfile(initialFolder, '*.mat'), 'Select .mat File');
BinMapFileName = fullfile(filepath, filename);


%% Evaluation boundaries 
bIsStaticOcculsionScenario = true; % for parked vehicles/static scenario


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


% Create a full-screen figure 
figure('units','normalized','outerposition',[0 0 1 1])
analyseSingleBinmap(BinMapFileName,osmDataName,MapX,MapY,bIsStaticOcculsionScenario);