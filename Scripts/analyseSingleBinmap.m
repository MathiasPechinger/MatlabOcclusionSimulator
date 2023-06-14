function analyseSingleBinmap(binMapName,osmDataName,MapX,MapY,bPlotParkedVeh)
% analyseSingleBinmapHeatspots: Analyzes a given binary map and open street map (OSM) data and visualizes the heatmap.
%
% This function loads the input binary map and OSM data, plots the buildings from OSM data on the same coordinates 
% as the binary map, and uses colors to represent the binary map's values as a heatmap.
% Each pixel of the binary map corresponds to a rectangular area on the plotted map. The colors of these areas 
% range from white (if the binary map's value at that pixel is zero) to the color corresponding to the maximum 
% value on the colormap parula (if the value is non-zero).
%
% Usage:
%   analyseSingleBinmapHeatspots(binMapName,osmDataName,MapX,MapY)
%
% Input:
%   binMapName: A string that specifies the name of the .mat file containing the binary map data.
%   osmDataName: A string that specifies the name of the .mat file containing the OSM data.
%   MapX: A two-element vector [Xmin Xmax] that defines the x-axis limits of the map.
%   MapY: A two-element vector [Ymin Ymax] that defines the y-axis limits of the map.
%
% Notes:
%   The binary map data should be in the form of a 2D matrix stored in the 'binmap' variable in the .mat file.
%   The OSM data should include building information stored in the 'osmBuildings' variable in the .mat file.
%
%   This function creates a full-screen figure and uses the parula colormap to visualize the data.
%   The heatmap visualization uses normalization for color mapping. The delay between plotting each 
%   pixel can be adjusted by changing the pause time.
%
%   In the OSM data, each building is represented as a structure with x and y coordinates.
%
%   It should be noted that a value of zero in the binary map is displayed as white, and the colors for 
%   other values are scaled according to the maximum value in the binary map.

    load(binMapName);
    load(osmDataName);
       
    figure('units','normalized','outerposition',[0 0 1 1])
    axis equal
    axis([MapX(1) MapX(2) MapY(1) MapY(2)])
    hold on
    
    for building = 1:size(osmBuildings,2)
        plot(osmBuildings{building}.x,osmBuildings{building}.y,'k')
    end

    if (bPlotParkedVeh)
    % only for static occlusion scenario
        for parking = 1:size(osmParking,2)
            plot(osmParking{parking}.x,osmParking{parking}.y,'k')
        end
    end

    hold on

    % get max value for color normalization
    maxBinValue = max(max(binmap));
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
                % colorCode = ceil((1-(currValue/maxBinValue))*255) ;
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
end

