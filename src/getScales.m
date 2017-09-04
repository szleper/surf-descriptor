function [ L ] = getScales()

% Echantillonnage des echelles d'analyse d'image
L = [];

% 4 octaves
for o = 1:4
    % 2 niveaux par octaves
    for i = 2:3
       % Echelles 
       L = [L 2^o*i+1]; 
    end
end

end

