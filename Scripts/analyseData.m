function [] = analyseData(AVpercentage, FOVrange, usePlot,aimsunDataName,osmDataName,MapX,MapY,bPlotParkedVeh,bVisualizeDebug)


% user either polyxpoly oder intersections algorithm for ray tracing.
% -> intersections is a lot faster
bUsePolyXPoly = false;

% Intersections algorithm settings
bRobustIntersections = false;

%% parse data names and load
aimsunData = xml2struct(aimsunDataName);
load(osmDataName);

% setup timeseries for av penetration rate tracking
ts_AVPenetrationRate = timeseries();

%% static data

% get type id of cars
CarTypeID = -1;
if size(aimsunData.AIMSUN_ANIMATION.STATIC.VEHICLE_TYPES.VEHICLE_TYPE,2) == 1
    for iter = 1:size(aimsunData.AIMSUN_ANIMATION.STATIC.VEHICLE_TYPES.VEHICLE_TYPE,2)
        if aimsunData.AIMSUN_ANIMATION.STATIC.VEHICLE_TYPES.VEHICLE_TYPE.NAME.Text == "Car"
            CarTypeID = aimsunData.AIMSUN_ANIMATION.STATIC.VEHICLE_TYPES.VEHICLE_TYPE.Attributes.ID;
        end
    end
else
    for iter = 1:size(aimsunData.AIMSUN_ANIMATION.STATIC.VEHICLE_TYPES.VEHICLE_TYPE,2)
        if aimsunData.AIMSUN_ANIMATION.STATIC.VEHICLE_TYPES.VEHICLE_TYPE{iter}.NAME.Text == "Car"
            CarTypeID = aimsunData.AIMSUN_ANIMATION.STATIC.VEHICLE_TYPES.VEHICLE_TYPE{iter}.Attributes.ID;
        end
    end
end


%%

% ----------------------------
% ------ create bin map ------
% ----------------------------

% setup bin data matrice
xSize = diff(MapX);
ySize = diff(MapY);
binmap = zeros(xSize,ySize);



% ----------------------------
% ------ run simulation ------
% ----------------------------


aimsunDynamicData = aimsunData.AIMSUN_ANIMATION.DYNAMIC;
CarCnt = 1;
AVCnt = 0;
clear vehicle;

if usePlot
    figure('units','normalized','outerposition',[0 0 1 1])
end

