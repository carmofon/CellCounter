function [centers] = The_Count(file_struct, img_index,crop_dist,th,sz,cpu_mode)
%--Objective:
%       The purpose of this function is for obtaining cell count data from
%       a single image.
%--Inputs:
%       file_struct [Structure Array]: The structure array given by 'dir'.
%       img_index [Int]: The image you're interested in specified by its
%           location in 'file_struct'.
%       th [Int]: A lower bound pixel value cutoff. Useful for removing
%            noise.
%       sz [Int]: An integer pixel length. Slightly larger than the average
%            cell diameter.
%       cpu_mode [bool]: Value of 1 means you would like to use the cpu
%            pkfnd algorithm. Value of 0 is for the GPU optimized
%            algorithm.
%--Outputs:
%       centers [Int nx2 Array]: n x,y coordinate pairs for detected cell
%            positions.
    
    if nargin == 5
        cpu_mode = 0;
    end
    
    names = struct2cell(file_struct);
    Im = imread(names{1,img_index});
    if cpu_mode == 1
        Im = imcrop(Im,[crop_dist crop_dist [size(Im,2) size(Im,1)]-2*crop_dist]);
        filtered = bpass(Im,2,sz);
        centers = pkfnd(filtered,th,sz);
    else
        Im = gpuArray(Im);
        filtered = bpass(Im,2,sz);
        centers = pkfnd_GPU4(filtered,th,sz);
    end