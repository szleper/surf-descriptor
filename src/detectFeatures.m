function [ Points ] = detectFeatures( I )

% Detecte les points d'interets dans l'image img. Renvoie un tableau 
% ordonne de points [Doh sign y x i], avec Doh la valeure absolue du 
% determinant de la matrice hessienne, sign le signe du Doh, y et x les 
% coordonnees du point et i l'echelle.

tic

% Calcul de l'image integrale pour la performance
iI = integralImage(I);

% Echelles d'analyse de l'image
L = getScales();

% Calcul du determinant de la matrice hessienne en chaque point de l'image
% pour les differentes echelles L

disp('Calcul du determinant de la matrice hessienne en chaque point ...');

% Initialisation de la matrice contenant les determinants 
[y_length, x_length] = size(I);
doh = zeros(y_length, x_length, length(L));

for i = 1:length(L)

    % Echelle l
    l = L(i);
    
    % Marge m
    m = (3*l-1)/2;
    
    % On parcours l'image en laissant une marge m
    for y = 1+m:(y_length-m)
        for x = 1+m:(x_length-m)
            
            Gxx = iI(y+l,x-(l-1)/2)+iI(y-l,x-m)-iI(y-l,x-(l-1)/2)-iI(y+l,x-m) ...
                -2*(iI(y+l,x+(l-1)/2)+iI(y-l,x-(l-1)/2)-iI(y-l,x+(l-1)/2)-iI(y+l,x-(l-1)/2)) ...
                + iI(y+l,x+m)+iI(y-l,x+(l-1)/2)-iI(y-l,x+m)-iI(y+l,x+(l-1)/2);
            
            Gyy = iI(y-(l-1)/2,x+l)+iI(y-m,x-l)-iI(y-(l-1)/2,x-l)-iI(y-m,x+l) ...
                -2*(iI(y+(l-1)/2,x+l)+iI(y-(l-1)/2,x-l)-iI(y+(l-1)/2,x-l)-iI(y-(l-1)/2,x+l)) ...
                + iI(y+m,x+l)+iI(y+(l-1)/2,x-l)-iI(y+m,x-l)-iI(y+(l-1)/2,x+l);

            Gxy = iI(y-1,x+l)+iI(y-l,x+1)-iI(y-1,x-1)-iI(y-l,x+l) ...
                + iI(y+l,x-1)+iI(y+1,x-l)-iI(y+1,x+1)-iI(y+l,x-l) ...
                -(iI(y+l,x+l)+iI(y+1,x+1)-iI(y+1,x+l)-iI(y+l,x+1)) ...
                -(iI(y-1,x-1)+iI(y-l,x-l)-iI(y-l,x-1)-iI(y-1,x-l));
            
            % On normalise en divisant par l^4 le determinant
            doh(y,x,i) = (1/l^4)*(Gxx*Gyy - (0.912*Gxy)^2);
            
        end
    end    
end

toc

tic

% Selection des points d'interets. Pour chaque point d'interet doh > 10^4
% et le doh doit etre un maximum local. (doh = determinant of hessian)

disp('Selection des points d''interets ...');

Points = [];

for i = 1:length(L)

    Doh = abs(doh(:,:,i));
    
    % Seuillage des determinants en chaque points
    Idxs = find(Doh > 10^4);
    
    % On parcourt les points obtenus
    for idx = Idxs'

        [n,m] = ind2sub([y_length x_length],idx);
            
        % On regarde si le determinant est un maximum local sur un carre 
        % 5x5
        tmp = Doh(n-5:n+5,m-5:m+5);
        
        if Doh(idx) == max(tmp(:))
            % On ajoute le point (n,m) a l'echelle i a nos points
            % d'interets
            Points = [Points; Doh(idx) doh(n,m,i)/Doh(idx) n m i];
        end 
    end
end

% On classe les points d'interets par ordre decroissant de la valeur du 
% determinant Doh.
Points = sortrows(Points,-1);

toc

end