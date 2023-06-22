function [] = readOSM(osmFileName, origin, LTP_OffsetX, LTP_OffsetY, bStaticScenario)

    alt = origin(3);  % 10 meters is an approximate altitude in Boston, MA
    

    %% load osm data

    osmData = xml2struct(osmFileName);
    format long
    
    %% align lat lon to local coordinate frame
    osmNode = osmData.osm.node;
    
%     figure
    hold on 
    
    % for iter = 1:size(osmNode,2)
    %     lat = str2num(osmNode{iter}.Attributes.lat);
    %     lon = str2num(osmNode{iter}.Attributes.lon);
    %     plot(lat,lon,'xr')
    % end
    
    %%
    clear osmBuildings osmHighways
    buildingIter = 1;
    highwayIter = 1;
    parkingIter = 1;
    sidewalkIter = 1;
    parkIter = 1;
%     figure
    hold on
    
    osmWay = osmData.osm.way;
    osmNode = osmData.osm.node;
    %iterate over all ways
    for ways = 1:size(osmWay,2)
        
        % BUILDINGS
        % we have to try because sometimes, tags are missing
        try
            % check if it is a building in all tags
            for tagIter = 1:size(osmWay{ways}.tag,2)
                if strcmp(osmWay{ways}.tag{tagIter}.Attributes.k,'building')
        
                     %iterate over all nodes in ways
                    clear lat lon
                    for wayNodes = 1:size(osmWay{ways}.nd,2)
                        nodeID = osmWay{ways}.nd{wayNodes}.Attributes.ref;
                        % serach for nodeID in nodes
                        for searchIter = 1:size(osmNode,2)
                            % add matching id to list
                            if strcmp(nodeID,osmNode{searchIter}.Attributes.id)
                                % NOTE: why check for 6 arcis specific?
%                                 if buildingIter == 6
%                                     break;
%                                 end
                                osmBuildings{buildingIter}.lat(wayNodes) = str2num(osmNode{searchIter}.Attributes.lat);
                                osmBuildings{buildingIter}.lon(wayNodes) = str2num(osmNode{searchIter}.Attributes.lon);
                                break;
                            end
                        end
                    end
%                     plot(osmBuildings{buildingIter}.lon,osmBuildings{buildingIter}.lat)
                    buildingIter = buildingIter+1;
                end
            end   
        end
    
        % ROADS
        % we have to try because sometimes, tags are missing
        try
            % check if it is a building in all tags
            for tagIter = 1:size(osmWay{ways}.tag,2)
                if and (strcmp(osmWay{ways}.tag{tagIter}.Attributes.k,'highway') ...
                     ,strcmp(osmWay{ways}.tag{tagIter}.Attributes.v,'secondary'))
        
                     %iterate over all nodes in ways
                    clear lat lon
                    for wayNodes = 1:size(osmWay{ways}.nd,2)
                        nodeID = osmWay{ways}.nd{wayNodes}.Attributes.ref;
                        % serach for nodeID in nodes
                        for searchIter = 1:size(osmNode,2)
                            % add matching id to list
                            if strcmp(nodeID,osmNode{searchIter}.Attributes.id)
                                osmHighways{highwayIter}.lat(wayNodes) = str2num(osmNode{searchIter}.Attributes.lat);
                                osmHighways{highwayIter}.lon(wayNodes) = str2num(osmNode{searchIter}.Attributes.lon);
                                break;
                            end
                        end
                    end
%                     plot(osmHighways{highwayIter}.lon,osmHighways{highwayIter}.lat)
                    highwayIter = highwayIter+1;
                end
            end   
        end
    
        % footway
        % we have to try because sometimes, tags are missing
        try
            % check if it is a building in all tags
            for tagIter = 1:size(osmWay{ways}.tag,2)
                if and (strcmp(osmWay{ways}.tag{tagIter}.Attributes.k,'highway') ...
                     ,strcmp(osmWay{ways}.tag{tagIter}.Attributes.v,'footway'))
        
                     %iterate over all nodes in ways
                    clear lat lon
                    for wayNodes = 1:size(osmWay{ways}.nd,2)
                        nodeID = osmWay{ways}.nd{wayNodes}.Attributes.ref;
                        % serach for nodeID in nodes
                        for searchIter = 1:size(osmNode,2)
                            % add matching id to list
                            if strcmp(nodeID,osmNode{searchIter}.Attributes.id)
                                osmSidewalk{sidewalkIter}.lat(wayNodes) = str2num(osmNode{searchIter}.Attributes.lat);
                                osmSidewalk{sidewalkIter}.lon(wayNodes) = str2num(osmNode{searchIter}.Attributes.lon);
                                break;
                            end
                        end
                    end
