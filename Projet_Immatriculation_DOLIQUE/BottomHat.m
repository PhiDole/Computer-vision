%--------------------------------------------------------------------------------------
%
%	Philippine DOLIQUE
%
%	Projet reconnaissance de plaques d'immatriculation
%
%	Modification : 07.06.2018
%
%--------------------------------------------------------------------------------------
function [ im ] = BottomHat( image )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    grayIm = rgb2gray (image);
    se = strel('square', 30);
    imClose = imclose(grayIm, se);
    im = imClose - grayIm ;
%     figure, imshow(im);

end

