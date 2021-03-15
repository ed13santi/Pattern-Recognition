clear all
close all


%% PART 1

PVT = load("F0_PVT.mat");

[X,Y,Z] = getWholeData(PVT.PVT);
wholeData = [X,Y,Z];
stdWholeData = standardiseData(wholeData);
scores = zeros(12,1);
distances = {'sqeuclidean', 'cityblock', 'cosine', 'correlation'};
plotable_cluster_numbers = containers.Map([2, 3, 6], [1, 2, 3]);
figure;
for distance = 1:4
    for cluster_number = 1:12
        [indeces,C,sumd] = kmeans(stdWholeData,cluster_number,'Distance',char(distances(distance)), 'OnlinePhase', 'on', 'Options', statset('UseParallel',1), 'Replicates', 15);
        score = sum(sumd);
        scores(cluster_number) = score;

        if cluster_number == 2 || cluster_number == 3 || cluster_number == 6
            subplot(4, 4, plotable_cluster_numbers(cluster_number) * 4 + distance - 4);
            colours = {'k','m','c','r','g','b'};
            shapes = {'o', '^', '*', '+', 's', 'h', 'd', 'p', '.', 'x', 'v', '>', '<'};
            dummy_plot_handles = zeros(6, 1);
            dummy_plot_handles(1) = plot3(0,0,0, '-','Color', char(colours(1))); 
            hold on
            dummy_plot_handles(2) = plot3(0,0,0, '-','Color', char(colours(2)));
            dummy_plot_handles(3) = plot3(0,0,0, '-','Color', char(colours(3)));
            dummy_plot_handles(4) = plot3(0,0,0, '-','Color', char(colours(4)));
            dummy_plot_handles(5) = plot3(0,0,0, '-','Color', char(colours(5)));
            dummy_plot_handles(6) = plot3(0,0,0, '-','Color', char(colours(6)));
            grid on;
            for i=1:60
                plot3(stdWholeData(i,1), stdWholeData(i, 2), stdWholeData(i, 3), char(shapes(indeces(i))), 'MarkerSize', 7, 'Color', char(colours(fix((i-1)/10)+1)))
            end
            title("Number of clusters: " + cluster_number + ", Distance: " + char(distances(distance)));
            xlabel("Pressure")
            ylabel("Vibration")
            zlabel("Temperature")
            hold off
        end
    end
    subplot(4, 4, 12+distance)
    hold on
    for i=1:12
        plot(i, scores(i), '.',  'MarkerSize', 12, 'Color', 'b');
    end
    xlabel("Number of Clusters");
    ylabel("Sum of distances");
    hold off
end

%hold on 
%l = legend(dummy_plot_handles, "Steel Vase", "Kitchen Sponge", "Flour Sack", "Car Sponge", "Black Foam", "Acrylic");
%l.Location = 'northeastoutside';
%hold off

figure;
hold on
for i=1:12
    plot(i, scores(i), '.',  'MarkerSize', 12, 'Color', 'b');
end
xlabel("Number of Clusters");
ylabel("Sum of distances");
hold off




%% PART 2

% load data and split into training and test data
data = load("3d_PCA_Electrodes.mat");
data = data.proj3dData;
[trainData, trainClasses, testData, testClasses] = splitData(data);

oobErrors = [];
for trial=1:100
% create trees trained on the training data
max_n_trees = 50;
Mdl = TreeBagger(max_n_trees,trainData',trainClasses','OOBPrediction','On','Method','classification');

% store out of bag error for trial
oobErrorBaggedEnsemble = oobError(Mdl);
oobErrors = [oobErrors, oobErrorBaggedEnsemble];
end

% display out of bag error for different numbers of trees
figure;
plot(mean(oobErrors,2));
xlabel 'Number of grown trees';
ylabel 'Average out-of-bag classification error';

