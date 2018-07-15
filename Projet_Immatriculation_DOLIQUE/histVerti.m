%--------------------------------------------------------------------------------------
%
%	Philippine DOLIQUE
%
%	Projet reconnaissance de plaques d'immatriculation
%
%	Modification : 04.06.2018
%
%--------------------------------------------------------------------------------------
function [ absCol ] = histVerti( im, seuil )
    [H,W] = size(im);
%   Calcul de l'histogramme horizontal
    col = sum(im, 1);
%   Seuil max
    maxi = seuil*(max(col(1:W/2)));
%   Enregistre les abscisses de début et de fin de chaque pic
    absCol = [];
    j = 1;
    L = 0:H;
    l = 0:W;
    
%   Prend les débuts et fins de chaque pic
    for i=2:W/2
        if col(i-1) <= maxi && col(i) >= maxi
            absCol(j) = i;
            j = j + 1;
        elseif col(i-1) >= maxi && col(i) <= maxi
            absCol(j) = i;
            j= j+1;
        end
    end
    

    
end

