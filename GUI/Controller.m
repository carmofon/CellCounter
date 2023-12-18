function [m,v1] = Controller
    m = Model();   
    v1 = Batch();
    v1 = genBtn(m,v1);    
    disp('Done with controller INIT')
    
    %Add listener for updates to plate info
    addlistener(m,'name_cell', 'PostSet', ...
        @(o,e) genBtn(e.AffectedObject,v1));
end

function v1 = genBtn(model,v1)
    v1 = GenFace(v1,model);
    disp('Generating button handles.')
    plates = model.plate_cell;
    [plate_num, ~] = size(plates);
    ch_nuM = max(plates{:,2});
    dim = [plate_num,ch_nuM];
    for p = 1:plate_num
        ch_num = plates{p,2};
        for c = 1:ch_num
            handle_name = ['btns_' num2str(p) '_' num2str(c)];
            %Channel Buttons
            ind = sub2ind(dim,p,c);
            set(v1.(handle_name), 'Callback',{@onPushSample,model,dim,ind})            
        end
    end
    set(v1.analyze, 'Callback',{@onPushAnalyze,model,dim})
    set(v1.pk, 'Callback',{@onCheckGPU,model})
    set(v1.settings,'Callback',{@onSettings,model})
end

function handles = GenFace(handles,model)
    disp("Generating Batch face")
    hFig = handles.fig;
    plates = model.grab_plates;
    [plate_num, ~] = size(plates);
    
    for p = 1:plate_num        
        %Text For Plates    
        uicontrol('Parent',hFig, 'Style','text', ...
            'Min',1, 'Max',500, 'Value',200, 'Position',[50 200-p*20 200 20],'String', plates{p,1});
        
        ch_num = plates{p,2};
        ch_nuM = max(plates{:,2});
        dim = [plate_num,ch_nuM];
        for c = 1:ch_num
            handle_name = ['btns_' num2str(p) '_' num2str(c)];
            %Channel Buttons            
            handles.(handle_name) = uicontrol('Parent',hFig,'Style', 'pushbutton', 'String', ['Ch ' num2str(c)],...
                'Position', [220+c*40 200-p*20 35 20],'UserData',sub2ind(dim,p,c));
        end
    end
    
    set(hFig,'UserData',sub2ind(dim,p,c))
    
    handles.analyze = uicontrol('Parent',hFig,'Style', 'pushbutton', 'String', 'Analyze',...
                'Position', [120 200-(1+plate_num)*20 100 20]);
            
    handles.pk = uicontrol('Parent',hFig,'Style', 'checkbox', 'String', 'Enable GPU',...
                'Position', [220 200-(1+plate_num)*20 100 20] ,'Value',0);
            
    handles.settings = uicontrol('Parent',hFig,'Style', 'pushbutton', 'String', 'Settings',...
                'Position', [120 200-(2+plate_num)*20 100 20]);
end

function onSettings(~,~,model)
    disp("Enter Settings")
    v3 = Settings_menu(model);
    set(v3.btn,'Callback',{@onNameUpdate,model,v3})
    set(v3.DimBtn,'Callback',{@onDimUpdate,model,v3})
end

function onDimUpdate(~,~,model,v3)
    Dims = [str2double(get(v3.XDim,'String')),str2double(get(v3.YDim,'String'))];
    model.dim_vals = Dims;
    disp(['Set patch size to: ' num2str(Dims(1)) ' ' num2str(Dims(1))])
end

function onNameUpdate(~,~,model,v3)
    %Position    
    [pdel,pval] = breaker(get(v3.pos,'String'));    
    set(v3.pos_del,'String',pdel)
    set(v3.pos_val,'String',pval)    
    
    %Time
    [tdel,tval] = breaker(get(v3.time,'String'));    
    set(v3.time_del,'String',tdel)
    set(v3.time_val,'String',tval)
    
    %Replicates
    [rdel,rval] = breaker(get(v3.rep,'String'));    
    set(v3.rep_del,'String',rdel)
    set(v3.rep_val,'String',rval)
    
    %Channel
    [cdel,cval] = breaker(get(v3.chan,'String'));    
    set(v3.chan_del,'String',cdel)
    set(v3.chan_val,'String',cval)
    
    model.name_cell = {pdel{1},pval{1},tdel{1},tval{1},rdel{1},rval{1},cdel{1},cval{1}};   
end

function [del,val] = breaker(name)
    if ~isempty(name)
        del = regexp(name,'\d*','Split');
        val = regexp(name,'\d*','Match');
    else
        del = {'None'};
        val = {0};
    end
end

function onCheckGPU(o,~,model)
    model.GPU_set = get(o,'Value');
end

function onPushSample(o,~,model,dim,ind)
    try
        close(3)
    end
    model.current_view = ind;
    v2 = Viewer(model,ind,dim);
    set(v2.set_vals, 'Callback',{@onSet,v2,model,dim,ind})
    set(v2.img_btn,'Callback',{@onPushIMG,model,dim,ind})
end

function onSet(o,~,v2,model,dim,ind)
    % update model (which in turn trigger event that updates view)
    [p,c] = ind2sub(dim,ind);    
    th = str2double(get(v2.th,'String'));
    sz = str2double(get(v2.sz,'String'));
    ln = str2double(get(v2.lnoise,'String'));
    model.sel_cell{p,c} = [th,sz,ln];
end

function onPushIMG(~,~,model,dim,ind)
    % update model (which in turn trigger event that updates view)
    [p,c] = ind2sub(dim,ind);
    [img,im_path] = uigetfile({'*.tif'},'File Selector');
    img = [im_path img];
    model.image_file{p,c} = img;
end

function onPushAnalyze(~,~,model,dim)
    disp('About to analyze')
    Gmode = model.GPU_set;
    patchDim = model.dim_vals;
    namebrk = model.name_cell;

    plate_num = dim(1);
    ch_nuM = dim(2);
    
    if isempty(namebrk)
        hank = 1;
    else
        hank = 0;
    end
    
    PlateID = model.plate_cell(:,1);
    vals = model.sel_cell;
    Ar_th = []; Ar_sz = []; Ar_lnoise = [];
    for p = 1:plate_num
        for c = 1:ch_nuM
            val = vals{p,c};
            if sum(val) ~= 0
                Ar_th(c) = val(1);
                Ar_sz(c) = val(2);
                Ar_lnoise(c) = val(3);
                Ar_get_count(p,c) = 1;
            else
                Ar_get_count(p,c) = 0;
            end
        end
        %You must run all the plates that display... for now.
        B_th{p} = Ar_th;
        B_sz{p} = Ar_sz;
        B_lnoise{p} = Ar_lnoise;
    end
    get_count = max(Ar_get_count,[],1);
    nm_deli = namebrk(1:2:end);
    nm_pos = cellfun(@(x) numel(num2str(x)),namebrk(2:2:end));
    Analysis_2(PlateID,B_th,B_sz,B_lnoise,patchDim,~Gmode,get_count,nm_deli,nm_pos,hank)
end