function [mn,stdev] = matrixstats_v3(Data, HDim, VDim)
%--Objective:
%       This function makes it easy to get the standard deviation and mean
%       of multiple values across a plate. It's primary use is for when you
%       have replicates that you want to average across.
%--Inputs:
%       Data [Array]: A three dimensional array of row, column, and time
%           information from your experiment. Usually you obtain this after
%           averaging over the reps dimension from the output of 'stacker_v1'
%           and taking the difference between channels.
%       HDim [Array]: An array that specifies row groupings.
%       VDim [Array]: An array that specifies column groupings.
%--Outputs:
%       mn [Array]: An array of the mean value across all wells within your groups.
%       stdev [Array]: An array of the standard deviation across all wells
%           within your groups.
%--Example:
%       Suppose you have a 96-well plate with three cell lines in
%       triplicate and using only five rows. Each row has its own cell
%       density.
%       Plate Layout:
%       1 1 1 2 2 2 3 3 3
%       1 1 1 2 2 2 3 3 3
%       1 1 1 2 2 2 3 3 3
%       1 1 1 2 2 2 3 3 3
%       1 1 1 2 2 2 3 3 3
%
%       HDim = [1 1 1 1 1];
%       Because each row is NOT to be averaged over
%       VDim = [3 3 3];
%       Because within a fixed row, your experiment groupings are length
%       three.

    [~,~,time] = size(Data);

    Split_Data = mat2cell(Data,HDim,VDim,ones(1,time));
    mn = cellfun(@(x)mean2(x),Split_Data,'UniformOutput',0);
    stdev = cellfun(@(x)std2(x),Split_Data,'UniformOutput',0);
    
    mn = cat(3,mn);
    stdev = cat(3,stdev);