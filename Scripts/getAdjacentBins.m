function [] = getAdjacentBins(xIter,yIter,MapX,MapY,binmap,threshold,outlierThreshold,bEnableCountInBoxes,validThreshold)
    % left bin
    xIterTemp = xIter-1;
    yIterTemp = yIter;

    diffVector = [binmap(xIterTemp,yIterTemp),binmap(xIter,yIter)];
    difference = diff(diffVector);
    % check for occlusion threshold and mark if applicable and skip zeros
    % additionally we check for outliers at static occlusion borders
    if difference>threshold ...
            && binmap(xIterTemp,yIterTemp) ~= 0 ...
            && binmap(xIterTemp,yIterTemp) > outlierThreshold ...
            && binmap(xIter,yIter) > validThreshold

        polyBox = getPolyShape(MapX,MapY,xIter,yIter);
        pg = plot(polyBox,"FaceAlpha",0,"EdgeAlpha",1);
        [centroid_x, centroid_y] = centroid(polyBox);
        if bEnableCountInBoxes
            text(centroid_x, centroid_y, num2str(binmap(xIter,yIter)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle',FontSize=20)
        end
        polyBox = getPolyShape(MapX,MapY,xIterTemp,yIterTemp);
        pg = plot(polyBox,"FaceAlpha",0,"EdgeAlpha",1);
        [centroid_x, centroid_y] = centroid(polyBox);
        if bEnableCountInBoxes
            text(centroid_x, centroid_y, num2str(binmap(xIterTemp,yIterTemp)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle',Color=[0.6350 0.0780 0.1840],FontSize=20)
        end
    end      

    % top bin
    xIterTemp = xIter;
    yIterTemp = yIter+1;
    diffVector = [binmap(xIterTemp,yIterTemp),binmap(xIter,yIter)];
    difference = diff(diffVector);
    % check for occlusion threshold and mark if applicable
    if difference>threshold ...
            && binmap(xIterTemp,yIterTemp) ~= 0 ...
            && binmap(xIterTemp,yIterTemp) > outlierThreshold ...
            && binmap(xIter,yIter) > validThreshold
        polyBox = getPolyShape(MapX,MapY,xIter,yIter);
        pg = plot(polyBox,"FaceAlpha",0,"EdgeAlpha",1);
        [centroid_x, centroid_y] = centroid(polyBox);
        if bEnableCountInBoxes
            text(centroid_x, centroid_y, num2str(binmap(xIter,yIter)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle',FontSize=20)
        end
        polyBox = getPolyShape(MapX,MapY,xIterTemp,yIterTemp);
        pg = plot(polyBox,"FaceAlpha",0,"EdgeAlpha",1);
        [centroid_x, centroid_y] = centroid(polyBox);
        if bEnableCountInBoxes
            text(centroid_x, centroid_y, num2str(binmap(xIterTemp,yIterTemp)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle',Color=[0.6350 0.0780 0.1840],FontSize=20)
        end
    end
    
    % right bin
    xIterTemp = xIter+1;
    yIterTemp = yIter;
    diffVector = [binmap(xIterTemp,yIterTemp),binmap(xIter,yIter)];
    difference = diff(diffVector);
    % check for occlusion threshold and mark if applicable
    if difference>threshold ...
            && binmap(xIterTemp,yIterTemp) ~= 0 ...
            && binmap(xIterTemp,yIterTemp) > outlierThreshold ...
            && binmap(xIter,yIter) > validThreshold
        polyBox = getPolyShape(MapX,MapY,xIter,yIter);
        pg = plot(polyBox,"FaceAlpha",0,"EdgeAlpha",1);
        [centroid_x, centroid_y] = centroid(polyBox);
        if bEnableCountInBoxes
            text(centroid_x, centroid_y, num2str(binmap(xIter,yIter)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle',FontSize=20)
        end
        polyBox = getPolyShape(MapX,MapY,xIterTemp,yIterTemp);
        pg = plot(polyBox,"FaceAlpha",0,"EdgeAlpha",1);
        [centroid_x, centroid_y] = centroid(polyBox);
        if bEnableCountInBoxes
            text(centroid_x, centroid_y, num2str(binmap(xIterTemp,yIterTemp)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle',Color=[0.6350 0.0780 0.1840],FontSize=20)
        end
    end

    % bottom bin
    xIterTemp = xIter;
    yIterTemp = yIter-1;
    diffVector = [binmap(xIterTemp,yIterTemp),binmap(xIter,yIter)];
    difference = diff(diffVector);
    % check for occlusion threshold and mark if applicable
    if difference>threshold ...
            && binmap(xIterTemp,yIterTemp) ~= 0 ...
            && binmap(xIterTemp,yIterTemp) > outlierThreshold ...
            && binmap(xIter,yIter) > validThreshold
        polyBox = getPolyShape(MapX,MapY,xIter,yIter);
        pg = plot(polyBox,"FaceAlpha",0,"EdgeAlpha",1);
        [centroid_x, centroid_y] = centroid(polyBox);
        if bEnableCountInBoxes
            text(centroid_x, centroid_y, num2str(binmap(xIter,yIter)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle',FontSize=20)
        end
        polyBox = getPolyShape(MapX,MapY,xIterTemp,yIterTemp);
        pg = plot(polyBox,"FaceAlpha",0,"EdgeAlpha",1);
        [centroid_x, centroid_y] = centroid(polyBox);
        if bEnableCountInBoxes
            text(centroid_x, centroid_y, num2str(binmap(xIterTemp,yIterTemp)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle',Color=[0.6350 0.0780 0.1840],FontSize=20)
        end
    end
        

end

