tic

folder = 'photos';

list_clef = dir(strcat(folder, '/clef*'));          
list_couteau = dir(strcat(folder, '/couteau*'));
list_portable = dir(strcat(folder, '/portable*'));

label_clef = 1;
label_couteau = 2;
label_portable = 3;

db_features = [];

for i = 1:length(list_clef) 
    I = rgb2gray(imread(strcat(folder,'/', list_clef(i).name))); 
    Points  = detectFeatures(I);
    Descriptor = extractFeatures( I, Points(1:20,:));
    Descriptor(:,end+1) = label_clef;
    db_features = [db_features; Descriptor]; 
end

for i = 1:length(list_couteau)
    I = rgb2gray(imread(strcat(folder,'/', list_couteau(i).name))); 
    Points  = detectFeatures(I);
    Descriptor = extractFeatures( I, Points(1:20,:));
    Descriptor(:,end+1) = label_couteau;
    db_features = [db_features; Descriptor]; 
end

for i = 1:length(list_portable)
    I = rgb2gray(imread(strcat(folder,'/', list_portable(i).name))); 
    Points  = detectFeatures(I);
    Descriptor = extractFeatures( I, Points(1:20,:));
    Descriptor(:,end+1) = label_portable;
    db_features = [db_features; Descriptor]; 
end

toc