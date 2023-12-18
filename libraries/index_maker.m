function [ Index,timeSteps,row_num,columns,channels,rep_num] = index_maker(directory)
%--Objective:
%       This function analyzes an image directory that uses the standard
%       'Hank" file name conventions, and outputs information about the
%       experimental setup.
%--Inputs:
%       directory [{String}]: A cell array of image filenames given by
%          'Hank'. If images are missing, then you're going to have a bad
%          day because this code will fail and you lost data.
%--Outputs:
%       Index [Array]: A table based on the indexing of your 'directory'.
%          For example, suppose 'Index' has a row of 1 2 3 34 15. 
%          That would mean that for the 1st well, 2nd timepoint, and 3rd well image, 
%          channel 1 is image 34 in your 'directory' files and channel 2 is image 15
%          in your 'directory' files.
%       timeSteps [Int]: The number of timepoints in your experiment.
%       row_num [Int]: The number of rows used in your experiment's plate.
%       columns [Int]: The number of columns used in your experiment's plate.
%       channels [Int]: The number of channels used in your count data.
%          Note that broadfield and phase contrast channels should be omitted
%          from this count because there isn't count data from those channels.
%       rep_num [Int]: The number of images per well in your plate. Usually 4 or 1.

    if isunix
        spc = '/';
    else
        spc = '\'; 
    end
    
    files = dir([directory spc '*.tif']);
    pre_Index = [];
    
    file_names = {files.name};
    split_names = cellfun(@(x) strsplit(x,'_'),file_names,'UniformOutput',false)';
    split_names = cat(1,split_names{:});

    %rows
    clean_row = @(x) strfind("ABCDEFGH",x(1));
    pre_Index(:,1) = cellfun(clean_row,split_names(:,1));
    row_num = max(pre_Index(:,1))-min(pre_Index(:,1))+1;
    
    %columns
    clean_col = @(x) str2double(x(2:end));
    pre_Index(:,2) = cellfun(clean_col,split_names(:,1));
    columns = max(pre_Index(:,2))-min(pre_Index(:,2))+1;
    
    %time
    clean_time = @(x) str2double(x(1:end-4));
    pre_Index(:,3) = cellfun(clean_time,split_names(:,end));
    timeSteps = max(pre_Index(:,3));
    
    %reps
    pre_Index(:,4) = cellfun(@str2double,split_names(:,4));
    rep_num = max(pre_Index(:,4));
    
    %channels
    pre_Index(:,5) = cellfun(@str2double,split_names(:,3));
    channels = max(pre_Index(:,5));
    
    %Build Index by compressing channels and sorting after linearizing rows
    %and columns.
    [nr,~] = size(pre_Index);
    pre_Index(:,8) = (1:nr)';
    
    S_row = min(pre_Index(:,1))-1;
    S_col = min(pre_Index(:,2))-1;
    for i = 1:nr
        try
            %Move image index into the correct column for its channel
            idx = pre_Index(i,5);
            pre_Index(i-(idx-1)*timeSteps*rep_num,idx+4) = pre_Index(i,8);

            %Convert the row and column into linear indices
            pre_Index(i) = sub2ind([columns,row_num],pre_Index(i,2)-S_col,pre_Index(i,1)-S_row);
        catch ME
        end
    end
    
    %Organize and clean
    [~,idx,~] = unique(pre_Index(:,1:4),'rows');
    Index = pre_Index(idx,[1 3:7]);
    
    %File missing problem
    if exist('ME','var')
        cd ..
        disp('File Missing!!!')
        save('Index_Error','pre_Index')
        rethrow(ME)        
    end
end