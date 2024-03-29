clear all
close all

data = load("F0_PVT.mat");
blackFoam = data.PVT.blackFoam;
carSponge = data.PVT.carSponge;

%% Part 1.a

pressure_all = vertcat(blackFoam.P, carSponge.P);
vibration_all = vertcat(blackFoam.V, carSponge.V);
temperature_all = vertcat(blackFoam.T, carSponge.T);
VTstd = standardiseData([vibration_all, temperature_all]);
VPstd = standardiseData([vibration_all, pressure_all]);
TPstd = standardiseData([temperature_all, pressure_all]);
PVTstd = standardiseData([pressure_all, vibration_all, temperature_all]);


LDATwoVariables('blackFoam', 'carSponge', "Vibration", "Temperature", VTstd(:,1), VTstd(:,2));
LDATwoVariables('blackFoam', 'carSponge', "Vibration", "Pressure", VPstd(:,1), VPstd(:,2));
LDATwoVariables('blackFoam', 'carSponge', "Temperature", "Pressure", TPstd(:,1), TPstd(:,2));

%% Part 1.b

LDAThreeVariables('blackFoam', 'carSponge', PVTstd(:,1), PVTstd(:,2), PVTstd(:,3));

%% Part 1.d
steelVase = data.PVT.steelVase;
flourSack = data.PVT.flourSack;

pressure_all = vertcat(steelVase.P, flourSack.P);
vibration_all = vertcat(steelVase.V, flourSack.V);
temperature_all = vertcat(steelVase.T, flourSack.T);

VTstd = standardiseData([vibration_all, temperature_all]);
VPstd = standardiseData([vibration_all, pressure_all]);
TPstd = standardiseData([temperature_all, pressure_all]);
PVTstd = standardiseData([pressure_all, vibration_all, temperature_all]);

LDATwoVariables('steelVase', 'flourSack', "Vibration", "Temperature", VTstd(:,1), VTstd(:,2));
LDATwoVariables('steelVase', 'flourSack', "Vibration", "Pressure",  VPstd(:,1), VPstd(:,2));
LDATwoVariables('steelVase', 'flourSack', "Temperature", "Pressure",  TPstd(:,1), TPstd(:,2));

LDAThreeVariables('steelVase', 'flourSack', PVTstd(:,1), PVTstd(:,2), PVTstd(:,3));


%% Helper functions

function LDATwoVariables(object1, object2, varName1, varName2, data1, data2)
    coloursMap = load('colours.mat');
    coloursMap = coloursMap.coloursMap;
    figure;
    grid on
    hold on
    classLables = cell(20,1);
    classLables(1:10) = {object1};
    classLables(11:end) = {object2};
    h1 = gscatter(data1, data2, classLables);
    h1(1).Color=coloursMap(object1);
    h1(2).Color=coloursMap(object2);
    h1(1).LineWidth = 2;
    h1(2).LineWidth = 2;
    legend(object1, object2, 'Location','best')

    MdlLinear = fitcdiscr([data1, data2],classLables);

    A = MdlLinear.Coeffs(1,2).Const;  
    B = MdlLinear.Coeffs(1,2).Linear;

    separationLine = @(x,y) A + B(1)*x + B(2)*y;
    linePlot = fimplicit(separationLine);
    linePlot.LineWidth = 2;
    linePlot.DisplayName = 'Separation line';

    LDALine = @(x,y) A - B(1)*y + B(2)*x;
    linePlot2 = fimplicit(LDALine);
    linePlot2.LineWidth = 2;
    linePlot2.DisplayName = "LDA";
    
    max_lim = max(max(data1)-min(data1), max(data2)-min(data2));
    xlim([min(data1)-0.1, min(data1)+max_lim+0.1]);
    ylim([min(data2)-0.1, min(data2)+max_lim+0.1]);

    xlabel(varName1)
    ylabel(varName2)
end

function LDAThreeVariables(object1, object2, data1, data2, data3)
    coloursMap = load('colours.mat');
    coloursMap = coloursMap.coloursMap;
    figure;
    view(3)
    grid on
    hold on

    plot3(data1(1:10), data2(1:10), data3(1:10), '.', 'color', coloursMap(object1), 'markersize', 15, 'DisplayName', object1);
    plot3(data1(11:end), data2(11:end), data3(11:end), '.', 'color', coloursMap(object2), 'markersize', 15, 'DisplayName', object2);
    legend('Location','best')

    classLables = cell(20,1);
    classLables(1:10) = {object1};
    classLables(11:end) = {object2};
    MdlLinear = fitcdiscr([data1, data2, data3],classLables);

    lineCoeffs = MdlLinear.Coeffs(2,1);  
    A = lineCoeffs.Const;
    B = lineCoeffs.Linear;
    start = 500 .* B';
    finish = -500 .* B';
    coords = [start; finish];
    linePlot = plot3(coords(:,1),coords(:,2),coords(:,3), 'color', 'blue');
    linePlot.LineWidth = 3;
    linePlot.DisplayName = "LDA";
    
    max_lim = max([max(data1)-min(data1), max(data2)-min(data2), max(data3)-min(data3)]);
    xlim([min(data1)-0.1, min(data1)+max_lim+0.1]);
    ylim([min(data2)-0.1, min(data2)+max_lim+0.1]);
    zlim([min(data3)-0.1, min(data3)+max_lim+0.1]);

    separationPlane = @(x,y,z) A + B(1)*x + B(2)*y + B(3)*z;
    planePlot = fimplicit3(separationPlane, 'FaceAlpha',.3);
    planePlot.DisplayName = "Separation Plane";
    
    xlabel("Pressure")
    ylabel("Vibration")
    zlabel("Temperature")

end


function stdData = standardiseData(data)
    stdData = data;
    for col=1:size(data,2)
        stdData(:,col) = (stdData(:,col) - mean(stdData(:,col))) ./ std(stdData(:,col));
    end
end
