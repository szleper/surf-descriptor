function [ Descriptor ] = extractFeatures( I, Points )

% Extraction du vecteur caracteristique pour chaque point d'interet.

Descriptor = zeros(size(Points,1),64);

% Calcul de l'image integrale pour la performance
iI = integralImage(I);

% Echelles d'analyse de l'image
L = getScales();

% On calcule la direction privilegie du gradient dans un cercle autour de
% chaque point d'interet.
TetaOptimal = zeros(size(Points,1),1);

disp('Calcul de la direction privilegie du gradient en chaque point d''interet ...');

tic
    
% On itere sur les points d'interets
for n = 1:size(Points,1)
    
    % Point d'interet 
    point = Points(n,:);
    y_pi = point(3);
    x_pi = point(4);
    
    % Variables d'echelle
    sigma = ceil(0.4*L(point(5)));
    l = ceil(0.8*L(point(5)));
    
    % Fenetre de ponderation gaussienne
    w = fspecial( 'gaussian', 12*sigma+1, 2*sigma );

    % Initialisation de la matrice contenant les gradients selon x et y 
    % ainsi que l'orientation du gradient Teta
    Gxy = zeros(13, 13, 2);
    Teta = zeros(13, 13);
    
    % Cercle autour du point d'interet
    for i = -6:6
       for j = -6:6
           if i^2+j^2 <= 36
                
               % Calcul des gradients pour chaque point du cercle de rayon
               % 6*sigma a l'echelle l.
               y = y_pi + i*sigma;
               x = x_pi + j*sigma;
               
               Gx = iI(y+l,x-1)+iI(y-l,x-l)-iI(y-l,x-1)-iI(y+l,x-l) ...
                    -(iI(y+l,x+l)+iI(y-l,x+1)-iI(y-l,x+l)-iI(y+l,x+1));

               Gy = iI(y-1,x+l)+iI(y-l,x-l)-iI(y-l,x+l)-iI(y-1,x-l) ...
                    -(iI(y+l,x+l)+iI(y+1,x-l)-iI(y+1,x+l)-iI(y+l,x-l));

               % Gradient selon x et y 
               Gxy(i+7,j+7,1) = Gx*w((6+i)*sigma+1,(6+j)*sigma+1);
               Gxy(i+7,j+7,2) = Gy*w((6+i)*sigma+1,(6+j)*sigma+1);
               
               % Orientation du gradient selon les gradients en x et y
               if (Gxy(i+7,j+7,1) == 0) && (Gxy(i+7,j+7,2) ~= 0)
                    if (Gxy(i+7,j+7,2) > 0)
                        Teta(i+7,j+7) = pi/2;
                    else
                        Teta(i+7,j+7) = 3*pi/2;
                    end
               elseif (Gxy(i+7,j+7,1) == 0) && (Gxy(i+7,j+7,2) == 0)
                    Teta(i+7,j+7) = 0;
                    
               elseif (Gxy(i+7,j+7,1) > 0) && (Gxy(i+7,j+7,2) > 0)
                    Teta(i+7,j+7) = atan(Gxy(i+7,j+7,2)/Gxy(i+7,j+7,1));
                    
               elseif (Gxy(i+7,j+7,1) > 0) && (Gxy(i+7,j+7,2) < 0)
                    Teta(i+7,j+7) = 2*pi + atan(Gxy(i+7,j+7,2)/Gxy(i+7,j+7,1));
                    
               elseif (Gxy(i+7,j+7,1) < 0) && (Gxy(i+7,j+7,2) < 0)
                    Teta(i+7,j+7) = pi + atan(Gxy(i+7,j+7,2)/Gxy(i+7,j+7,1));
                    
               elseif (Gxy(i+7,j+7,1) < 0) && (Gxy(i+7,j+7,2) > 0)
                    Teta(i+7,j+7) = pi + atan(Gxy(i+7,j+7,2)/Gxy(i+7,j+7,1));
               end
               
               % Affichage des gradients
%                hold on;   
%                quiver(x,y,Gxy(i+7,j+7,1),Gxy(i+7,j+7,2),'r');
%                hold off;   
           end
       end
    end
    
    % Calcul de l'orientation priviliegie. On discretise l'espace 2pi en 
    % 40 orientations de pas pi/20 (2pi = 40*pi/20)
    score = zeros(40, 2);

    for k = 0:39
        
        teta = k*pi/20;

        % Cercle autour du point d'interet
        for i = -6:6
           for j = -6:6
               if i^2+j^2 <= 36
                    % Si l'orientation du gradient au point (i,j) autour du 
                    % point d'interet est proche de teta, on ajoute un 
                    % point au score de teta
                    if (Teta(i+7,j+7) > (teta-pi/6)) && (Teta(i+7,j+7) < (teta+pi/6))                   
                        score(k+1,:) = score(k+1,:)+[Gxy(i+7,j+7,1) Gxy(i+7,j+7,2)] ;
                    end
               end
           end
        end
    end
    
    for tmp = 1:40
        result(tmp) = norm(score(tmp,:));
    end
    
    K = find(result == max(result));
    
    % Orientation privilegie du gradient
    TetaOptimal(n) = (K(1)-1)*pi/20;

