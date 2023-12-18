function out =pkfnd_GPU4(im,th,sz)
%--Objective:
%       Obtain cell position data from an image that has gone through
%       'bpass'.
%--Input:
%       im [Image]: The image file you would like to obtain a count from.
%          This image should probably be denoised from a bandpass filter
%          first.
%       th [Int]: A lower bound pixel value cutoff. Useful for removing
%            noise.
%       sz [Int]: An integer pixel length. Slightly larger than the average
%            cell diameter.
%--Output:
%       out [Int nx2 Array]: n x,y coordinate pairs for detected cell
%            positions.

%Keeps both peaks if they're of the same intensity. GPU4c
%Convert Diameter to radius
sz = floor(sz/2);

%Thresholding.
im = max(im-th,0);

%Shift around
shifty = reshape(eye(3^2),3,3,3^2);
cake = convn(im,shifty,'full');

%Get peak canidates.
[~,I] = max(cake,[],3);
I = I(ceil(3/2):end-ceil(3/2)+1,ceil(3/2):end-ceil(3/2)+1);
I(I~=ceil(3^2/2)) = 0;

%Find brightest peak within sz among canidates
mx = uint8(im.*I);
r2 = 2*sz+1;
mask = ones(r2);
mask(ceil(r2^2/2)) = 0;

dia = imdilate(mx, mask);
peaks = mx >= dia;

[r,c] = find(I.*peaks);
out = [c,r];