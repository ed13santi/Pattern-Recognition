clear all
close all

PVT = load("F0_PVT.mat");

[X,Y,Z] = getWholeData(PVT.PVT);
wholeData = [X,Y,Z];
stdWholeData = standardiseData(wholeData);
scores = zeros(12,4);
distances = {'sqeuclidean', 'cityblock', 'cosine', 'correlation'};
colours = {'k','m','c','r','g','b'};
shapes = {'o', '^', '*', '+', 's', 'h', 'd', 'p', '.', 'x', 'v', '>', '<'};
plotable_cluster_numbers = containers.Map([2, 3, 6], [1, 2, 3]);
figure;
for distance = 1:4
    for cluster_number = 1:12
        [indeces,C,sumd] = kmeans(stdWholeData,cluster_number,'Distance',char(distances(distance)), 'OnlinePhase', 'on', 'Options', statset('UseParallel',1), 'Replicates', 15);
        score = sum(sumd);
        scores(cluster_number, distance) = score;

        if cluster_number == 2 || cluster_number == 3 || cluster_number == 6
            subplot(3, 4, plotable_cluster_numbers(cluster_number) * 4 + distance - 4);
            grid on;
            view([166.234884119522 28.6891719787526]);
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
end

figure;
for distance=1:4
subplot(2, 2, distance)
    hold on
    for i=1:12
        plot(i, scores(i, distance), '.',  'MarkerSize', 12, 'Color', 'b');
    end
    title("Elbow plot for distance: " + char(distances(distance)));
    xlabel("Number of Clusters");
    ylabel("Sum of distances");
    hold off
end

%% 2D Clustering with temperature and pressure

wholeData = [X,Z];
stdWholeData = standardiseData(wholeData);
colours = {'k','m','c','r','g','b'};
shapes = {'o', '^', '*', '+', 's', 'h', 'd', 'p', '.', 'x', 'v', '>', '<'};
[indeces,C,sumd] = kmeans(stdWholeData, 6,'Distance', 'sqeuclidean', 'OnlinePhase', 'on', 'Options', statset('UseParallel',1), 'Replicates', 15);
figure;
dummy_plot_handles = zeros(6, 1);
dummy_plot_handles(1) = plot(0,0, '-','Color', char(colours(1))); 
hold on
dummy_plot_handles(2) = plot(0,0, '-','Color', char(colours(2)));
dummy_plot_handles(3) = plot(0,0, '-','Color', char(colours(3)));
dummy_plot_handles(4) = plot(0,0, '-','Color', char(colours(4)));
dummy_plot_handles(5) = plot(0,0, '-','Color', char(colours(5)));
dummy_plot_handles(6) = plot(0,0, '-','Color', char(colours(6)));
for i=1:60
    plot(stdWholeData(i,1), stdWholeData(i, 2), char(shapes(indeces(i))), 'MarkerSize', 7, 'Color', char(colours(fix((i-1)/10)+1)))
end
title("2D K-Means, 6 Clusters, square euclidean distance");
xlabel("Pressure");
ylabel("Temperature"); 
l = legend(dummy_plot_handles, "Steel Vase", "Kitchen Sponge", "Flour Sack", "Car Sponge", "Black Foam", "Acrylic");
l.Location = 'best';
hold off

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
