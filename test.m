% On a pre-enregistre les features des images de notre base de donnes
% Ces images sont stockes dans le dossier 'photos'.
load db_features.mat;

% Chaque ligne de db_features et compose de 65 colonnes. Les 64 premieres 
% colonnes sont le descripteur, et la 65 colonne est le label associe.  

% On teste l'algorithme avec une image
I = rgb2gray(imresize(imread('test_clef.jpg'),0.5)); 

% Detection et selection de point d'interets
Points  = detectFeatures(I);

% Affichage des points d'interets
showFeatures(I,Points,20);

% Extraction de descripteurs 
Descriptor = extractFeatures( I, Points(1:20,:));

% Comparaison des descripteurs à ceux de notre base de donnes.
Distance = matchFeatures( Descriptor, db_features(:,1:64));

% Seuillage des distances 
Result = Distance < 0.4;

% Recuperation des indexes des features de la base de donnees proches des 
% features de l'image test
idxs = find(any(Result == 1));

% On regarde quel est le label le plus present parmi les features de la
% base de donnees proches des features de l'image test 
label = mode(db_features(idxs,65));

if label == 1
    type = 'clef';
elseif label == 2
    type = 'couteau';   
elseif label == 3
    type = 'portable';
end

disp('L''objet reconnu est :');
disp(type);