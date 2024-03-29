%% Colours of each object in graphs
colours =   {'k','m','c','r','g','b'};
objects = {'steelVase', 'kitchenSponge', 'flourSack', 'carSponge', 'blackFoam', 'acrylic'};
coloursMap = containers.Map(objects, colours);
save('colours.mat','coloursMap');

%% Order of objects
index =   {1,2,3,4,5,6};
objects = {'steelVase', 'kitchenSponge', 'flourSack', 'carSponge', 'blackFoam', 'acrylic'};
objects = containers.Map(index, objects);
save('objects.mat','objects');
