function [angle] = getAngleFromXY(v)
%GETANGLEFROMXY Summary of this function goes here
%   Detailed explanation goes here

angle = atan2( ...
    (str2num(v.Y2)-str2num(v.Y1)),...
    (str2num(v.X2)-str2num(v.X1)) ...
    );
end

