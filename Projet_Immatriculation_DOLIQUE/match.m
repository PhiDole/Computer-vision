%--------------------------------------------------------------------------------------
%
%	Philippine DOLIQUE
%
%	Projet reconnaissance de plaques d'immatriculation
%
%	Modification : 04.06.2018
%
%--------------------------------------------------------------------------------------

function [ result ] = match( num )

%   Permet de faire le lien entre l'indexe de l'image et la lettre ou le
%   chiffre correspondant
 pos = ['0'; '1'; '2'; '3'; '4'; '5'; '6'; '7'; '8'; '9'; 'A'; 'B'; 'C'; 'D'; 'E'; 'F';...
        'G'; 'H'; 'J'; 'K'; 'L'; 'M'; 'N'; 'P'; 'Q'; 'R'; 'S'; 'T'; 'V'; 'X'; 'Y'; 'Z'; '-'];
    if (num == -1)
        result='!';
    else
        result = pos(num);
    end          

end

