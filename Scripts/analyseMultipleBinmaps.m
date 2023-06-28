% function analyseSingleBinmap(binMapFolder)
% LEGACY FILE: NOT USED ANYMORE

    binMapFolder = "Results/";
    S = dir(binMapFolder);

    % sort by date
    S = S(~[S.isdir]);
    [~,idx] = sort([S.datenum]);
    S = S(idx)
    fileList = S;

    load("osmData/geotheplatz.osm.mat");
    % Map boundaries
    MapX = [50, 200];
    MapY = [50, 170];
    figure('units','normalized','outerposition',[0 0 1 1])
    maxBinValue = 0;

    binMapCnt = 8;

%     load all binmaps
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

        subplot(2,4,dataSize);
        


    
        binMapName = fileList(dataSize).name
        title("AV penetration rate "+num2str(sscanf(binMapName,'binmap_AV%d'))+"%")
        load(binMapFolder+binMapName);


        axis equal
        axis([MapX(1) MapX(2) MapY(1) MapY(2)])
        hold on
        
        for building = 1:size(osmBuildings,2)
            plot(osmBuildings{building}.x,osmBuildings{building}.y,'k')
        end

        % only used for arcis street analysis
%         for parking = 1:size(osmParking,2)
%             plot(osmParking{parking}.x,osmParking{parking}.y,'k')
%         end
             
        
        % get max value for color normalization
%         maxBinValue = max(max(binmap));
        cmap = colormap(parula);
        
        for xIter = 1:size(binmap,1)
            for yIter = 1:size(binmap,2)
                
                boxPointX = zeros(1,4);
                boxPointY = zeros(1,4);
                % start at bottom left
                boxPointX(1) = [MapX(1)+xIter];
                boxPointX(2) = [MapX(1)+xIter];
                boxPointX(3) = [MapX(1)+xIter+1];
                boxPointX(4) = [MapX(1)+xIter+1];
        %         boxPointX(5) = [MapX(1)+xIter];
        
                boxPointY(1) = [MapY(1)+yIter];
                boxPointY(2) = [MapY(1)+yIter+1];
                boxPointY(3) = [MapY(1)+yIter+1];
                boxPointY(4) = [MapY(1)+yIter];
        %         boxPointY(5) = [MapY(1)+yIter];
        
                polyBox = polyshape(boxPointX,boxPointY);    
                
                currValue = binmap(xIter,yIter);
                if currValue == 0
                    currValue = 1;
                end        
                colorCode = ceil((currValue/maxBinValue)*255);  
        
                plot(polyBox,"FaceColor",[cmap(colorCode,:)],"EdgeAlpha",0.0);   
                
        
            end
            pause(0.0000001)
        end
        
        axis([MapX(1) MapX(2) MapY(1) MapY(2)])
%         axis equal
        
        
    end
% end


saveas(gcf,"results.png")
