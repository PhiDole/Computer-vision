%--------------------------------------------------------------------------------------
%
%	Philippine DOLIQUE
%
%	Projet reconnaissance de plaques d'immatriculation
%
%	Modification : 13.06.2018
%
%--------------------------------------------------------------------------------------

clear all
close all
clc
warning('off','all');

resultat = ['DA-849-RJ'; 'DM-814-SV'; 'AT-752-FR'; 'AP-769-CL'; 'DC-282-FJ'; 'CX-478-TL'; 'BP-341-NT'; 'AM-338-AR'; 'DJ-538-WF';...
    'DB-654-NN'; 'DH-013-JQ'; 'CN-990-LL'; 'AT-751-SW'; 'DL-536-MG'; 'CY-291-ZN'; 'AW-376-NH'; 'AC-439-WW'; 'DE-002-DK'; 'BV-593-WP';...
    'CA-101-HD'; 'AS-118-ZQ'; 'AD-446-YA'; 'DA-187-CW'; 'CH-698-SC'; 'CQ-140-WY'; 'DK-159-RF'; 'CD-702-JS'; 'CG-733-RF'; 'CG-343-NE';...
    'BX-066-LS'; 'AE-222-DN'; 'BP-564-NF'; 'BK-392-TE'; 'BK-392-TE'; 'BJ-742-RZ'; 'AW-530-QN'; 'DE-955-KY'; 'DN-899-EE'; 'BZ-896-SP';...
    'CT-277-QF'; 'DN-184-VH'; 'DK-805-TB'; 'BJ-019-ZS'; 'BT-286-NT'; 'DB-830-NF'; 'CT-282-GA'; 'CT-282-GA'; 'DC-282-FJ'; 'AE-433-HR';...
    'AZ-982-WT'; 'AZ-982-WT'; 'CN-974-JT'; 'BW-930-WE'; 'AL-430-HK'; 'AL-430-HK'];

numPos = 55*3;

stat1 = 0;
stat2 = 0;

for numImage = 1:55

    %% Traitement initiale
    
    % Ouverture de l'image
    formatSpec = 'P%d%s';
    str = '.JPG';
    str2 = sprintf(formatSpec,numImage,str);
    image  = imread(str2);

%       image = imread('P1.JPG');

    % Prétraitement de l'image, qui permet de mettre en avant les carrés
    % bleus sur les côtés de la plaque
    im = pretraiter(image);
    [H,W] = size(im);
    
     string = resultat(numImage,:);

    %% Recherche des contours de la plaque 
    
    L = 1:H;
    l = 1:W;
    
    %Calcul de l'histogramme cumulé sur la moitié de l'image pour détecter
    %la largeur du carré bleu de gauche
    absCol = histVerti(im, 9/10);
    
    if length(absCol)>2
        absCol(2) = absCol(length(absCol));
    end

    imbis = imcrop(im, [absCol(1) 0 (absCol(2)- absCol(1)) H]);
    
    
    % On en déduit sa hauteur
    box = regionprops(imbis, 'BoundingBox');

    
    absLign(1) = box(1).BoundingBox(2); % Ligne du haut
    absLign(2) = box(1).BoundingBox(4);% Ligne du bas 
    imter = imcrop(im, [0 absLign(1) W absLign(2)]);
    
    %Grâce à la hauteur du carré bleu de gauche sur l'image on en déduit
    %la position du carré de droite
    box2 = regionprops(imter, 'BoundingBox');
    %On en déduit des rectangles encadrant la plaque et les numéros
    delta = 10;
    rect1(1) = box2(1).BoundingBox(1) - delta;
    rect1(2) = absLign(1) - delta;
    rect1(3) = box2(2).BoundingBox(1) + box2(2).BoundingBox(3) - box2(1).BoundingBox(1) + 2*delta;
    rect1(4) = rect1(3)*11/55 + delta;
    rect2(1) = box2(1).BoundingBox(1) + box2(1).BoundingBox(3) ;
    rect2(2) = absLign(1);
    rect2(3) = box2(2).BoundingBox(1) - (box2(1).BoundingBox(1) + box2(1).BoundingBox(3));
    rect2(4) = rect1(4) - 2*delta;
    
     figure; imshow(image); hold on; 
     rectangle('Position', rect1, 'EdgeColor','g','LineWidth',3); hold on;
     rectangle('Position', rect2, 'EdgeColor','m','LineWidth',3); hold on;


    %% Detection et reconnaissance des numéros de la plaque
    
    %On réalise une différence entre l'image et un top hat pour faire
    %ressortir les petits caractères sombres de l'image    
    
    plaque = tailleText(rgb2gray(image), rect2(1), rect2(3));
    BW1 = imcrop(BottomHat(image),[rect2(1) plaque(1) rect2(3) plaque(2)]);
    %On passe l'image en binaire et on réalise une ouverture pour enlever
    %les petites structures blanches
    BW2 = im2bw(BW1, 0.2);    
    se = strel('square', 5);
    BW3 = imopen(BW2, se);
    [Hplaque Wplaque] = size(BW3);
    

    %On ouvre les images des numéros qui vont servir à la corrélation
    format = 'plaque%d%s';
    s = '.jpg';
    info = imfinfo('plaque0.jpg');
    hr = info.Height;
    
    %On recadre les images pour que les numéros aient la même taille que
    %ceux de la plaque
    scale = (Hplaque)/hr;
    Wr = ceil((info.Width)*scale) ;
    Hr = Hplaque;
    
    %On stocke les numéros
    iref = zeros(Hr,Wr,32);
    for num = 0:32
        imref = imresize(~im2bw(rgb2gray(imread(sprintf(format,num,s))),0.5), scale);
        iref(:,:,num+1) = imref;
    end
    %On labellise la plaque
    [label, nbobjets] = bwlabel(BW3,8);
       

    resultat1='';
    for i=4:6
        
        x = bwlabel((label == i),8); 
        c = regionprops(x,'Area','BoundingBox'); 

        Wnum = c.BoundingBox(3);
        y0= c.BoundingBox(1) - round((Wr-Wnum)/2); 

        maxcorr = -100;
        maxr = -1;
        %On calcule la corrélation pour chaque numéro, et on garde en
        %mémoire celui avec la corrélation maximale
        if (y0 + Wr-1 < Wplaque)
            test = x(1:Hr,y0:y0+Wr-1);
            for r=1:10
                correl = corr2(iref(:,:,r),test);           
                if correl > maxcorr                        
                    maxcorr = correl;
                    maxr = r;
                end
            
            end
        end
        resultat1 = strcat(resultat1, match(maxr));
    end
    

     %On applique l'algorithme OCR pour reconnaitre les numéro
     txt = ocr(BW3);
     resultat2 = txt.Text(4:6);
     
     %On met à jour le nombre de réussite pour chaque algorithme de
     %reconnaissance
     for i = 1:3
         if resultat1(i) == string(i+3)
            stat1 = stat1+1;
         end
         if resultat2(i) == string(i+3)
             stat2 = stat2+1;
         end
     end
    
    
end

% On calcul le pourcentage de réussite de chaque algorithme

statOcr = 100*stat2/numPos
statCor = 100*stat1/numPos