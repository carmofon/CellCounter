%%
%--Objective:
%       A simple function for plotting multiple bar plots with different
%       conditions. It allows you to plot multiple different cell lines
%       with each line having its own row and timepoint of choice. It
%       automatically combines statistical replicates (images within one
%       well).
%--Inputs:
%       DataNames [Cell Array]: A cell array of strings that provides
%            the file names for the data. e.g. {'AllResults_Plate 1_CPU', 'AllResults_Plate 2_CPU'}
%       Path [String]: The file path to the data.
%       CellLines [Cell Array]: Contains the names of each cell line.
%       Conditions [Cell Array]: The names of each condition.
%       LineGrps [Cell Array]: A cell array that specifies an id unique
%       to each cell line. For example, if you have 2 MDA and 3 TOM,
%       LineGrps = [1 1 2 2 2];
%       rows [Int]: The number of rows.
%       VDim [Array]: An array that specifies treatment groupings.
%       timePoints [Array]: An array with one value FOR EACH CELL LINE,
%       specifying the timepoint to plot in the bar graph.
%       rowPoints [Array]: An array with one value FOR EACH CELL LINE,
%       specifying the row (cell density) to plot in the bar graph.
%       colorGroup [Array]: An matrix with RGB values for each row for each
%       condition.
%--Outputs:
%       One plot.


DataNames = {'Data_1','Data_2'};
Path = './Edit/';
CellLines = {'Line 1','Line 1'};
Conditions = {'Treat 1','Treat 2','Treat 2','Treat 4','Treat 5'};

LineGrps = [1 2]; %Saying Data 1 and Data 2 are distinct lines.
rows = 8; %Number of rows for the well.
VDim = [2 2 2 2 2]; %Assuming two adjacent duplicates.

%Specify a timepoint and row for each cell line.
timePoints = [1,10]; %Display the first cell line at time 1 and second at time 10.
rowPoints = [3,6]; %Display the first cell line at row 3 and second at row 6.

%The colors Carlos likes.
colorGroup = [0    0.4470    0.7410
                0.8500    0.3250    0.0980
                0.9290    0.6940    0.1250
                0.4940    0.1840    0.5560
                0.4660    0.6740    0.1880
                0.3010    0.7450    0.9330
                0.6350    0.0780    0.1840];

%Only Edit if you know what you're doing.-----------------------------------
for LineGroup = 1:max(LineGrps)
    subplot(1,max(LineGrps),LineGroup)
    %Settings for making stack
    CF = 11.38;
    getvals = dlmread([Path DataNames{1}]);
    columns = sum(VDim);
    timeSteps = max(getvals(:,2));
    reps = max(getvals(:,3));
    channels = 2;
    
    %Only grab plates for the same line
    LineData = DataNames(LineGrps==LineGroup);
    Data = stacker_v1(rows, columns, timeSteps, reps, channels, Path, LineData, CF);    
    %Merge replicates within same well
    if reps > 1
        Data = squeeze(mean(Data,4));
    end
    flat = squeeze(Data(:,:,:,1,:)-Data(:,:,:,2,:));
    [nr,nc,nt,np] = size(flat);    
    
    %Break up plate into specified groupings.
    Groups = mat2cell(flat,nr,VDim,nt,np);
    Gnum = numel(Conditions);
    for g = 1:Gnum
        groupData = Groups{g}(rowPoints(LineGroup),:,[1,timePoints(LineGroup)],:);
        groupData = groupData(1,:,2,:)./groupData(1,:,1,:);
        groupMean = mean(groupData(:));
        groupStd = std(groupData(:));
        hold on
        bar(g,groupMean,'facecolor',colorGroup(g,:))
        hold on
        scatter(normrnd(g,0.05,[1,length(groupData(:))]),groupData(:),'.k')
        hold on
        errorbar(g,groupMean,groupStd,'k')
    end
    title(CellLines{LineGroup})
    line([0 Gnum+1],[1 1],'color',[0 0 0],'linestyle','--')
    xticks(1:Gnum)
    xticklabels(Conditions)
    axis square
end