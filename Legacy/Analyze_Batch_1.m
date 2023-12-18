%This allows use to analyze a batch images with a simple interface.
%The main output is 'SortData'. Each dimension of 'SortData' is
%[row,column,channel].

%Settings
ExpDims = [8 12];
cpu = 0; %CPU=1 means your are using pkfnd
B_th = [200 200 200];
B_sz = [5 5 5];
lnoise = 4; %What's the size of noise in your data? (in pixels)

im_dir = uigetdir('./','Select Plate Folder');
cd(im_dir)
files = dir('*.tif');
names = {files.name};

Data = [];
for chan = 1:length(B_th)
    chan_idx = find(cellfun(@(nm) str2double(nm(end-4))==chan,names));
    counts = cellfun(@(img) length(pk_mini(img,lnoise,B_th(chan),B_sz(chan),cpu)),names(chan_idx),'UniformOutput',false);
    Data = [Data ; [names(chan_idx)' counts']];
end
cd ..
save('Georgio_Data','Data')
%Organize Output
for file = 1:length(Data)
    filename = Data{file,1};
    channel = str2double(filename(end-4));
    pos_idx = str2double(filename(end-7:end-6));
    [posx,posy] = ind2sub(fliplr(ExpDims),pos_idx);
    SortData(posx,posy,channel) = Data{file,2};
end
SortData = permute(SortData,[2 1 3]);
%Flip every other row because Giorgio is lazy
for chan = 1:length(B_th)
SortData(2:2:end,:,chan) = fliplr(SortData(2:2:end,:,chan));
end
save('Georgio_Data_Sorted','SortData')

function centers = pk_mini(Im,lnoise,th,sz,cpu)
    if cpu == 0
        Im = gpuArray(imread(Im));
        filtered = bpass(Im,lnoise,2*sz);
        centers = pkfnd_GPU4(filtered,th,sz);
    else
        Im = imread(Im);
        filtered = bpass(Im,lnoise,sz);
        centers = pkfnd(filtered,th,sz);
    end
end