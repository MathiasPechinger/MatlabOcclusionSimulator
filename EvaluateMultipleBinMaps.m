

bIsStaticOcculsionScenario = false;
bVisualizeColorBar = false;
binMapFolder = "Results/";

if bIsStaticOcculsionScenario

    osmDataName = "osmData/arcis_theresien_crossing.osm.mat";
    MapX = [-190, -100];
    MapY = [-200, -20];

else
    osmDataName = "osmData/geotheplatz.osm.mat";
    MapX = [50, 200];
    MapY = [50, 170];

end


% Get a list of all files in the folder
fileList = dir(fullfile(binMapFolder, '*.mat'));

maxBinValue = 0; 
binMapCnt = size(fileList,1);

% load all binmaps
for dataSize=1:binMapCnt
    binMapName = fileList(dataSize).name
    load(binMapFolder+binMapName);
    max(max(binmap))
    if maxBinValue < max(max(binmap))
        maxBinValue = max(max(binmap))
    end
end

% plot data
for dataSize=1:binMapCnt

    % subplot(2,4,dataSize);

    % Create a full-screen figure 
    figure('units','normalized','outerposition',[1 1 1 1]) %right screen
    % figure('units','normalized','outerposition',[0 0 1 1]) % left screen
    


    binMapName = fileList(dataSize).name
    title("AV penetration rate "+num2str(sscanf(binMapName,'binmap_AV%d'))+"%", 'FontName', 'Times','FontSize',24)
    % load(binMapFolder+binMapName);

    analyseSingleBinmap(binMapFolder+binMapName,osmDataName,MapX,MapY,bIsStaticOcculsionScenario, maxBinValue)

    if bVisualizeColorBar
        cmap = colormap(parula);
        cbh = colorbar ; %Create Colorbar
        cbh.Ticks = linspace(0, 1, 20) ; %Create 8 ticks from zero to 1
        cbh.TickLength = 0;
        pos = cbh.Position;
        pos(1) = .8;
        pos(3) = .02;
        cbh.Position = pos;
        myCellArray = cell(1, 20)';
        myCellArray{3} = 'minimum';
        myCellArray{2} = 'number of';
        myCellArray{1} = 'observations';
        myCellArray{end} = 'maximum';
        myCellArray{end-1} = 'number of';
        myCellArray{end-2} = 'observations';
    
    
        cbh.TickLabels = myCellArray;    %Replace the labels of these 8 ticks with the numbers 1 to 8
    end
    % pause(0.0000001)
    % saveas(gcf,"Results/"+binMapName+".png")
    % saveas(gcf,"Results/"+binMapName+"_01.eps",'epsc')
    % print("Results/"+binMapName+"_02.pdf", '-dpdf', '-r300');
    print("Results/Figures/"+binMapName+".eps", '-depsc2');
    close all
end
% end



