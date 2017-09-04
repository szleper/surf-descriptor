function [ ] = showFeatures( img, Points, features_count )

% Affichage des points d'interets de notre image.

% Echelles d'analyse de l'image
L = getScales();

% Selection des points des points d'interets les 
Points = Points(1:features_count,:);

figure;

imshow(img);

hold on;

plot(Points(:,4),Points(:,3),'+','color','green');

for i = 1:features_count
    position = [ Points(i,4) - (3*L(Points(i,5))-1)/2, Points(i,3) - (3*L(Points(i,5))-1)/2, ...
                    2*(3*L(Points(i,5))-1)/2 + 1, 2*(3*L(Points(i,5))-1)/2 + 1];
                
    rectangle('Position', position, 'Curvature', [1 1], 'EdgeColor', 'green')
end

hold off;

end