end

toc

disp('Calcul du descripteur en chaque point d''interet ...');

tic
    
% On itere sur les points d'interets
for n = 1:size(Points,1)

    % Point d'interet 
    point = Points(n,:);
    y_pi = point(3);
    x_pi = point(4);
    
    % Variables d'echelle
    sigma = ceil(0.4*L(point(5)));
    l = ceil(0.8*L(point(5)));
    
    % Fenetre de ponderation gaussienne
    w = fspecial( 'gaussian', 20, 3.3*sigma );    
    
    % Matrice de rotation de la base canonique (x,y) a la base (u,v) obtenue 
    % a partir de l'orientation privilegiee du gradient.
    R = [cos(TetaOptimal(n)) -sin(TetaOptimal(n)); sin(TetaOptimal(n)) cos(TetaOptimal(n))];
    
    % Initialisation de la matrice contenant les gradients selon x et y 
    % sur une grille de 20*20 points autour du point d'interet.
    Gxy = zeros(20, 20, 2);    
    
    % Affichage de l'orientation privilegiee du gradient
%     hold on;
%     plot(x_pi,y_pi,'r+');
%     quiver(x_pi,y_pi,100*cos(TetaOptimal(n)),100*sin(TetaOptimal(n)));
%     hold off;

    % Grille de 20*20 points autour du point d'interet
    for i = -10:9
        for j = -10:9
            
            % Grille centree autour du point d'interet
            x = i + 1/2;
            y = j + 1/2;

            % Coordonnées dans le repere de direction privilegie du
            % gradient. On applique la rotation et la translation.
            X = sigma*R*[x y]' + [x_pi y_pi]';
            
            % Voisin le plus proche
            x = round(X(1));
            y = round(X(2));

            % Affichage de la grille de 20*20 points
            % plot(x,y,'go')

            % Calcul du gradient en x y
            Gx = iI(y+l,x-1)+iI(y-l,x-l)-iI(y-l,x-1)-iI(y+l,x-l) ...
                -(iI(y+l,x+l)+iI(y-l,x+1)-iI(y-l,x+l)-iI(y+l,x+1));

            Gy = iI(y-1,x+l)+iI(y-l,x-l)-iI(y-l,x+l)-iI(y-1,x-l) ...
                -(iI(y+l,x+l)+iI(y+1,x-l)-iI(y+1,x+l)-iI(y+l,x-l));
            
            % On calcul les coordonnes du gradient dans le repere de la
            % direction privilegie du gradient, pondere par w.
            U = R\[Gx Gy]';
            
            Gxy(i+11,j+11,1) = U(1)*w(i+11,j+11);
            Gxy(i+11,j+11,2) = U(2)*w(i+11,j+11);
        end
    end
    
    tmp_descriptor = zeros(16,4);
    
    % On subdivise la grille en 16 régions, puis on effectue des
    % statistiques sur le gradient pour chacune des regions.
    for u = 1:4
        for v = 1:4
            for i = 1:5
                for j = 1:5
                    
                    % Pour chaque region on calcule les coordonnes des 25 points la
                    % composant
                    x = 5*(u-1) + i;
                    y = 5*(v-1) + j;

                    % Maj des statistiques pour la region concerne 
                    tmp_descriptor(4*(u-1)+v,1) = tmp_descriptor(4*(u-1)+v,1) + Gxy(x,y,1);
                    tmp_descriptor(4*(u-1)+v,2) = tmp_descriptor(4*(u-1)+v,2) + Gxy(x,y,2);
                    tmp_descriptor(4*(u-1)+v,3) = tmp_descriptor(4*(u-1)+v,3) + abs(Gxy(x,y,1));
                    tmp_descriptor(4*(u-1)+v,4) = tmp_descriptor(4*(u-1)+v,4) + abs(Gxy(x,y,2));
                end
            end
        end
    end
    
    tmp_descriptor = reshape(tmp_descriptor',[1 64]);
    tmp_descriptor = tmp_descriptor/norm(tmp_descriptor);
   
    Descriptor(n,:) = tmp_descriptor; 
end

toc

end

