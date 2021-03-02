clear all

%% B1

% part a
data = load("F0_PVT.mat");
[X,Y,Z] = getWholeData(data.PVT);
wholeData = [X,Y,Z];
stdWholeData = standardiseData(wholeData);
covMat = cov(stdWholeData)          % covariance matrix
[eigVecMat,eigValMat] = eig(covMat) % eigenvectors and eigenvalues

% part b
plotStandardised(stdWholeData, eigVecMat) % plot standardised data + vectors of Principal Components

% part c
proj2d = eigVecMat(:,end-1:end);
proj2dData = proj2d' * stdWholeData';
plotProj2d(proj2dData');

% part d
plotProj1d(stdWholeData,eigVecMat);



%% B2

% part a 
data = load("F0_Elecs.mat");
wholeData = getWholeDataElecs(data);
stdWholeData = standardiseData(wholeData);
covMat = cov(stdWholeData);          % covariance matrix
eigenvalues = eig(covMat) % eigenvalues
figure;
plot(length(eigenvalues):-1:1, eigenvalues);
ylabel("eigenvalues");
xlabel("Principal Component");
title("Scree plot");

% part b
[eigVecMat,eigValMat] = eig(covMat) % eigenvectors and eigenvalues
proj3d = eigVecMat(:,end-2:end);
proj3dData = proj3d' * stdWholeData'
plotProj3d(proj3dData',eigVecMat(:,end-2:end));


%% Helper functions

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

function stdData = standardiseData(data)
    stdData = data;
    for col=1:size(data,2)
        stdData(:,col) = (stdData(:,col) - mean(stdData(:,col))) ./ std(stdData(:,col));
    end
end

function plotStandardised(stdData,eigVecs)
    figure;
    X = stdData(:,1);
    Y = stdData(:,2);
    Z = stdData(:,3);
    colMap = load("colours.mat");
    colMap = colMap.coloursMap;
    objectsLst = load("objects.mat");
    objectsLst = objectsLst.objects;
    hold on;
    for n=0:5
        i=n*10+1;
        currObj = objectsLst(n+1);
        plot3(X(i:i+9),Y(i:i+9),Z(i:i+9),'+','Color',colMap(currObj));
    end
    zeroVec = zeros(1,3);
    quiver3(zeroVec,zeroVec,zeroVec,eigVecs(1,:),eigVecs(2,:),eigVecs(3,:),'ShowArrowHead','on');
    hold off;
    xlabel('P');
    ylabel('V');
    zlabel('T');
    title('Standardised data');
end

function plotProj2d(data)
    figure;
    X = data(:,2); % biggest component
    Y = data(:,1); % 2nd biggest component
    colMap = load("colours.mat");
    colMap = colMap.coloursMap;
    objectsLst = load("objects.mat");
    objectsLst = objectsLst.objects;
    hold on;
    for n=0:5
        i=n*10+1;
        currObj = objectsLst(n+1);
        plot(X(i:i+9),Y(i:i+9),'+','Color',colMap(currObj));
    end
    xlabel('PC1');
    ylabel('PC2');
    hold off;
    title('Projected on 2 principal components');
end

function plotProj1d(data,eigVecMat)
    figure;
    for PC=1:3
        eigVec = eigVecMat(:,4-PC); % obtain eigenvectors (starting from biggest which is indexed 3)
        % project data onto eigenvectors
        projData = eigVec' * data'; 

        X = projData'; % projected data
        Y = PC*ones(size(X,1),1); % plot the three sets on different lines
        colMap = load("colours.mat");
        colMap = colMap.coloursMap;
        objectsLst = load("objects.mat");
        objectsLst = objectsLst.objects;
        hold on;
        for n=0:5
            i=n*10+1;
            currObj = objectsLst(n+1);
            plot(X(i:i+9),Y(i:i+9),'+','Color',colMap(currObj));
        end
    end
    hold off;
    yticks([1 2 3])
    yticklabels({'PC1' 'PC2' 'PC3'})
    ylim([0,4]);
    title('1d projection on each PC');
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

function plotProj3d(data, eigVecs)
    figure;
    X = data(:,3); % biggest component
    Y = data(:,2); % 2nd biggest component
    Z = data(:,1); % 3rd biggest component
    colMap = load("colours.mat");
    colMap = colMap.coloursMap;
    objectsLst = load("objects.mat");
    objectsLst = objectsLst.objects;
    hold on;
    for n=0:5
        i=n*10+1;
        currObj = objectsLst(n+1);
        plot3(X(i:i+9),Y(i:i+9),Z(i:i+9),'+','Color',colMap(currObj));
    end
    hold off;
    xlabel('PC1');
    ylabel('PC2');
    zlabel('PC3');
    title('Projected on 3 principal components');
end
