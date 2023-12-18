%--Objective:
%--Inputs:
%       PlateID [{String}]: A cell array of plate names.
%       B_th    [{Array}]: A cell array of ordered pairs. Each ordered pair
%          contains a threshold value for each channel.
%       B_sz    [{[Int]}]: A cell array of ordered pairs. Each ordered pair
%           contains a size value for each channel.
%       B_lnoise    [{[Int]}]: A cell array of ordered pairs. Each ordered pair
%           contains a lower noise size value for each channel.
%       cpu_mode [Bool]: Indicates if you would like to use the CPU
%          algorithm (cpu_mode = 1) or the GPU algorithm (cpu_mode = 0).
%       Hank [Bool]: A bool value specifying if you're processing a Hank
%          plate or something else.
%       get_count [Array]: An array specifying which channels contain
%           flourescent data. e.g. A 1 in the second position indicates that
%           the second channel has flourscent data.
%       patch_size [Array]: An array specifying the size of chunks to
%          process for each image. [0 0] means you would like to analyze the
%          whole image simultaniously. [500 500] is usually a good option
%          for Giorgio data.
%       chan_filt [Array]: Each row of this array is an output channel.
%          The first column is the channel the elements are coming from.
%          The second column is the channel the elements need to be near.
%          e.g. [1 1;2 1] leaves the first channel alone, and filteres the
%          second channel by only keeping points close to elements from the
%          first channel.
%       nm_deli [{String}]: A cell array of Strings. The first value is
%          a string the preceeds the numbers for the well position in the
%          plate. The second value preceeds the numbers for the timepoint.
%          The third preceeds the channel number. (Example Below).
%       nm_pos [Array]: A integer array of how many digits each parameter
%       takes in the filename. [position, time,channel].
%--Outputs:
%       A results text file written into a directory called 'Edit'.
%--Example for working with Giorgio Data filenames:
%       Suppose your filenames are like WhateverName_T=12xy13c1.tif.
%       nm_deli = {'xy','T=','c'};
%       nm_pos = [2,2,1];
%       The first values for these are 'xy' and 2, because 'xy' is before the position value in the filename.
%       and 2 is the number of digits that are used to specify the well position.
%
%       IMPORTANT NOTE: If your filename was something like
%       WhateverT=Name_T=12xy13c1.tif that would be a problem because you
%       have two different places where you have 'T='. This program will
%       always take the RIGHTMOST value. This means you should be careful
%       if your delimeters are weak. 'c' is a good example of a bad
%       delimeter because it's conceivable that you would want c in your filename.
%       Hence, It's best practice to put your position, time, and channel
%       information at the end of your filenames.

%--Basic Settings--
%All of the plates you want to analyze.
PlateID = {'PLATE 1' 'PLATE 2'};

B_th = {[THRESH_CH1 THRESH_CH2] [THRESH_CH1 THRESH_CH2]};
B_sz = {[SIZE_CH1 SIZE_CH2] [SIZE_CH1 SIZE_CH2]};
B_lnoise = {[BP_MIN_NOISE_SIZE_CH1 BP_MIN_NOISE_SIZE_CH2] [BP_MIN_NOISE_SIZE_CH1 BP_MIN_NOISE_SIZE_CH2]};

cpu_mode = 1; %=1 means use pkfnd
Hank = 1;

get_count = [1 1 0];
patch_size = [0 0]; %Choose [] for the entire image to be analyzed
chan_filt = [1 1;2 1];

%Non-Hank
%Extract information from filenames based on positon.
%nm_deli = {'pos','time','chan'};
nm_deli = {'xy','T=','c'}; %only needed for non-Hank.
nm_pos = [2,2,1];

%You probably don't want to mess with things below this line
%-----------------------------------------------------------
%Auto Detect System Settings   
if isunix
    spc = '/';
else
    spc = '\';
end

if cpu_mode
    alg = 'CPU';
else
    alg = 'GPU';
end

%Collect Data
for i = 1:numel(PlateID)
    th = B_th{i};
    sz = B_sz{i};
    lnoise = B_lnoise{i};

    cd(['./' PlateID{i}])
    files = dir('*.tif');
    cd ..

    %Label maker
    disp('Initializing');
    %If this fails, then check your data transfer.
    if Hank == 1
        [Index,timeSteps,rows,columns,channels,reps] = index_maker(['./' PlateID{i}]);

    else
        [Index,pos_num,timeSteps,channels] = index_maker_multi(['./' PlateID{i}],nm_deli,nm_pos);        
    end
    disp(Index)

    [nr,~] = size(Index);

    %Data Collection
    disp(['Running...' PlateID{i}]);        

    %Get centers location data:
    cd(['./' PlateID{i}])
    for c = 1:channels
        if get_count(c) == 1
            disp(c)
            centers(1:nr,c) = cellfun(@(x) The_Count_v4(files(x).name,lnoise(c),th(c),sz(c),patch_size,cpu_mode),...
                num2cell(Index(:,3+c)),'UniformOutput',false);            
        end
        disp(['Done with channel ' num2str(c)])
    end

    %Extract position data:
    [nchan,~] = size(chan_filt);

    for c = 1:nchan            
        for r = 1:nr
            outList = centers{r,chan_filt(c,1)};
            filterList = centers{r,chan_filt(c,2)};
            filterSize = sz(chan_filt(c,2));
            cent_mix{r,chan_filt(c,1)} = outList(LocCount(filterList,outList,filterSize),:);
        end
    end

    %Get counts from position:
    Counts = cellfun(@(x) length(x),cent_mix);

    %Output    
    cd ..
    mkdir 'Edit' %This will probably throw an error that doesn't matter.
    mkdir 'Full'
    DemoMatrix =[Index(:,1:3) Counts];
    save(['.' spc 'Full' spc 'files_' PlateID{i}],'files')
    save(['.' spc 'Full' spc 'Index_' PlateID{i}],'Index')
    save(['.' spc 'Full' spc 'Positions_' PlateID{i}],'cent_mix')
    outname = ['.' spc 'Edit' spc 'AllResults_' PlateID{i} '_' alg];
    dlmwrite(outname,DemoMatrix,'\t');
end
disp("All Done.")

function out = LocCount(firstList,secondList,sz)
    %Get the elements of the second list that are within
    %sz of the first list.
    gap = pdist2(firstList,secondList);
    out = min(gap)<=sz;
end