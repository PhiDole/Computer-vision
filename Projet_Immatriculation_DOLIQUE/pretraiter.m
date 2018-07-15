%--------------------------------------------------------------------------------------
%
%	Philippine DOLIQUE
%
%	Projet reconnaissance de plaques d'immatriculation
%
%	Modification : 04.06.2018
%
%--------------------------------------------------------------------------------------

function [ im ] = pretraiter( image )
%   Mise en avant des zones bleues de l'image
    imageBlue = image(:,:,3);
    diff =  imageBlue- image;
    
%   Passage de l'image en niveaux de gris
    grayImage = rgb2gray(diff); 
%   Calcul du gradient de Canny pour trouver les contours
    imGrad = edge(grayImage, 'Canny', 0.5);
    
%   Fermeture sur l'image pour rejoindre les contours entre eux et créer
%   des zones
    se = strel('square', 40);
    Imclose = imclose(imGrad, se);
%   Fermeture sur l'image pour enlever les lignes horizontales
    se2 = strel('line', 20, 90);
    im = imerode(Imclose, se2);
    
end

