% function analyseSingleBinmap(binMapFolder)
    clear
    close all


    % ======================================================
    % ======================================================
    % ======================================================
    % MAX BIN VALUE IS NOT SET RIGHT NOW!!!
    % ======================================================
    % ======================================================
    % ======================================================


    osmDataName = "osmData/arcis_theresien_crossing.osm.mat";
    bIsStaticOcculsionScenario = true;
    binMapFolder = "Results/";
    MapX = [-190, -100];
    MapY = [-200, -20];


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
        figure('units','normalized','outerposition',[0 0 1 1])
        

    
        binMapName = fileList(dataSize).name
        title("AV penetration rate "+num2str(sscanf(binMapName,'binmap_AV%d'))+"%", 'FontName', 'Times','FontSize',24)
        % load(binMapFolder+binMapName);

        analyseSingleBinmap(binMapFolder+binMapName,osmDataName,MapX,MapY,bIsStaticOcculsionScenario)

        % pause(0.0000001)
        % saveas(gcf,"Results/"+binMapName+".png")
        % saveas(gcf,"Results/"+binMapName+"_01.eps",'epsc')
        % print("Results/"+binMapName+"_02.pdf", '-dpdf', '-r300');
        print("Results/"+binMapName+".eps", '-depsc2');
        close all
    end
% end



