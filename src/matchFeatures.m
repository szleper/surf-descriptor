function [ distance ] = matchFeatures( ImgFeatures, BaseFeatures )

% Comparaison des features de l'image avec les features des images de 
% notre base de donnees. Renvoie la matrice des distances de features de
% l'image aux features de la base de donnees.

n = size(ImgFeatures,1);
m = size(BaseFeatures,1);

distance = zeros(n,m);

for i = 1:n
   for j = 1:m
     distance(i,j) = norm(ImgFeatures(i,:)-BaseFeatures(j,:));
   end
end

end

