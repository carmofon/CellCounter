%This will overlay what cells were detected from a count.
%You need to speed this up!
%It assumes your images are phase contrast
%It displays the first channel as green
%It displays the second channel as red

[img,im_path] = uigetfile({'*Phase*.tif'},'File Selector');

filename = img;
file_path = strsplit(im_path,'/');
folder = file_path{end-1};
Path = './Full/';

%LOAD FILES
load([Path 'Index_' folder])
load([Path 'files_' folder])
load([Path 'Positions_' folder])

%Check only the phase contrast names (speedup)
names = {files.name};
smaller_names = names(Index(:,6));

%GET FILE INDEX FROM NAME
data_index = find(cellfun( @(x) strcmp(x,filename), smaller_names));

chan1 = imread([folder '/' files(Index(data_index,4)).name]);
chan2 = imread([folder '/' files(Index(data_index,5)).name]);
chan3 = imread([folder '/' files(Index(data_index,6)).name]);

%Make pretty image
rgb = repmat(chan3,1,1,3);
rgb(:,:,1) = rgb(:,:,1)+chan2-imopen(chan2,strel('disk',15));
rgb(:,:,2) = rgb(:,:,2)+chan1-imopen(chan1,strel('disk',15));

Live = cent_mix{data_index,1};
Dead = cent_mix{data_index,2};

figure(1)
imshow(rgb)
hold on
scatter(Live(:,1),Live(:,2),'b','x')
hold on
scatter(Dead(:,1),Dead(:,2),'m','x')

disp(['You were just viewing ' filename])