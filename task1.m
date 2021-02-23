clear all

%plot within the range
timeLims = [400,499];
% subtract mean when plotting
normalise = true;

% steel vase
displayObjTrialFinger("steelVase",0,1,timeLims,normalise);
% kitchen sponge
displayObjTrialFinger("kitchenSponge",0,1,timeLims,normalise);
% flour sack
displayObjTrialFinger("flourSack",0,1,timeLims,normalise);
% car sponge
displayObjTrialFinger("carSponge",0,1,timeLims,normalise);
% black foam
displayObjTrialFinger("blackFoam",0,1,timeLims,normalise);
% acrylic
displayObjTrialFinger("acrylic",0,1,timeLims,normalise);

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
        plot(p(first:last));
        plot(v(first:last));
        plot(t(first:last));
        for i=1:size(e,1)
            plot(e(i,first:last));
        end
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