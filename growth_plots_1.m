%%
%--Objective:
%       A no-nonsense function to plot 96-well plate data. If you've
%       grouped your rows or columns nonconsecutively or in weird shapes, that's nonsense and this
%       function won't help you.
%--Inputs:
%       DataNames [Cell Array]: A cell array of strings that provides
%            the file names for the data. e.g. {'AllResults_Plate 1_CPU', 'AllResults_Plate 2_CPU'}
%       Path [String]: The file path to the data.
%       Hank [Bool]: A bool value specifying if you're processing a Hank
%          plate or something else.
%       HDim [Array]: An array that specifies row groupings.
%       VDim [Array]: An array that specifies column groupings.
%       dt [Int]: The amount of time between timepoints.
%       ori [Int]: ori = 0 -> No merging. ori = 1 -> Merge down columns. ori = 2 -> Merge across rows.
%       nLog [Bool]: nLog = 1 -> Plot the log normalized data.
%       std [Bool]: std = 1 -> Plot error bars at 1 standard deviation on the error between wells.
%--Outputs:
%       One standard plot.

%%
%Settings
DataNames = {'PLATE NAMES'};
Path = './Edit/';
Hank = 1;

dt = 2;
ori = 0;
nLog = 0;
std = 0;
HDim = [3 3];
VDim = ones(1,10);

%Only Edit if you know what you're doing.-----------------------------------
CF = 11.38;
getvals = dlmread([Path DataNames{1}]);
rows = sum(HDim);
columns = sum(VDim);
timeSteps = max(getvals(:,2));
reps = max(getvals(:,3));
channels = 2;

Data = stacker_v1(rows, columns, timeSteps, reps, channels, Path, DataNames , CF);
%If you want to rearrange the rows and columns, then this is the place to
%do it. Be careful.

if numel(DataNames)>1
    Data = squeeze(mean(Data,ndims(Data)));
end
if reps > 1
    Data = squeeze(mean(Data,4));
end
flat = Data(:,:,:,1)-Data(:,:,:,2);

if nLog == 1
    flat = flat./flat(:,:,1);
end

if ~Hank
    %This flips every other rows' data
    flat(2:2:end,:,:) = flip(flat(2:2:end,:,:),2);
end

[mn,stdev] = matrixstats_v3(flat, HDim, VDim);

%Break up plate into specified groupings.
[nr,nc,nt] = size(mn);
switch ori
    case 1
        %Merge down columns
        mnT = mat2cell(mn,nr,ones(1,nc),nt);
        stdevT = mat2cell(stdev,nr,ones(1,nc),nt);
        sups_title = 'Merged Down Columns';
    case 2
        %Merge along rows
        mnT = mat2cell(mn,ones(1,nr),nc,nt);
        stdevT = mat2cell(stdev,ones(1,nr),nc,nt);
        sups_title = 'Merged Across Rows';
    otherwise
        %No merge
        mnT = mat2cell(mn,ones(1,nr),ones(1,nc),nt);
        stdevT = mat2cell(stdev,ones(1,nr),ones(1,nc),nt);
        sups_title = 'Full Plate No Merging';
end

%Plot Settings
fig = figure(1);
p = uipanel('Parent',fig,'BorderType','none'); 
p.Title = sups_title;
p.TitlePosition = 'centertop'; 
p.FontSize = 14;
p.FontWeight = 'bold';

%Loop through each grouping.
[nr,nc,nt] = size(mnT);
for r = 1:nr
    for c = 1:nc
        idx = sub2ind([nr,nc],r,c);
        subplot(nr,nc,sub2ind([nc,nr],c,r),'parent',p)
        subData = mnT{idx};
        subDataErr = stdevT{idx};
        [nR,nC,nT] = size(subData);
        subCell = mat2cell(subData,ones(1,nR),ones(1,nC),nT);
        subCellErr = mat2cell(subDataErr,ones(1,nR),ones(1,nC),nT);
        
        %Within each grouping, plot each well.
        for i = 1:nR*nC
            if std == 0
                plot(dt*(0:nT-1),squeeze(cell2mat(subCell{i})))
            else                
                errorbar(dt*(0:nT-1),squeeze(cell2mat(subCell{i})),squeeze(cell2mat(subCellErr{i})))
            end
            %Subplot settings.
            ylim([min(flat(:)),max(flat(:))])
            xlim([0,dt*nT])
            xticks([0 dt*nT])
            xticklabels({'0 hrs',[num2str(dt*nT) 'hrs']})
            ylabel('Cell Growth')
            xlabel('Time [hrs]')
            %title(['R:' int2str(r) ' C:' int2str(c)])
            if nLog ==1
                set(gca,'yscale','Log')
                ylabel('NLog Cell Growth')
            end
            axis square
            hold on
        end
        hold off
    end
end