%% Evaluate in Parallel

clear
close all
addpath("Scripts")
addpath("submodules/matlab-tools")
addpath("submodules/intersections")

%% Generate osm files

osmFileName = 'osmData/geotheplatz.osm';
origin = [48.12864, 11.55673, 10];
LTP_OffsetX = 0;
LTP_OffsetY =0;
bIsStaticOcculsionScenario = false; % for parked vehicles
readOSM(osmFileName, origin, LTP_OffsetX, LTP_OffsetY,bIsStaticOcculsionScenario);

%% setup jobs
c = parcluster; %or maybe c = findResource('scheduler','Configuration','local');
job = createJob(c); 


% f = parfeval(job,@analyseData,0,0.1,30,false);

%% setup tasks

% TASK 1:
% Evaluation boundaries
MapX = [50, 200];
MapY = [50, 170];
% Simulation parameters
FoV = 30;
visualize = false;
visualizeDebug = false;
% Data Sources
% aimsunData = 'aimsunData/staticOcclusionScenario_ShortTest.xml';
aimsunData = 'aimsunData/dynamicOcclusionScenario.xml';
osmDataName = "osmData/geotheplatz.osm.mat";

% Start analysis
% 
av_percentage = 1.0;
createTask(job,@analyseData,0,{av_percentage,FoV,visualize,aimsunData,osmDataName,MapX,MapY,bIsStaticOcculsionScenario, visualizeDebug})
av_percentage = 0.9;
createTask(job,@analyseData,0,{av_percentage,FoV,visualize,aimsunData,osmDataName,MapX,MapY,bIsStaticOcculsionScenario, visualizeDebug})
av_percentage = 0.8;
createTask(job,@analyseData,0,{av_percentage,FoV,visualize,aimsunData,osmDataName,MapX,MapY,bIsStaticOcculsionScenario, visualizeDebug})
av_percentage = 0.7;
createTask(job,@analyseData,0,{av_percentage,FoV,visualize,aimsunData,osmDataName,MapX,MapY,bIsStaticOcculsionScenario, visualizeDebug})
av_percentage = 0.6;
createTask(job,@analyseData,0,{av_percentage,FoV,visualize,aimsunData,osmDataName,MapX,MapY,bIsStaticOcculsionScenario, visualizeDebug})
av_percentage = 0.5;
createTask(job,@analyseData,0,{av_percentage,FoV,visualize,aimsunData,osmDataName,MapX,MapY,bIsStaticOcculsionScenario, visualizeDebug})
av_percentage = 0.4;
createTask(job,@analyseData,0,{av_percentage,FoV,visualize,aimsunData,osmDataName,MapX,MapY,bIsStaticOcculsionScenario, visualizeDebug})
av_percentage = 0.3;
createTask(job,@analyseData,0,{av_percentage,FoV,visualize,aimsunData,osmDataName,MapX,MapY,bIsStaticOcculsionScenario, visualizeDebug})
av_percentage = 0.2;
createTask(job,@analyseData,0,{av_percentage,FoV,visualize,aimsunData,osmDataName,MapX,MapY,bIsStaticOcculsionScenario, visualizeDebug})
av_percentage = 0.1;
createTask(job,@analyseData,0,{av_percentage,FoV,visualize,aimsunData,osmDataName,MapX,MapY,bIsStaticOcculsionScenario, visualizeDebug})



submit(job)
% wait(job)

