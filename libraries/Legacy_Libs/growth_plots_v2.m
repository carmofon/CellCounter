%function growth_plots_v2(Data,HDim,VDim,dt,ori,std)
%--Objective:
%       This function makes it easy to plot standard growth data from
%       96-well plates.
%--Inputs:
%       Data [Array]: A three dimensional array of row, column, and time
%           information from your experiment. Usually you obtain this after
%           averaging over the reps dimension from the output of 'stacker_v1'
%           and taking the difference between channels.
%       HDim [Array]: An array that specifies row groupings.
%       VDim [Array]: An array that specifies column groupings.
%       dt [Int]: The amount of time between timepoints.
%       Ori [Bool]: Specify if you would like to group along rows (Ori = 0) or
%       columns (Ori = 1). Leave it blank to not group plots.
%--Outputs:
%       Two figures. One is a log-plot and the other is a standard plot.

[mn,stdev] = matrixstats_v3(Data, HDim, VDim);

%Show Data
%Change the type of plot
nLog = 0;
rows = prev_set(1);
columns = prev_set(2);
timeSteps = prev_set(3);
reps = prev_set(4);     

Data = stacker_v1(rows, columns, timeSteps, reps, 2, './Edit/', {['AllResults_' PlateID{i} '_GPU4']} , CF);
growth_plots_NEW(Data,HDim,VDim,dt,ori,std)

%end