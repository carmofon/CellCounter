%--Objective:
%       The purpose of this function is for testing cell parameter
%       values. You'll be prompted to specify a sample image for testing.
%--Inputs:
%       lnoise [Int]: The Characteristic lengthscale of noise in pixels.
%            Additive noise averaged over this length should vanish. 
%            May assume any positive floating value. May be set to 0 or false,
%            in which case only the highpass "background subtraction" operation is performed.
%       th [Int]: A lower bound pixel value cutoff. Useful for removing
%            noise.
%       sz [Int]: An integer pixel length. Slightly larger than the average
%            cell diameter. [!!!!!!!!CHANGE GPU]
%       cpu_mode [bool]: Value of 1 means you would like to use the cpu
%            pkfnd algorithm. Value of 0 is for the GPU optimized
%            algorithm.
%--Outputs:
%       Displays an example of your parameter settings on a test image.

%Good Settings for Giorgio
th = 500;
sz = 20;
lnoise = 4;

cpu_mode = 1;

[img,im_path] = uigetfile({'*.tif'},'File Selector');

filename = img;
file_path = strsplit(im_path,'/');
folder = file_path{end-1};

image = imread([im_path img]);

if cpu_mode
    %CPU
    filtered_cpu = bpass(Im,lnoise,2*sz);
    centers = pkfnd(gather(filtered_cpu),th,2*sz);
    figure(1)
    %imagesc(filtered)
    imshow(image)
    hold on
    scatter(gcenters(:,1),gcenters(:,2),'g','o')
else
    %GPU
    Im = gpuArray(image);
    filtered = single(bpass(Im,lnoise,2*sz));
    gcenters = pkfnd_GPU4(filtered,th,sz);
    hold on
    scatter(centers(:,1),centers(:,2),'m','x')
end

disp(['You were just viewing ' filename])