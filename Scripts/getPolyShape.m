function [polyBox] = getPolyShape(MapX,MapY,xIter,yIter)
%GETPOLYSHAPE Summary of this function goes here
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
end