%                     plot(osmSidewalk{sidewalkIter}.lon,osmSidewalk{sidewalkIter}.lat)
                    sidewalkIter = sidewalkIter+1;
                end
            end   
        end
    
    
    
    end
    
    %% convert to LTP
    
    %all buildings
    for building = 1:size(osmBuildings,2)
        % all building nodes
        for nodes = 1:size(osmBuildings{building}.lat,2)
            lat = osmBuildings{building}.lat(nodes);
            lon = osmBuildings{building}.lon(nodes);
            [osmBuildings{building}.x(nodes),osmBuildings{building}.y(nodes),zUp] = latlon2local(lat,lon,alt,origin);
    %         osmBuildings{building}.x(nodes) = osmBuildings{building}.x(nodes)+LTP_OffsetX;
    %         osmBuildings{building}.y(nodes) = osmBuildings{building}.y(nodes)+LTP_OffsetY;
        end
    end
    
    % all highways
    for highways = 1:size(osmHighways,2)
        % all building nodes
        for nodes = 1:size(osmHighways{highways}.lat,2)
            lat = osmHighways{highways}.lat(nodes);
            lon = osmHighways{highways}.lon(nodes);
            [osmHighways{highways}.x(nodes),osmHighways{highways}.y(nodes),zUp] = latlon2local(lat,lon,alt,origin);
        end
    end
    
    % all sidewalks
    for sidewalks = 1:size(osmSidewalk,2)
        % all building nodes
        for nodes = 1:size(osmSidewalk{sidewalks}.lat,2)
            lat = osmSidewalk{sidewalks}.lat(nodes);
            lon = osmSidewalk{sidewalks}.lon(nodes);
            [osmSidewalk{sidewalks}.x(nodes),osmSidewalk{sidewalks}.y(nodes),zUp] = latlon2local(lat,lon,alt,origin);
        end
    end
    
    
    
    
    
    %%
%     figure 
    hold on
    for building = 1:size(osmBuildings,2)
        hold on
%         plot (osmBuildings{building}.x,osmBuildings{building}.y,'-b')
    end
    
    % figure 
    hold on
    for highway = 1:size(osmHighways,2)
        hold on
%         plot (osmHighways{highway}.x,osmHighways{highway}.y,'-k')
    end
    
    % figure 
    hold on
    for sidewalks = 1:size(osmSidewalk,2)
        hold on
