function Analysis_2(PlateID,B_th,B_sz,B_lnoise,patch_size,cpu_mode,get_count,nm_deli,nm_pos,Hank)
    %{    
    %--Basic Settings--
    %All of the plates you want to analyze.
    PlateID = {'PLATE 1' 'PLATE 2'};
    
    B_th = {[THRESH_CH1 THRESH_CH2] [THRESH_CH1 THRESH_CH2]};
    B_sz = {[SIZE_CH1 SIZE_CH2] [SIZE_CH1 SIZE_CH2]};
    B_lnoise = {[BP_MIN_NOISE_SIZE_CH1 BP_MIN_NOISE_SIZE_CH2] [BP_MIN_NOISE_SIZE_CH1 BP_MIN_NOISE_SIZE_CH2]};
    %}

    %cpu_mode = 1; %=1 means use pkfnd
    %get_count = [1 1 0];
    %patch_size = []; %Choose [] for the entire image to be analyzed
    %chan_filt:
    %Each row is an output channel.
    %The first column is the channel the elements are coming from.
    %The second column is the channel the elements need to be near.
    %Note to self: you can replace get_count with this.
    chan_filt = repmat((1:sum(get_count))',[1,2]);%[1 1;2 2];

    %Non-Hank
    %Extract information from filenames based on positon.
    %nm_deli={'pos','time','chan'}
    %nm_deli = {'xy','T=','c'}; %only needed for non-Hank.
    %nm_pos = [2,2,1];

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

    function out = LocCount(firstList,secondList,sz)
        %Get the elements of the second list that are within
        %sz of the first list.
        gap = pdist2(firstList,secondList);
        out = min(gap)<=sz;
    end
    disp("All Done.")
end