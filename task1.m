clear all


%% A1

%plot within the range
timeLims = [400,499];
% subtract mean when plotting
normalise = false;

displayObjTrialFinger("steelVase",     0,1,timeLims,normalise);
displayObjTrialFinger("kitchenSponge", 0,1,timeLims,normalise);
displayObjTrialFinger("flourSack",     0,1,timeLims,normalise);
displayObjTrialFinger("carSponge",     0,1,timeLims,normalise);
displayObjTrialFinger("blackFoam",     0,1,timeLims,normalise);
displayObjTrialFinger("acrylic",       0,1,timeLims,normalise);


%% A2

% CHOOSE TIME STEP AND FINGER
time_step = 700;
finger = 0;

PVT = struct;
PVT.steelVase = addObjectPVT("steelVase",finger, time_step);
PVT.kitchenSponge = addObjectPVT("kitchenSponge",finger, time_step);
PVT.flourSack = addObjectPVT("flourSack",finger, time_step);
PVT.carSponge = addObjectPVT("carSponge",finger, time_step);
PVT.blackFoam = addObjectPVT("blackFoam",finger, time_step);
PVT.acrylic = addObjectPVT("acrylic",finger, time_step);
save(['F',num2str(finger),'_PVT.mat'], 'PVT');

Elecs = struct;
Elecs.steelVase = addObjectE("steelVase",finger, time_step);
Elecs.kitchenSponge = addObjectE("kitchenSponge",finger, time_step);
Elecs.flourSack = addObjectE("flourSack",finger, time_step);
Elecs.carSponge = addObjectE("carSponge",finger, time_step);
Elecs.blackFoam = addObjectE("blackFoam",finger, time_step);
Elecs.acrylic = addObjectE("acrylic",finger, time_step);
save(['F',num2str(finger),'_Elecs.mat'], 'PVT');

%% A3

PVT = load(['F',num2str(finger),'_Elecs.mat'], 'PVT');

figure;
plotBranch(PVT.PVT.steelVase,'steelVase');
hold on;
plotBranch(PVT.PVT.kitchenSponge,'kitchenSponge');
plotBranch(PVT.PVT.flourSack,'flourSack');
plotBranch(PVT.PVT.carSponge,'carSponge');
plotBranch(PVT.PVT.blackFoam,'blackFoam');
plotBranch(PVT.PVT.acrylic,'acrylic');
hold off;
xlabel('P');
ylabel('V');
zlabel('T');



%% HELPER FUNCTIONS

function out = displayObjTrialFinger(object, finger, trial, timeLims, normalise)
    [pres,vibr,temp,elecs] = extractData(object, finger, trial);
    out = display(pres,vibr,temp,elecs,object,timeLims,normalise);
end

function out = display(p,v,t,e,titleText,timeLims,normalise)
    first = timeLims(1);
    last = timeLims(2);

    figure('NumberTitle', 'off', 'Name', titleText);
    hold on;
    if normalise  
        plot(normalised(p(first:last)));
        plot(normalised(v(first:last)));
        plot(normalised(t(first:last)));
        for i=1:size(e,1)
            plot(normalised(e(i,first:last)));
        end
    else    
        subplot(4,1,1);
        plot(p(first:last));
        subplot(4,1,2);
        plot(v(first:last));
        subplot(4,1,3);
        plot(t(first:last));
        subplot(4,1,4);
        hold on;
        for i=1:size(e,1)
            plot(e(i,first:last));
        end
        hold off;
    end
    hold off;   
    out = [];
end


function [pres,vibr,temp,elecs] = extractData(object, finger, trial) 
    keys =   {'steelVase',      'kitchenSponge',      'flourSack',      'carSponge',      'blackFoam',      'acrylic'};
    values = {'steel_vase_702', 'kitchen_sponge_114', 'flour_sack_410', 'car_sponge_101', 'black_foam_110', 'acrylic_211'};
    fileNamesMap = containers.Map(keys, values);
    numbersMap = containers.Map({1,2,3,4,5,6,7,8,9,10},{'01', '02', '03', '04', '05', '06', '07', '08', '09', '10'});
    fileName = [fileNamesMap(object), '_', numbersMap(trial), '_HOLD'];
    path = fullfile("data",fileName);
    data = load(path);
    
    
    fingersMap = containers.Map({0,1},{'00', '01'});
    fingerStr = fingersMap(finger);
    if finger == 0
        pres = data.F0pdc;
        vibrAll = data.F0pac;
        vibr = vibrAll(2,:);
        temp = data.F0tdc;
        elecs = data.F0Electrodes;
    end
    if finger == 0
        pres = data.F1pdc;
        vibrAll = data.F1pac;
        vibr = vibrAll(2,:);
        temp = data.F1tdc;
        elecs = data.F1Electrodes;
    end
end

function normalised = normalised(seq)
    normalised = (seq - mean(seq)) / std(seq);
end

function [P,V,T,E] = extractTimeStepPVT(object, finger, trial, time)
    [pres,vibr,temp,elecs] = extractData(object, finger, trial);
    P = pres(time);
    V = vibr(time);
    T = temp(time);
    E = elecs(:,time);
end    

function trials = addObjectPVT(object, finger, time)
    trials = [];
    for trial=1:10
        [P,V,T,~] = extractTimeStepPVT(object, finger, trial, time);
        tmp_trial.P = P;
        tmp_trial.V = V;
        tmp_trial.T = T;
        trials = [trials, tmp_trial];
    end
end

function trials = addObjectE(object, finger, time)
    trials = [];
    for trial=1:10
        [~,~,~,Elecs] = extractTimeStepPVT(object, finger, trial, time);
        trials = [trials, Elecs];
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
        