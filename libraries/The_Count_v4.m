function [cts,filtered] = The_Count_v4(filename,lnoise,th,sz,dims,cpu_mode,sample)
%--Objective:
%       The purpose of this function is for obtaining cell count data from
%       a single image.
%--Inputs:
%       filename [String]: The path and name of the file that you want to extract count
%            data from.
%       lnoise [Int]: The Characteristic lengthscale of noise in pixels.
%            Additive noise averaged over this length should vanish. 
%            May assume any positive floating value. May be set to 0 or false,
%            in which case only the highpass "background subtraction" operation is performed.
%       th [Int]: A lower bound pixel value cutoff. Useful for removing
%            noise.
%       sz [Int]: An integer pixel length. Slightly larger than the average
%            cell diameter.
%       dims [Int 1x2 Array]: Useful for larger images. This is the size (in pixels) you would like
%            fragment the image into for processing. Set to [0,0] to use the whole image.
%       cpu_mode [bool]: Value of 1 means you would like to use the cpu
%            pkfnd algorithm. Value of 0 is for the GPU optimized
%            algorithm.
%       sample [bool]: Useful if you would like to display a partial output
%            from a large image. If set to 1, then The_Count will operate
%            and output a sample image of the size specified by 'dims'.
%--Outputs:
%       cts [Int nx2 Array]: n x,y coordinate pairs for detected cell
%            positions.
%       filtered [Image]: The image given by bpass using your settings. 
%            See 'bpass' for more information.

    %Default dims and mode
    if (nargin < 7)
        sample = 0;
    end
    
    if (nargin < 6)
        disp("Defaulting to CPU.")
        cpu_mode = 1;
    end
    
    if (nargin < 5)
        disp("If your memory is running out on your GPU, then set dims.")
        dims = [];
    end
    
    if (nargin < 4)
        disp("Not enough inputs!")
    end    
    
    %In case you want to decouple sz with crop_dist.
    crop_dist = sz;
   
    if isequal(dims,[0,0])
        cts_Img = Counter(imread(filename),lnoise,th,sz,cpu_mode);
    else
        if ~sample
            cts_Img = blockproc(filename,dims,@(x) Counter(x.data,lnoise,th,sz,cpu_mode),'BorderSize',crop_dist*[1,1]);            
        else
            smp_img = imcrop(imread(filename),[0,0,dims(1),dims(2)]);
            cts_Img = Counter(smp_img,lnoise,th,sz,cpu_mode);
        end        
    end
    cts_Img = imcrop(cts_Img,[crop_dist crop_dist [size(cts_Img,2) size(cts_Img,1)]-2*(crop_dist)]);
    [r,c] = find(gather(cts_Img));
    cts = [c,r]+crop_dist;
    
    %Get bpass image
    disp(filename)
    filtered = filterer(imread(filename),lnoise,sz,cpu_mode);
end

function Im_bk = Counter(Im,lnoise,th,sz,cpu_mode)
    Im_bk = 0.*Im;
    if cpu_mode == 1
        filtered = bpass(Im,lnoise,sz);
        centers = pkfnd(filtered,th,sz);
    else
        Im = gpuArray(Im);
        filtered = bpass(Im,lnoise,sz);
        centers = pkfnd_GPU4(filtered,th,sz);            
    end
    %This can probably be done without a loop!
    for i = 1:length(centers)
        try
            Im_bk(centers(i,2),centers(i,1)) = 1;
        catch
            disp(centers)
        end
    end
end

function filtered = filterer(Im,lnoise,sz,cpu_mode)
    if cpu_mode == 1
        filtered = bpass(Im,lnoise,sz);
    else
        Im = gpuArray(Im);
        filtered = bpass(Im,lnoise,sz);
    end
end