% create new model using optimal number of trees
n_trees = 20;
tic
Mdl = TreeBagger(n_trees,trainData',trainClasses','OOBPrediction','On','Method','classification');
toc

% view 2 trees
figure;
view(Mdl.Trees{1},'Mode','graph');
view(Mdl.Trees{2},'Mode','graph');

% predict using trained ensemble on the test data
tic
Y = predict(Mdl, testData');
toc
Y = convertCharsToStrings(Y);
confusionchart(testClasses', Y);

% do again but skipping PCA and using random projections
clear all

data = load("F0_Elecs.mat");
wholeData = getWholeDataElecs(data);
stdWholeData = standardiseData(wholeData);
[trainData, trainClasses, testData, testClasses] = splitData(stdWholeData');
n_trees = 20;
tic
Mdl = TreeBagger(n_trees,trainData',trainClasses','OOBPrediction','On','Method','classification');
toc
tic
Y = predict(Mdl, testData');
toc
Y = convertCharsToStrings(Y);
confusionchart(testClasses', Y);


%% HELPER FUNCTIONS

function stdData = standardiseData(data)
    stdData = data;
    for col=1:size(data,2)
        stdData(:,col) = (stdData(:,col) - mean(stdData(:,col))) ./ std(stdData(:,col));
    end
end

function [X,Y,Z] = getWholeData(data)
    X = [];
    Y = [];
    Z = [];
    [X,Y,Z] = appendObjTrial(X,Y,Z,data.steelVase);
    [X,Y,Z] = appendObjTrial(X,Y,Z,data.kitchenSponge);
    [X,Y,Z] = appendObjTrial(X,Y,Z,data.flourSack);
    [X,Y,Z] = appendObjTrial(X,Y,Z,data.carSponge);
    [X,Y,Z] = appendObjTrial(X,Y,Z,data.blackFoam);
    [X,Y,Z] = appendObjTrial(X,Y,Z,data.acrylic);
end

function [X,Y,Z] = appendObjTrial(X,Y,Z,objData)
    for trial=1:10
        trialData = objData(trial);
        X = [X; trialData.P];
        Y = [Y; trialData.V];
        Z = [Z; trialData.T];
    end
end

function [X,Y,Z] = getCoords(PVTbranch,trial)
    X = PVTbranch(trial).P;
    Y = PVTbranch(trial).V;
    Z = PVTbranch(trial).T;
end

function plotBranch(PVTbranch,object)
    X = [];
    Y = [];
    Z = [];
    for trial=1:10
        [x,y,z] = getCoords(PVTbranch,trial);
        X = [X;x];
        Y = [Y;y];
        Z = [Z;z];
    end
    coloursMap = load('colours.mat');
    plot3(X,Y,Z,'+','Color',coloursMap.coloursMap(object));
end

function [trainData, trainClasses, testData, testClasses] = splitData(data)
    classes = ["steel vase", "kitchen sponge", "flour sack", "car sponge", "black foam", "acrylic"];
    trainData = [];
    testData = [];
    trainClasses = [];
    testClasses = [];
    for i=1:6
        indexes = randperm(10);
        trainIndexes = (i-1)*10 + indexes(1:6);
        trainData = [trainData, data(:,trainIndexes)];
        trainClasses = [trainClasses, classes(i), classes(i), classes(i), classes(i), classes(i), classes(i) ];
        testIndexes = (i-1)*10 + indexes(7:10);
        testData = [testData, data(:,testIndexes)];
        testClasses = [testClasses, classes(i), classes(i), classes(i), classes(i)];
    end
end

function wholeData = getWholeDataElecs(data)
    data = data.Elecs;
    wholeData = [];
    wholeData = [wholeData; data.steelVase'];
    wholeData = [wholeData; data.kitchenSponge'];
    wholeData = [wholeData; data.flourSack'];
    wholeData = [wholeData; data.carSponge'];
    wholeData = [wholeData; data.blackFoam'];
    wholeData = [wholeData; data.acrylic'];
end