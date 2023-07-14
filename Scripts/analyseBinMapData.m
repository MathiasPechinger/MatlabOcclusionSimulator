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

%% exract data
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
            
            % pause(0.0001) 
            % end of single bin evaluation
        end
        % pause(0.0001) 
        % end of column evaluation
    end
end

%% plot statistics

% figure('units','normalized','outerposition',[0 0 1 1]) % left screen if applicable
figure('units','normalized','outerposition',[0 0 1 1]) % left screen if applicable
plot(1:11, binCntSummary)
font_size = 25;

% Add labels to x and y axis
xlabel('percentage steps', 'FontName', 'Times','FontSize',font_size)
ylabel('Number of observations', 'FontName', 'Times','FontSize',font_size)

% Set the current axes font to Times New Roman
set(gca, 'FontName', 'Times')
ax = gca;
ax.FontSize = font_size;  
grid on

%% fit data
% sf = fit([1:11, binCntSummary],'poly2')


