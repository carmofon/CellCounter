function [ Index,pos_num,timeSteps,channels,reps] = index_maker_multi(directory,nm_deli,nm_pos)
%--Objective:
%       This function analyzes an image directory that uses the standard
%       'Hank" file name conventions, and outputs information about the
%       experimental setup.
%--Inputs:
%       directory [{String}]: A cell array of image filenames given by
%          'Hank'. If images are missing, then you're going to have a bad
%          day because this code will fail and you lost data.
%       nm_deli [{String}]: A cell array of Strings. The first value is
%          a string the preceeds the numbers for the well position in the
%          plate. The second value preceeds the numbers for the timepoint.
%          The third preceeds the channel number. (Example Below).
%       nm_pos [Array]: A integer array of how many digits each parameter
%       takes in the filename. [position, time,channel].
%--Outputs:
%       Index [Array]: A table based on the indexing of your 'directory'.
%          For example, suppose 'Index' has a row of 1 2 3 34 15. 
%          That would mean that for the 1st well, 2nd timepoint, and 3rd well image, 
%          channel 1 is image 34 in your 'directory' files and channel 2 is image 15
%          in your 'directory' files.
%       pos_num [Int]: The number of positions in your plate.
%       timeSteps [Int]: The number of timepoints in your experiment.
%       channels [Int]: The number of channels used in your count data.
%          Note that broadfield and phase contrast channels should be omitted
%          from this count because there isn't count data from those channels.
%       reps [Int]: The number of images per well in your plate. Usually 4 or 1.
%--Example:
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
    
    if isunix
        spc = '/';
    else
        spc = '\'; 
    end
    
    files = dir([directory spc '*.tif']);
    pre_Index = [];
    
    file_names = {files.name};
    %disp(files.name)
    %Get positions based on delimeters
    clean = @(x,deli) strsplit(x,nm_deli{deli});
    for deli = 1:numel(nm_deli)
        name_Index(:,deli) = cellfun(@(x) clean(x,deli),file_names,'UniformOutput',false);                
        if nm_pos(deli) == 0
            pre_Index(:,deli) = 1;
        else
            pre_Index(:,deli) = cellfun(@(x) str2double(x{end}(1:nm_pos(deli))),name_Index(:,deli));            
        end
        out{deli} = length(unique(pre_Index(:,deli)));
    end
        
    %position
    pos_num = out{1};
    
    %reps
    reps = out{2};
    
    %time
    timeSteps = out{3};
    
    %channels
    channels = out{4};    
    
    %Build Index by compressing channels and sorting after linearizing rows
    %and columns.
    [nr,~] = size(pre_Index);
    pre_Index(:,numel(nm_deli)+channels) = (1:nr)';
    
    [~,Idx] = sortrows(pre_Index(:,1:(numel(nm_deli)-1)));
    pre_Index = pre_Index(Idx,:);
    pre_Index(isnan(pre_Index)) = 1;
    for i = 1:nr
        %Move image index into the correct column for its channel
        try
            idx = pre_Index(i,numel(nm_deli));
            pre_Index(i-(idx-1)*timeSteps*reps,idx+numel(nm_deli)-1) = pre_Index(i,numel(nm_deli)+channels);
        catch ME            
        end
    end
    
    %Organize and clean
    [~,idx,~] = unique(pre_Index(:,1:(numel(nm_deli)-1)),'rows');
    Index = pre_Index(idx,1:end-1);

    %File missing problem
    if exist('ME','var')
        cd ..
        disp('File Missing!!!')
        save('Index_Error','pre_Index')
        rethrow(ME)        
    end
end