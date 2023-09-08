function analyseSingleBinmapObservationRate(binMapName,osmDataName,MapX,MapY,bPlotParkedVeh, maxBinValue, occlusionThresholdPercentage, outlierThresholdPercentage,validThreshold,areaOfInterest)
    % Load the binary map and OSM data
    load(binMapName);
    load(osmDataName);

    %setup sim time
    simTime = duration(0,30, 5, 100); % 30 minutes, 5 second, 100 milliseconds



    bEnableCheckDynOcclusionSpots = false;
    
    axis equal
    axis([MapX(1) MapX(2) MapY(1) MapY(2)])
    hold on

    % for single scnearios, -1 given as max bin value to indicate that it
    % must be evaluated here:
    if maxBinValue == -1
        maxBinValue = max(max(binmap));
    end
    
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

    x_size = size(binmap,1);
    y_size = size(binmap,2);
    

    %% 1. get the color of the bin


    cmap2 = colormap(turbo);

    % O-LOS
    LOS_A = 5.1 % 5 obeservations per second
    LOS_B = 4.1 % 5 obeservations per second
    LOS_C = 3.1 % 5 obeservations per second
    LOS_D = 1.8 % 5 obeservations per second


    for xIter = 1:x_size
        for yIter = 1:y_size
            polyBox = getPolyShape(MapX,MapY,xIter,yIter);
            currValue = binmap(xIter,yIter);
            % if it IS empty
            if currValue == 0
                currValue = 1;
                colorCode = 0;
                pg = plot(polyBox,"FaceColor",[1,1,1],"EdgeAlpha",0.0);  
            % if it IS NOT empty

            else    
            
                observationsPerSeconds = currValue/seconds(simTime);
                
                if observationsPerSeconds >= LOS_D && observationsPerSeconds < LOS_C
                    colorCode = ceil(255*.8);
                elseif observationsPerSeconds >= LOS_C && observationsPerSeconds < LOS_B 
                    colorCode = ceil(255*.7);
                elseif observationsPerSeconds >= LOS_B && observationsPerSeconds < LOS_A 
                    colorCode = ceil(255*.6);     
                elseif observationsPerSeconds >= LOS_A 
                    colorCode = ceil(255*.5);   
                else
                    colorCode = ceil(255*0.9); % LOS E
                end

                pg = plot(polyBox,"FaceColor",[cmap2(colorCode,:)],"EdgeAlpha",0.0);   
            end      

            % write count into all bins for debugging
            % [centroid_x, centroid_y] = centroid(polyBox);
            % text(centroid_x, centroid_y, num2str(binmap(xIter,yIter)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle')
                

            % pause(0.0001) 
            % end of single bin evaluation
        end
        % pause(0.0001) 
        % end of column evaluation
    end
    

    %% 2. Check if the adjacent bin is significantly different from 
    % its neigbors
    if bEnableCheckDynOcclusionSpots
        % must be dynamic for different pentration rates:
        dynamicOcclusionTreshold = max(max(binmap))*(occlusionThresholdPercentage/100); % 10 percent of the max value
        % values below this value are not realistic and count as outlier
        outlierThreshold = max(max(binmap))*(outlierThresholdPercentage/100); 
        validThreshold = max(max(binmap))*(validThreshold/100);
        
        bEnableCountInBoxes = false;
    
        x1 = areaOfInterest(1);
        x2 = areaOfInterest(2);
        y1 = areaOfInterest(3);
        y2 = areaOfInterest(4);
        % rectangle('Position', [x1, y1, x2-x1, y2-y1], 'EdgeColor', 'k');
        %x1 x2 y1 y2
        areaOfInterest = areaOfInterest - [MapX(1) MapX(1) MapY(1) MapY(1)];

    
        % for xIter = 1:x_size
        %     for yIter = 1:y_size        
        for xIter = areaOfInterest(1):areaOfInterest(2)
            for yIter = areaOfInterest(3):areaOfInterest(4)   



                % skip borders
                if xIter == 1 || xIter == x_size || yIter == 1 || yIter == y_size
                    %skip
                % if the current bin is not at the binning map border
                else
                    getAdjacentBins(xIter,yIter,MapX,MapY,binmap,dynamicOcclusionTreshold,outlierThreshold,bEnableCountInBoxes,validThreshold);    
                end
                % pause(0.0001) 
                % end of single bin evaluation
            end
            % pause(0.0001) 
            % end of column evaluation
        end
    end


    font_size = 45;

    % Add labels to x and y axis
    xlabel('x position [m]', 'FontName', 'Times','FontSize',font_size)
    ylabel('y position [m]', 'FontName', 'Times','FontSize',font_size)



    %% legend:
    
    lbl =  {'LoV A', 'LoV B', 'LoV C', 'LoV D', 'LoV E'};
    % lbl =  {'LoV C', 'LoV D', 'LoV E'};
    
    
    cmap_legend = [cmap2(ceil(255*.5),:); cmap2(ceil(255*.6),:); cmap2(ceil(255*.7),:); cmap2(ceil(255*.8),:); cmap2(ceil(255*.9),:)]
    % cmap_legend = [cmap2(ceil(255*.7),:); cmap2(ceil(255*.8),:); cmap2(ceil(255*.9),:)]
    
    for ii = 1:size(cmap_legend,1)
        p(ii) = patch(NaN, NaN, cmap_legend(ii,:));
        p(ii).FaceAlpha = 0.5;  % make patches slightly transparent
    end
    
    legend(p, lbl);
 
%%
    % Set the current axes font to Times New Roman
    set(gca, 'FontName', 'Times')
    ax = gca;
    ax.FontSize = font_size;  % Font Size of 15

    %%
    % saveas(gcf,"Results/Figures/AV100LOS.png")

end