% iterate through all time frames
for frame = 1:size(aimsunDynamicData.FRAME,2)

    % ----------------------------
    % ------ Get new data --------
    % ----------------------------

    currentFrame = aimsunDynamicData.FRAME{frame};
    % check if new vehicle was created
    try
        % either one was created
        if size(currentFrame.CREATED.VEH,2) == 1
            %check if it is a car
            if currentFrame.CREATED.VEH.TYPE.Text == CarTypeID
                
                % add AV if applicable
                currentManualDrivenCarCnt = CarCnt-AVCnt;
                if (AVCnt/currentManualDrivenCarCnt < AVpercentage)
                    vehicle{CarCnt}.isAV = true;
                    AVCnt = AVCnt+1;
                else
                    vehicle{CarCnt}.isAV = false;
                end
                
                vehicle{CarCnt}.ID = currentFrame.CREATED.VEH.Attributes.ID;
                vehicle{CarCnt}.POS = currentFrame.CREATED.VEH.POS.Attributes;
                vehicle{CarCnt}.PATH.POS(1) =  currentFrame.CREATED.VEH.POS.Attributes;
                
                % bounding box
                vehicle{CarCnt}.WIDTH = str2num(currentFrame.CREATED.VEH.WIDTH.Text);
                vehicle{CarCnt}.LENGTH = str2num(currentFrame.CREATED.VEH.SHAPE2D.Attributes.length);
                angle = getAngleFromXY(vehicle{CarCnt}.POS);                
                [boxX,boxY] = getBoundings( ...
                    str2num(vehicle{CarCnt}.POS.X1), ...
                    str2num(vehicle{CarCnt}.POS.Y1), ...
                    angle, ...
                    vehicle{CarCnt}.LENGTH, ...
                    vehicle{CarCnt}.WIDTH);
                vehicle{CarCnt}.box.x = boxX;
                vehicle{CarCnt}.box.y = boxY;

                CarCnt = CarCnt+1;
            end
        % or several vehicles were created
        else
            for carIter = 1:size(currentFrame.CREATED.VEH,2)
                if currentFrame.CREATED.VEH{carIter}.TYPE.Text == CarTypeID

                    % add AV if applicable
                    currentManualDrivenCarCnt = CarCnt-AVCnt;
                    if (AVCnt/currentManualDrivenCarCnt < AVpercentage)
                        vehicle{CarCnt}.isAV = true;
                        AVCnt = AVCnt+1;
                    else
                        vehicle{CarCnt}.isAV = false;
                    end

                    vehicle{CarCnt}.ID = currentFrame.CREATED.VEH{carIter}.Attributes.ID;
                    vehicle{CarCnt}.POS = currentFrame.CREATED.VEH{carIter}.POS.Attributes;
                    vehicle{CarCnt}.PATH.POS(1) = currentFrame.CREATED.VEH{carIter}.POS.Attributes;
    
                    % bounding box
                    vehicle{CarCnt}.WIDTH = str2num(currentFrame.CREATED.VEH{carIter}.WIDTH.Text);
                    vehicle{CarCnt}.LENGTH = str2num(currentFrame.CREATED.VEH{carIter}.SHAPE2D.Attributes.length);
                    angle = getAngleFromXY(vehicle{CarCnt}.POS);              
                    [boxX,boxY] = getBoundings( ...
                        str2num(vehicle{CarCnt}.POS.X1), ...
                        str2num(vehicle{CarCnt}.POS.Y1), ...
                        angle, ...
                        vehicle{CarCnt}.LENGTH, ...
                        vehicle{CarCnt}.WIDTH);
                    vehicle{CarCnt}.box.x = boxX;
                    vehicle{CarCnt}.box.y = boxY;

                    CarCnt = CarCnt+1;
                end
            end
        end
    end


    % check if a single vehicle has moved
    try
        %either one vehicle has changed its position
        if size(currentFrame.CHANGED.VEH,2) == 1
            % check which vehicle has changed
            for vehicleCnt = 1:size(vehicle,2)
                if strcmp(vehicle{vehicleCnt}.ID, '-1')
                    continue;
                end
                if vehicle{vehicleCnt}.ID == currentFrame.CHANGED.VEH.Attributes.ID
                    vehicle{vehicleCnt}.POS = currentFrame.CHANGED.VEH.POS.Attributes;
                    % Changed position of this vehicle
                    currPathLenth = size(vehicle{vehicleCnt}.PATH.POS,2);
                    vehicle{vehicleCnt}.PATH.POS(currPathLenth+1) = currentFrame.CHANGED.VEH.POS.Attributes;

                    % bounding box
                    angle = getAngleFromXY(vehicle{vehicleCnt}.POS);                
                    [boxX,boxY] = getBoundings( ...
                        str2num(vehicle{vehicleCnt}.POS.X1), ...
                        str2num(vehicle{vehicleCnt}.POS.Y1), ...
                        angle, ...
                        vehicle{vehicleCnt}.LENGTH, ...
                        vehicle{vehicleCnt}.WIDTH);
                    vehicle{CarCnt}.box.x = boxX;
                    vehicle{CarCnt}.box.y = boxY;

                end
            end
        % or several vehicles have changed their position
        else
            % iterate over all changed vehicles
            for changedIter = 1:size(currentFrame.CHANGED.VEH,2)
                %check which vehicle has changed
                for vehicleCnt = 1:size(vehicle,2)
                    if strcmp(vehicle{vehicleCnt}.ID, '-1')
                        continue;
                    end
                    if vehicle{vehicleCnt}.ID == currentFrame.CHANGED.VEH{changedIter}.Attributes.ID
                        vehicle{vehicleCnt}.POS = currentFrame.CHANGED.VEH{changedIter}.POS.Attributes;
                        % Changed position of this vehicle
                        currPathLenth = size(vehicle{vehicleCnt}.PATH.POS,2);
                        vehicle{vehicleCnt}.PATH.POS(currPathLenth+1) = vehicle{vehicleCnt}.POS;

                        % bounding box                    
                        angle = getAngleFromXY(vehicle{vehicleCnt}.POS);            
                        [boxX,boxY] = getBoundings( ...
                            str2num(vehicle{vehicleCnt}.POS.X1), ...
                            str2num(vehicle{vehicleCnt}.POS.Y1), ...
                            angle, ...
                            vehicle{vehicleCnt}.LENGTH, ...
                            vehicle{vehicleCnt}.WIDTH);
                        vehicle{vehicleCnt}.box.x = boxX;
                        vehicle{vehicleCnt}.box.y = boxY;

                    end
                end
            end
        end
    end

    % check if a vehicle has left the scene
    try 
        % either one vehicle has left the scene
        if size(currentFrame.DELETED.VEH,2) == 1
            % check which vehicle was removed
            for vehicleCnt = 1:size(vehicle,2)
                if strcmp(vehicle{vehicleCnt}.ID, currentFrame.DELETED.VEH.Attributes.ID)
                    vehicle{vehicleCnt}.ID = '-1';
                end
            end
        % or several vehicles have 
        else
            % iterate over all changed vehicles
            for changedIter = 1:size(currentFrame.DELETED.VEH,2)
                % check which vehicle was removed
                for vehicleCnt = 1:size(vehicle,2)
                    if strcmp(vehicle{vehicleCnt}.ID, currentFrame.DELETED.VEH{changedIter}.Attributes.ID)
                        vehicle{vehicleCnt}.ID = '-1';
                    end
                end
            end
        end
    end


    % ----------------------------
    % ------ Plot data -----------
    % ----------------------------
    if usePlot
        clf;
        hold on
        axis equal
    end    

    try
        clear occludingBuilding;
        % plot buildings from osm
        if (usePlot)
            for building = 1:size(osmBuildings,2)
                plot(osmBuildings{building}.x,osmBuildings{building}.y,'k')
            end
            if (bPlotParkedVeh)
                % only for static occlusion scenario
                for parking = 1:size(osmParking,2)
                    plot(osmParking{parking}.x,osmParking{parking}.y,'k')
                end
            end
        end
    


        % occlusion calc
        clear occludingVehicle;
        occVehicleCnt = 1;

        % look at all vehicles
        for vehicle_n = 1:size(vehicle,2)
            if strcmp(vehicle{vehicle_n}.ID, '-1')
                continue;
            end

            if (bVisualizeDebug)
            % plot mid point of vehicle
                plot(str2num(vehicle{vehicle_n}.POS.X1),str2num(vehicle{vehicle_n}.POS.Y1),'xk');
            end

            % check if this vehicle is an AV
            if vehicle{vehicle_n}.isAV
                if strcmp(vehicle{vehicle_n}.ID, '-1')
                    continue;
                end
                % plot shape of vehicle
                if usePlot
                    plot(vehicle{vehicle_n}.box.x,vehicle{vehicle_n}.box.y,'r');
                end
                % create sensors polygon (circle)
                r=FOVrange;
                sensorRayCount = 200;
                FoVHull = zeros(sensorRayCount,2);
                ego_x_RayPoints = zeros(1,sensorRayCount);
                ego_y_RayPoints = zeros(1,sensorRayCount);
                ego_dist_RayPoints = zeros(1,sensorRayCount);
                theta = linspace(0,2*pi,sensorRayCount);
                x_pos = str2num(vehicle{vehicle_n}.POS.X1);
                y_pos = str2num(vehicle{vehicle_n}.POS.Y1);

                for rayCnt = 1:sensorRayCount
                    ego_x_RayPoints(rayCnt) = x_pos + r*cos(theta(rayCnt));
                    ego_y_RayPoints(rayCnt) = y_pos + r*sin(theta(rayCnt));
                    ego_dist_RayPoints(rayCnt) = FOVrange;
                end
                % -------------------------------------------
                % get occlusion points for cars
                % -------------------------------------------
                for vehicleOther = 1:size(vehicle,2)
                    % check if it is yourself
                    if strcmp(vehicle{vehicle_n}.ID, vehicle{vehicleOther}.ID)
                        continue;
                    end
                    % check if it is deleted
                    if strcmp(vehicle{vehicleOther}.ID, '-1')
                        continue;
                    end
                    % check if it is another AV then it cannot be an
                    % occlusion, because it senses the same area
                    if vehicle{vehicleOther}.isAV
                        continue;
                    end

                    other_x_points = vehicle{vehicleOther}.box.x;
                    other_y_points = vehicle{vehicleOther}.box.y;
                    % check if it is inside the circle
                    PolyCheckResult = inpolygon(other_x_points,other_y_points,ego_x_RayPoints,ego_y_RayPoints);
                    
                    newOcclusion = false;
                    polyCnt = 1;
                    for polyPointCnt = 1:size(PolyCheckResult,2)
                        
                        if PolyCheckResult(polyPointCnt) 
                            % save relevant points
                            newOcclusion = true;
                            occludingVehicle{occVehicleCnt}.x(polyCnt) = other_x_points(polyPointCnt);
                            occludingVehicle{occVehicleCnt}.y(polyCnt) = other_y_points(polyPointCnt);
                            polyCnt = polyCnt +1;

                            if (bVisualizeDebug)
                                plot(other_x_points(polyPointCnt),other_y_points(polyPointCnt),'or')
                            end
                        end
                    end
                    if newOcclusion == true
                        occVehicleCnt = occVehicleCnt + 1;
                    end
                end

               %% make sure we have occluding vehicle defined
               try 
                   size(occludingVehicle,2)
               catch
                   occludingVehicle = zeros(0);
               end


                
                % We know possible occlusion points
                % Now we perform the ray tracing for the given occlusions
                ego_x = str2num(vehicle{vehicle_n}.POS.X1);
                ego_y = str2num(vehicle{vehicle_n}.POS.Y1);
                for rayIter = 1:sensorRayCount
                    % (1) Check rays for occluding vehicles
                    % setup ego ray
                    x_ray = [ego_x, ego_x_RayPoints(rayIter)];
                    y_ray = [ego_y, ego_y_RayPoints(rayIter)];
                    for occIter = 1:size(occludingVehicle,2)

                        % setup occluding object
                        x_object = occludingVehicle{occIter}.x;
                        y_object = occludingVehicle{occIter}.y;

                        if bUsePolyXPoly
                            [polyxpolyresultX, polyxpolyresultY]  = ...
                                polyxpoly(x_ray, y_ray, x_object, y_object);
                        else
                            [polyxpolyresultX, polyxpolyresultY]  = ...
                                intersections(x_ray, y_ray, x_object, y_object,bRobustIntersections);
                        end

                        % it is curcial to collect the information about the second intersection, because
                        % otherwise we would evaluate that the area that is taken by the vehicle is an acutal occluded spot
                        if size(polyxpolyresultX,1) > 1
                            for polyxresIter = 1:size(polyxpolyresultX,1)
                                dist_list = zeros(size(polyxpolyresultX,1),1);
                                % get all distances
                                for distCalcIter = 1:size(polyxpolyresultX,1)
                                    dist_list(distCalcIter) = distance([ego_x,ego_y], ...
                                        [polyxpolyresultX(distCalcIter),polyxpolyresultY(distCalcIter)]);
                                end

                                %get second smallest value
                                [~, sortedIndices] = sort(dist_list);
                                indexSecondSmallest = sortedIndices(2);

                                dist = distance([ego_x,ego_y], ...
                                    [polyxpolyresultX(polyxresIter),polyxpolyresultY(polyxresIter)]);
                                % if ray is smaller than current dist than replace it
                                if dist < ego_dist_RayPoints(rayIter)
                                    ego_dist_RayPoints(rayIter) = dist_list(indexSecondSmallest);
                                    ego_x_RayPoints(rayIter) = polyxpolyresultX(indexSecondSmallest);
                                    ego_y_RayPoints(rayIter) = polyxpolyresultY(indexSecondSmallest);
                                    x_ray = [ego_x, ego_x_RayPoints(rayIter)];
                                    y_ray = [ego_y, ego_y_RayPoints(rayIter)];
                                end
                            end                          
                        end
                    end

                    % (2) Check rays for occluding buildings
                    % we have to check all rays against all building polygons
                    for building = 1:size(osmBuildings,2)
            
    
                        if bUsePolyXPoly
                            [polyxpolyresultX, polyxpolyresultY]  = ...
                                polyxpoly(x_ray, y_ray, osmBuildings{building}.x, osmBuildings{building}.y);
                        else
                            [polyxpolyresultX, polyxpolyresultY]  = ...
                                intersections(x_ray, y_ray, osmBuildings{building}.x, osmBuildings{building}.y,bRobustIntersections);
                        end

                        for polyPointCnt = 1:size(polyxpolyresultX,1)
                            
                            if polyxpolyresultX(polyPointCnt) 
                                dist = distance([ego_x,ego_y], ...
                                    [polyxpolyresultX(polyPointCnt),polyxpolyresultY(polyPointCnt)]);

                                if dist < ego_dist_RayPoints(rayIter)
                                    ego_dist_RayPoints(rayIter) = dist;
                                    ego_x_RayPoints(rayIter) = polyxpolyresultX(polyPointCnt);
                                    ego_y_RayPoints(rayIter) = polyxpolyresultY(polyPointCnt);
                                    x_ray = [ego_x, ego_x_RayPoints(rayIter)];
                                    y_ray = [ego_y, ego_y_RayPoints(rayIter)];
                                end
                                % show building ray hits
                                if (bVisualizeDebug)
                                    plot(polyxpolyresultX,polyxpolyresultY,'ob')
                                end
                            end
                        end
    
                    end

                    % (3) Check rays for occluding cars
                    % we have to check all rays against all parking polygons
                    % only static occlusion scenario
                    if(bPlotParkedVeh)
                        for parking = 1:size(osmParking,2)
    
                            if bUsePolyXPoly
                                [polyxpolyresultX, polyxpolyresultY]  = ...
                                    polyxpoly(x_ray, y_ray, osmParking{parking}.x, osmParking{parking}.y);
                            else

                                [polyxpolyresultX, polyxpolyresultY]  = ...
                                    intersections(x_ray, y_ray, osmParking{parking}.x, osmParking{parking}.y,bRobustIntersections);
    
                            end

                            for polyPointCnt = 1:size(polyxpolyresultX,1)
    
                                if polyxpolyresultX(polyPointCnt) 
                                    dist = distance([ego_x,ego_y], ...
                                        [polyxpolyresultX(polyPointCnt),polyxpolyresultY(polyPointCnt)]);
    
                                    if dist < ego_dist_RayPoints(rayIter)
                                        ego_dist_RayPoints(rayIter) = dist;
                                        ego_x_RayPoints(rayIter) = polyxpolyresultX(polyPointCnt);
                                        ego_y_RayPoints(rayIter) = polyxpolyresultY(polyPointCnt);
                                        x_ray = [ego_x, ego_x_RayPoints(rayIter)];
                                        y_ray = [ego_y, ego_y_RayPoints(rayIter)];
                                    end
                                    % show building ray hits
                                    if (bVisualizeDebug)
                                        plot(polyxpolyresultX,polyxpolyresultY,'ob')
                                    end
                                end
                            end
    
                        end
                    end
                   
                    % this is the valueable info!
                    % x_ray and y_ray

                    % show single rays
                    if (bVisualizeDebug)
                        plot(x_ray,y_ray,'color',[0 0.5 0])
                    end

                    % create FoV Hull
                    FoVHull(rayIter,1) = x_ray(2);
                    FoVHull(rayIter,2) = y_ray(2);
                    
                end
                if ~strcmp(vehicle{vehicle_n}.ID, '-1')
                    if usePlot
                        plot (FoVHull(:,1),FoVHull(:,2),'r')
                    end
                    vehicle{vehicle_n}.FoVHull = FoVHull;
                end
            else
                if usePlot
                    plot(vehicle{vehicle_n}.box.x,vehicle{vehicle_n}.box.y,'k');
                end
            end
            % Finsihed for this AV


        end
    catch me
