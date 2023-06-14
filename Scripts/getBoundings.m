function [boxX,boxY] = getBoundings(posX,posY,angle,length,width)
%GETBOUNDINGS Summary of this function goes here
%   Detailed explanation goes here
test = updateBoundingBox(0,0,angle,length,width);
boxX = [test{1}.X, test{2}.X, test{3}.X, test{4}.X, test{1}.X]+posX;
boxY = [test{1}.Y, test{2}.Y, test{3}.Y, test{4}.Y, test{1}.Y]+posY;

end

