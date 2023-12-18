%Inputs: the files structure, image index, lnoise, threshold (single
%number),size (single number)
%Outs: Centers of all cells

%!!!
%This is different from 'The_Count' because the crop distance has been
%replaced with the minimum noise size on the bandpass filter.
%The crop distance is not assumed to be ceil(sz/2).

function [centers] = The_Count_v2(file_struct, img_index,lnoise,th,sz,cpu_mode)
    
    if nargin == 5
        cpu_mode = 0;        
    end
    
    names = struct2cell(file_struct);
    Im = imread(names{1,img_index});
    if cpu_mode == 1
        crop_dist = ceil(sz/2);
        Im = imcrop(Im,[crop_dist crop_dist [size(Im,2) size(Im,1)]-2*crop_dist]);
        filtered = bpass(Im,lnoise,sz);
        centers = pkfnd(filtered,th,sz);
    else
        Im = gpuArray(Im);
        filtered = bpass(Im,lnoise,sz);
        centers = pkfnd_GPU4(filtered,th,sz);
    end
    %To prevent errors from null output.
    if isempty(centers)
        centers = [0 0];
    end