%         display("error "+me.message)
    end
    
    
    % ----------------------------
    % ------ update bin map ------
    % ----------------------------

    showBinMap = false;
    if showBinMap
        % plot bin
        % boundaries
        plot([MapX(1),MapX(2)],[MapY(1),MapY(1)],LineWidth=3,Color=[.5 .5 .5])
        plot([MapX(1),MapX(2)],[MapY(2),MapY(2)],LineWidth=3,Color=[.5 .5 .5])
        plot([MapX(1),MapX(1)],[MapY(1),MapY(2)],LineWidth=3,Color=[.5 .5 .5])
        plot([MapX(2),MapX(2)],[MapY(1),MapY(2)],LineWidth=3,Color=[.5 .5 .5])
        for yIter = 1:size(binmap,2)-1
            % plot horizontal seperator lines
             plot([MapX(1),MapX(2)],[MapY(1)+yIter,MapY(1)+yIter],LineWidth=1,Color=[.8 .8 .8])
        end
        for xIter = 1:size(binmap,1)-1
            % plot horizontal seperator lines
             plot([MapX(1)+xIter,MapX(1)+xIter],[MapY(1),MapY(2)],LineWidth=1,Color=[.8 .8 .8])
        end
    end

    frameBinmap = zeros(xSize,ySize);

    try
        for vehicleIter = 1:size(vehicle,2)
            if strcmp(vehicle{vehicleIter}.ID, '-1')
                continue;
            end
            if vehicle{vehicleIter}.isAV
                vehicle{vehicleIter}.FoVHull;
                % iterate over all bins and check for matches
                for xIter = 1:size(binmap,1)
                    for yIter = 1:size(binmap,2)
                        % start at bottom left
                        boxPointX(1) = [MapX(1)+xIter];
                        boxPointX(2) = [MapX(1)+xIter];
                        boxPointX(3) = [MapX(1)+xIter+1];
                        boxPointX(4) = [MapX(1)+xIter+1];
                        boxPointX(5) = [MapX(1)+xIter];

                        boxPointY(1) = [MapY(1)+yIter];
                        boxPointY(2) = [MapY(1)+yIter+1];
                        boxPointY(3) = [MapY(1)+yIter+1];
                        boxPointY(4) = [MapY(1)+yIter];
                        boxPointY(5) = [MapY(1)+yIter];

