%--Basic Settings--
%All of the plates you want to analyze.
PlateID = {'PLATE 1' 'PLATE 2'};
B_th = {[THRESH_CH1 THRESH_CH2] [THRESH_CH1 THRESH_CH2]}; %GPU4 (keeping both peaks)
B_sz = {[SIZE_CH1 SIZE_CH2] [SIZE_CH1 SIZE_CH2]};

dt = TIMESTEPS;
cpu_mode = 0; %=1 means use pkfnd

%--Options--
%Analysis or Plot?
% op=1 -> Image Analysis op=0 -> Display Data
op = 0;

%Plot Options
%nLog=1 -> Normalized Log Plot. nLog=0 -> Regular Plot.
%Ori=0 -> Breakup by columns. Ori=1 -> Breakup by rows.
std = 0;
%nLog = 0; It's automatic that both figures are generated now.
Ori = 0;
HDim = ones(1,8);
VDim = [3 3 3 3];

%You probably don't want to mess with things below this line
%-----------------------------------------------------------
%Advanced Settings
crop_dist = 5;
CF = 11.38;

if op == 1
    %Collect Data
    for i = 1:numel(PlateID)
        th = B_th{i};
        sz = B_sz{i};
        
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
        Live_full = cellfun(@(x) The_Count(files,x,5,th(1),sz(1),cpu_mode),num2cell(Index(:,4)),'UniformOutput',false);
        Dead_full = cellfun(@(x) The_Count(files,x,5,th(2),sz(2),cpu_mode),num2cell(Index(:,5)),'UniformOutput',false);
        
        %Make sure off GPU for storage
        Live_full = cellfun(@gather,Live_full,'UniformOutput',false);
        Dead_full = cellfun(@gather,Dead_full,'UniformOutput',false);
        
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
        outname = ['./Edit/AllResults_' PlateID{i} '_GPU4'];
        dlmwrite(outname,DemoMatrix,'\t');
    end    
    dlmwrite('./Edit/settings_GPU4',[rows,columns,timeSteps,reps,channels,CF,dt,th,sz],'\t');

else
    %Show Data
    for ty = 0:1
        %Change the type of plot
        nLog = ty;
        
        prev_set = dlmread('./Edit/settings_GPU4');
        rows = prev_set(1);
        columns = prev_set(2);
        timeSteps = prev_set(3);
        reps = prev_set(4);
        for i = 1:numel(PlateID)        
            stack = stacker_v1(rows, columns, timeSteps, reps, 2, './Edit/', {['AllResults_' PlateID{i} '_GPU4']} , CF);
            stack = squeeze(mean(stack,4));
            save('stack','stack')
            Live = stack(:,:,:,1)-stack(:,:,:,2);
            Live(Live<0) = 0;
            [flat_stack, std] = matrixstats_v3(Live,HDim,VDim);
            figure(sub2ind([numel(PlateID) 2],i,ty+1))
            growth_plots(flat_stack,nLog,Ori,dt)
        end
    end
end