%--Basic Settings--
%All of the plates you want to analyze.
PlateID = {'PLATE 1' 'PLATE 2'};
B_th = {[THRESH_CH1 THRESH_CH2] [THRESH_CH1 THRESH_CH2]}; %GPU4 (keeping both peaks)
B_sz = {[SIZE_CH1 SIZE_CH2] [SIZE_CH1 SIZE_CH2]};
B_lnoise = {[BP_MIN_NOISE_SIZE_CH1 BP_MIN_NOISE_SIZE_CH2] [BP_MIN_NOISE_SIZE_CH1 BP_MIN_NOISE_SIZE_CH2]};

dt = TIMESTEPS;
cpu_mode = 0; %=1 means use pkfnd
hank = 1;

%You probably don't want to mess with things below this line
%-----------------------------------------------------------
%Advanced Settings
crop_dist = 5;
CF = 11.38;

if cpu_mode
    tag = '_CPU';
else
    tag = '_GPU';
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
    [Index ,timeSteps,rows,columns,channels,reps] = index_maker(['./' PlateID{i}]);

    %Data Collection
    disp(['Running...' PlateID{i}]);        

    %Get centers location data:
    Live_full = cellfun(@(x) The_Count_v2(files,x,lnoise(1),th(1),sz(1),cpu_mode),num2cell(Index(:,4)),'UniformOutput',false);
    Dead_full = cellfun(@(x) The_Count_v2(files,x,lnoise(2),th(2),sz(2),cpu_mode),num2cell(Index(:,5)),'UniformOutput',false);        

    if hank
        %Better Death Count:
        Dead_full = cellfun(@(L,D) D(logical(DeathCount(L,D,sz(1))),:),Live_full,Dead_full,'UniformOutput',false);
    end
    
    %Extract count data:
    Live = cell2mat(cellfun(@length,Live_full,'UniformOutput',false));
    Dead = cell2mat(cellfun(@length,Dead_full,'UniformOutput',false));        

    %Output
    %This will probably throw an error that doesn't matter.
    cd ..
    mkdir './Edit'
    save(['files_' PlateID{i}],'files')
    save(['Index_' PlateID{i}],'Index')
    save(['Live_full_' PlateID{i}],'Live_full')
    save(['Dead_full_' PlateID{i}],'Dead_full')
    DemoMatrix =[Index(:,1:3) Live Dead];
    outname = ['./Edit/AllResults_' PlateID{i} tag];
    dlmwrite(outname,DemoMatrix,'\t');
end    

function out = DeathCount(LivingList,DeadList,sz)
    gap = pdist2(LivingList,DeadList);
    out = min(gap)<=sz;
end