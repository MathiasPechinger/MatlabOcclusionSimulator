function [points] = updateBoundingBox(PosX,PosY,angle,length,width)
%UPDATEBOUNDINGBOX Summary of this function goes here
%   Detailed explanation goes here
% X = x*cos(angle) - y*sin(angle)
% Y = x*sin(angle) + y*cos(angle)
    
% points{1}.X = PosX - ( (length/2)*cos(angle) - (width/2)*sin(angle) );
% points{1}.Y = PosY + ( (length/2)*sin(angle) + (width/2)*cos(angle) );
% points{2}.X = PosX + ( (length/2)*cos(angle) - (width/2)*sin(angle) );
% points{2}.Y = PosY + ( (length/2)*sin(angle) + (width/2)*cos(angle) );
% points{3}.X = PosX + ( (length/2)*cos(angle) - (width/2)*sin(angle) );
% points{3}.Y = PosY - ( (length/2)*sin(angle) + (width/2)*cos(angle) );
% points{4}.X = PosX - ( (length/2)*cos(angle) - (width/2)*sin(angle) );
% points{4}.Y = PosY - ( (length/2)*sin(angle) + (width/2)*cos(angle) );

x_FL = length/2;
y_FL = width/2;
x_FR = length/2;
y_FR = -width/2;
x_RL = -length/2;
y_RL = width/2;
x_RR = -length/2;
y_RR = -width/2;

tempX = x_FL-PosX;
tempY = y_FL-PosY;
rotatedX = tempX*cos(angle)-tempY*sin(angle);
rotatedY = tempX*sin(angle)+tempY*cos(angle);
points{1}.X = rotatedX+PosX;
points{1}.Y = rotatedY+PosY;

tempX = x_FR-PosX;
tempY = y_FR-PosY;
rotatedX = tempX*cos(angle)-tempY*sin(angle);
rotatedY = tempX*sin(angle)+tempY*cos(angle);
points{2}.X = rotatedX+PosX;
points{2}.Y = rotatedY+PosY;

tempX = x_RR-PosX;
tempY = y_RR-PosY;
rotatedX = tempX*cos(angle)-tempY*sin(angle);
rotatedY = tempX*sin(angle)+tempY*cos(angle);
points{3}.X = rotatedX+PosX;
points{3}.Y = rotatedY+PosY;

tempX = x_RL-PosX;
tempY = y_RL-PosY;
rotatedX = tempX*cos(angle)-tempY*sin(angle);
rotatedY = tempX*sin(angle)+tempY*cos(angle);
points{4}.X = rotatedX+PosX;
points{4}.Y = rotatedY+PosY;



end



% // cx, cy - center of square coordinates
% // x, y - coordinates of a corner point of the square
% // theta is the angle of rotation

% // translate point to origin
% float tempX = x - cx;
% float tempY = y - cy;
% 
% // now apply rotation
% float rotatedX = tempX*cos(theta) - tempY*sin(theta);
% float rotatedY = tempX*sin(theta) + tempY*cos(theta);
% 
% // translate back
% x = rotatedX + cx;
% y = rotatedY + cy;