function analyseSingleBinmap(binMapName,osmDataName,MapX,MapY,bPlotParkedVeh, maxBinValue)
    % Load the binary map and OSM data
    load(binMapName);
    load(osmDataName);
    
    axis equal
    axis([MapX(1) MapX(2) MapY(1) MapY(2)])
    hold on
    
    % Plot buildings from the OSM data
    for building = 1:size(osmBuildings,2)
        plot(osmBuildings{building}.x,osmBuildings{building}.y,'k')
    end

    if (bPlotParkedVeh)
        for parking = 1:size(osmParking,2)
            plot(osmParking{parking}.x,osmParking{parking}.y,'k')
        end
    end

    hold on


    cmap = colormap(parula);
    
    for xIter = 1:size(binmap,1)
        for yIter = 1:size(binmap,2)
            
            boxPointX = zeros(1,4);
            boxPointY = zeros(1,4);

            % Start at bottom left
            boxPointX(1) = [MapX(1)+xIter];
            boxPointX(2) = [MapX(1)+xIter];
            boxPointX(3) = [MapX(1)+xIter+1];
            boxPointX(4) = [MapX(1)+xIter+1];
    
            boxPointY(1) = [MapY(1)+yIter];
            boxPointY(2) = [MapY(1)+yIter+1];
            boxPointY(3) = [MapY(1)+yIter+1];
            boxPointY(4) = [MapY(1)+yIter];
    
            polyBox = polyshape(boxPointX,boxPointY);    
            
            currValue = binmap(xIter,yIter);

            % if it IS empty
            if currValue == 0
                currValue = 1;
                colorCode = 0;
                pg = plot(polyBox,"FaceColor",[1,1,1],"EdgeAlpha",0.0);  

            % if it IS NOT empty
            else              
                colorCode = ceil(((currValue/maxBinValue))*255) ;
    
                % avoid invalid 0
                if colorCode == 0
                    colorCode = 1;
                end
                pg = plot(polyBox,"FaceColor",[cmap(colorCode,:)],"EdgeAlpha",0.0);   
            end      
        end
        pause(0.0001) 
    end
    
    % Add labels to x and y axis
    xlabel('x position [m]', 'FontName', 'Times','FontSize',24)
    ylabel('y position [m]', 'FontName', 'Times','FontSize',24)

    % Set the current axes font to Times New Roman
    set(gca, 'FontName', 'Times')
    ax = gca;
    ax.FontSize = 22;  % Font Size of 15
end