%                         plot(boxPointX,boxPointY)

                        % check if box is inside FoV
                        result = inpolygon(boxPointX,boxPointY,vehicle{vehicleIter}.FoVHull(:,1)',vehicle{vehicleIter}.FoVHull(:,2)');
                        if result
%                             plot(boxPointX,boxPointY)
                            %WARNING THIS IS NOT NORMALIZED FOR FRAMES
                            frameBinmap(xIter,yIter) = 1;
                        end
                    end
                end
            end
        end

        % add observations from this frame to the overall binmap
        binmap = binmap + frameBinmap;

    catch me
%         display("error2 "+me.message)
    end
    
    

    % ----------------------------
    % ------ other stuff ---------
    % ----------------------------


    offset = 50; %m increase area visible in simulation
    axis([MapX(1)-offset MapX(2)+offset MapY(1)-offset MapY(2)+offset])

    displayText = "AV Percentage: "+AVCnt/(CarCnt-AVCnt)*100;
    text(MapX(2)+offset+10,MapY(2)+offset,displayText)
    displayText = "Common Vehicle Count: "+(CarCnt-AVCnt);
    text(MapX(2)+offset+10,MapY(2)+offset-10,displayText)
    displayText = "AV Count: "+AVCnt;
    text(MapX(2)+offset+10,MapY(2)+offset-15,displayText)
    displayText = "Note: Not all vehicles are inside the view area from the " + ...
        "beginning of the simulation";
    text(MapX(2)+offset+10,MapY(2)+offset-25,displayText)

    % track av penetration rate
    currentAVpercentage = (AVCnt/(CarCnt-AVCnt))*100;
    ts_AVPenetrationRate = addsample(ts_AVPenetrationRate, 'Data', currentAVpercentage, 'Time', 0.1*frame);

    pause(0.0001)
end


%% save binmap

save("Results/binmap_AV"+num2str(AVpercentage*100)+"_FOV"+num2str(FOVrange)+".mat","binmap","ts_AVPenetrationRate")

