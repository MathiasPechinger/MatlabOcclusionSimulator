function [ts_av_penetration,ts_totalCarCount] = getAVpentrationRate(AVpercentage, usePlot,aimsunData)
% This function is used to get the av pentration rate over time as is is
% complex to recalculate everything just to get the pentration rate.


%% Setup structure for AV penetration rate
ts_AVPenetrationRate = timeseries();
ts_CarCount = timeseries();


fprintf('Progress:   0%%');

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
% ------ run simulation ------
% ----------------------------


aimsunDynamicData = aimsunData.AIMSUN_ANIMATION.DYNAMIC;
CarCnt = 1;
AVCnt = 0;
clear vehicle;


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
                % So for every newly created vehicle we check how many
                % vehicles were created already and add a new one if the
                % percentage falls below our threshold
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
                    if (AVCnt/CarCnt < AVpercentage)
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


    % get vehicle count inside intersection


    % 
    % displayText = "AV Percentage: "+AVCnt/(CarCnt-AVCnt)*100;
    % text(MapX(2)+offset+10,MapY(2)+offset,displayText)
    % currentAVpercentage = (AVCnt/(CarCnt-AVCnt))*100;
    currentAVpercentage = (AVCnt/(CarCnt))*100;

    ts_CarCount = addsample(ts_CarCount, 'Data', CarCnt, 'Time', 0.1*frame);
    ts_AVPenetrationRate = addsample(ts_AVPenetrationRate, 'Data', currentAVpercentage, 'Time', 0.1*frame);


    progressPercentage = (frame/size(aimsunDynamicData.FRAME,2))*100;
    % disp("progress: "+ progressPercentage)
    fprintf('\b\b\b\b%3d%%', round(progressPercentage));

    

    % pause(0.0001)
end

ts_totalCarCount = ts_CarCount;

ts_av_penetration = ts_AVPenetrationRate;

%% save binmap

% save("Results/binmap_AV"+num2str(AVpercentage*100)+"_FOV"+num2str(FOVrange)+".mat","binmap")

