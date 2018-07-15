
%--------------------------------------------------------------------------------------
%
%	Philippine DOLIQUE
%
%	Projet reconnaissance de plaques d'immatriculation
%
%	Modification : 13.06.2018
%
%--------------------------------------------------------------------------------------

function [ outList ] = maxk( inList, k )

    outList = [];

    for i = 1:k
        [~,I] = max(inList);
        outList(i) = I;
        inList(I) = 0;
        
    end

%     A = sort(inList);
%     i = A(length(A)-k-1:length(A));
%     
%     outList = zeros(1,k);
%     for j = 1:k
%         outList(j)
%         find(inList==i(j))
%         outList(j) = find(inList==i(j));
%         i(outList(j)) = 0;
%         
%     end
       
end