%         plot (osmSidewalk{sidewalks}.x,osmSidewalk{sidewalks}.y,'-r')
    end
    
    
    
    %% Add Car ONLY FOR STATIC SCENARIO PARKING VEHICLES
    
    if (bStaticScenario)
    
        angle1 = deg2rad(246+90);
        angle2 = deg2rad(157+90);
        width = 2.0;
        length = 4.1;
        
        Car{1} = [92.2899421691895+LTP_OffsetX, 104.644905090332+LTP_OffsetY, 2.7,7.0,angle1];
        Car{2} = [95.7775192260742+LTP_OffsetX, 112.562324523926+LTP_OffsetY, width,length,angle1];
        Car{3} = [98.4492874145508+LTP_OffsetX, 118.818176269531+LTP_OffsetY, width,length,angle1];
        % Car{4} = Car{3} ;
        Car{4} = [101.007766723633+LTP_OffsetX, 124.406944274902+LTP_OffsetY, width,length,angle1];
        Car{5} = Car{3} ;
        Car{6} = [105.394760131836+LTP_OffsetX, 111.294845581055+LTP_OffsetY, width,length,angle1];
        Car{7} = [78.2771148681641+LTP_OffsetX, 69.8350143432617+LTP_OffsetY, width,length,angle1];
        
        %right side main road
        Car{8} =  [108.462516784668+LTP_OffsetX, 82.1033325195313+LTP_OffsetY, width,length,angle2];
        Car{9} =  [113.674812316895+LTP_OffsetX, 79.9141693115234+LTP_OffsetY, width,length,angle2];
        Car{10} = [118.261627197266+LTP_OffsetX, 78.0377349853516+LTP_OffsetY, width,length,angle2];
        Car{11} = [123.473930358887+LTP_OffsetX, 75.9528198242188+LTP_OffsetY, width,length,angle2];
        Car{12} = [127.852256774902+LTP_OffsetX, 74.0763931274414+LTP_OffsetY, width,length,angle2];
        %left side main road
        Car{13} = [103.667205810547+LTP_OffsetX, 73.4509201049805+LTP_OffsetY, width,length,angle2];
        Car{14} = [108.358276367188+LTP_OffsetX, 71.4702453613281+LTP_OffsetY, width,length,angle2];
        Car{15} = [112.632354736328+LTP_OffsetX, 69.9065551757813+LTP_OffsetY, width,length,angle2];
        Car{16} = [117.010681152344+LTP_OffsetX, 68.0301361083984+LTP_OffsetY, width,length,angle2];
        Car{17} = [122.327224731445+LTP_OffsetX, 66.0494689941406+LTP_OffsetY, width,length,angle2];
        Car{18} = [126.809791564941+LTP_OffsetX, 64.2772903442383+LTP_OffsetY, width,length,angle2];
        
        %left road
        Car{19} = [75.6709671020508+LTP_OffsetX, 65.1439437866211+LTP_OffsetY, width,length,angle1]; 
        Car{20} = Car{19};
        % Car{20} = [73.377555847168 +LTP_OffsetX, 60.244384765625 +LTP_OffsetY, width,length,angle1];
        Car{21} = [71.5011367797852+LTP_OffsetX, 55.4490699768066+LTP_OffsetY, width,length,angle1]; 
        Car{22} = [90.2654037475586+LTP_OffsetX, 67.5415992736816+LTP_OffsetY, width,length,angle1]; 
        Car{23} = [87.9719924926758+LTP_OffsetX, 62.4335479736328+LTP_OffsetY, width,length,angle1]; 
        Car{24} = [85.9913177490234+LTP_OffsetX, 57.8467254638672+LTP_OffsetY, width,length,angle1]; 
        Car{25} = [83.9063949584961+LTP_OffsetX, 52.8429222106934+LTP_OffsetY, width,length,angle1]; 
        
        %main road further on
        Car{26} = Car{25}; 
        Car{27} = [73.7486114501953+LTP_OffsetX, 97.0105247497559+LTP_OffsetY, width,length,angle2]; 
        Car{28} = [68.3278198242188+LTP_OffsetX, 99.3039360046387+LTP_OffsetY, width,length,angle2]; 
        Car{29} = [74.3740844726563+LTP_OffsetX, 86.7944297790527+LTP_OffsetY, width,length,angle2]; 
        Car{30} = [70.1000061035156+LTP_OffsetX, 88.5666084289551+LTP_OffsetY, width,length,angle2];
        
        for (carIter = 1:size(Car,2))
            Car{carIter}
            % bounding box             
            [boxX,boxY] = getBoundings( ...
                Car{carIter}(1), ...
                Car{carIter}(2), ...
                Car{carIter}(5), ...
                Car{carIter}(3), ...
                Car{carIter}(4));
            CarBox{carIter}.x = boxX;
            CarBox{carIter}.y = boxY;

            hold on
            % plot(Car{carIter}(1),Car{carIter}(2),'xr')
            % plot(CarBox{carIter}.x,CarBox{carIter}.y,'-r')

            osmParking{carIter}.x = CarBox{carIter}.x;
            osmParking{carIter}.y = CarBox{carIter}.y;

        end
    % if static occlusion scenario we want parked cars
    save(osmFileName+".mat","osmBuildings","osmHighways","osmParking")

    else
    % if dynamic occlusion scenario (we don't need parked cars)
    save(osmFileName+".mat","osmBuildings","osmHighways")
    end
    
end


