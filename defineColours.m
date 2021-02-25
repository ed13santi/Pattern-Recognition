%% Colours of each object in graphs
colours =   {'k','m','c','r','g','b'};
objects = {'steelVase', 'kitchenSponge', 'flourSack', 'carSponge', 'blackFoam', 'acrylic'};
coloursMap = containers.Map(objects, colours);
save('colours.mat','coloursMap');