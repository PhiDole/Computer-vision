
%--------------------------------------------------------------------------------------
%
%	Philippine DOLIQUE
%
%	Projet reconnaissance de plaques d'immatriculation
%
%	Modification : 04.06.2018
%
%--------------------------------------------------------------------------------------


function [ rectangle ] = tailleText( image, index1, index2 )

   
    [Horigin,Worigin] = size(image);

    %% Pré-traitement de l'image (recadrement et filtrage)

    %  Recadrement de l'image
    im = imcrop(image, [50 0.25*Horigin  550 (Horigin*0.5)]);
    [H,W] = size(im);
%      figure, imshow(im);

    % Filtre médian pour enlever le bruit
    imfilt = medfilt2(im);
    
    %% Morphologie mathématique pour accentuer les caractéristiques de l'image
    
    % Fermeture et Erosion de l'image par un disque de rayon 3px
    se = strel('disk',3);
    BW =imclose(im,se);
 %    figure, imshow(BW), title('Image fermeture')
    erodeBW = imerode(BW, se);
%     figure, imshow(erodeBW), title('Image érosion')
    

    
    %% Contours de l'image grâce au gradient 
    
    % Determiner les contours de l'image grâce au noyau de Sobel
    imGrad = edge(erodeBW, 'Sobel', 0.1, 'vertical');
%     figure, imshow(imGrad), title('Gradient')


    %% Fermeture pour accentuer le contour de la plaque 

    % Fermeture de l'image par un carré de côté 40px
    se2 = strel('square', 40);
    Imclose = imclose(imGrad, se2);
%    figure, imshow(Imclose), title('image fermée')
    
    %% Histogramme Profil cumulé vertical
    
    % Calcul de l'histogramme horizontal
    col = sum(Imclose, 2);
    Cy = 1 :H;
%   figure, plot(col, Cy, '-r'); title('Histogramme verticale');
 
    % Seuillage et binarisation de l'histogramme 
    seuil2 = max(col)/2;
    for i = 1 : H
        if col(i)> seuil2
            col(i) = 1;
        else
            col(i) = 0;
        end
    end
    
    
    % Définir les débuts et fins horizontales des rectangles
    absCol = [];
    b=0;
    
    for i = 2 : H
        if col(i)==1 && col(i-1)==0
            b = b+1;
            absCol(b) = i;
        elseif col(i)==0 && col(i-1)==1
            b = b+1; 
            absCol(b) = i;
        end
    end
    
%     figure, imshow(im);
%     for i = 1 : length(absCol)
%         hold on; plot([0 W], [absCol(i) absCol(i)] , '-r');
%     end
    
 
        
    
    % Recadrement de l'image grâce au profil cumulé vertical
    
    delta = 5;
    rectangle = [absCol(1)+0.25*Horigin - delta (absCol(2)- absCol(1)) + delta];
    Imclose2 = imcrop(Imclose, [index1 absCol(1) index2 (absCol(2)- absCol(1))]);

end

