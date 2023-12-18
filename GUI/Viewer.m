function handles = Viewer(m,ind,dim)
    %VIEW  a GUI representation of analysis
    
    % build the GUI
    handles = initGUI(m,ind,dim);    
    
    % populate with initial values
    onChangedEntry(handles, m,ind,dim);

    % observe on model changes and update view accordingly
    % (tie listener to model object lifecycle)
    addlistener(m,'image_file', 'PostSet', ...
        @(o,e) onChangedEntry(handles,e.AffectedObject,ind,dim));
    addlistener(m,'sel_cell', 'PostSet', ...
        @(o,e) onChangedEntry(handles,e.AffectedObject,ind,dim));
end

function handles = initGUI(m,ind,dim)
    % initialize GUI controls    
    [p,c] = ind2sub(dim,ind);
    hFig = figure(3);
    set(hFig,'NumberTitle', 'off', 'Name', ['Plate ' num2str(p) ' Channel ' num2str(c)],'pos',[10 10 900 600]);
    hAx = axes('Parent',hFig);
    
    %Threshold
    %20-170
    uicontrol('Parent',hFig, 'Style','text','Value',200, 'Position',[20 20 80 20],'String','Threshold:');
    hTH = uicontrol('Parent',hFig, 'Style','edit', ...
        'Min',1, 'Max',1000, 'Value',200, 'Position',[100 20 50 20]);
    
    %Size
    %180-320
    uicontrol('Parent',hFig, 'Style','text','Value',200, 'Position',[150 20 80 20],'String','Size:');
    hSZ = uicontrol('Parent',hFig, 'Style','edit', ...
        'Min',1, 'Max',10, 'Value',5, 'Position',[230 20 50 20]);
    
    %LNoise
    %330-480
    uicontrol('Parent',hFig, 'Style','text','Value',200, 'Position',[280 20 80 20],'String','LNoise:');
    hLN = uicontrol('Parent',hFig, 'Style','edit', ...
        'Min',1, 'Max',10, 'Value',2, 'Position',[360 20 50 20]);

    %Set parameters
    set_values = uicontrol('Parent',hFig,'Style', 'pushbutton', 'String', 'Set Values',...
        'Position', [450 20 80 20]);
    
    %Get file
    hBtn_img = uicontrol('Parent',hFig,'Style', 'pushbutton', 'String', 'GET FILE',...
        'Position', [530 20 80 20],'Value',0);
    

   
    % customize
    title(hAx, 'Preview Image')

    % return a structure of GUI handles
    handles = struct('fig',hFig, 'ax',hAx, 'th',hTH, ...
        'sz',hSZ,'lnoise',hLN,...
        'img_btn',hBtn_img,'set_vals',set_values,'Vsub',[p,c]);
end

function onChangedEntry(handles,model,~,dim)
    %Pull values from model
    ind = model.current_view;
    [p,c] = ind2sub(dim,ind);
    sel_cell_vect = model.sel_cell{p,c};
    th = sel_cell_vect(1);
    sz = sel_cell_vect(2);
    lnoise = sel_cell_vect(3);
    
    %Generate scatter plot
    IM = model.image_file{p,c};    
    if isempty(IM)
        disp('NO IMAGE LOADED');
    else        
        [centers, filter] = The_Count_v4(IM,lnoise,th,sz,model.dim_vals,~model.GPU_set,1);

        if length(centers)>1
            dims = model.dim_vals;
            if sum(dims)>0            
                IM = imcrop(imread(IM),[0,0,dims(1),dims(2)]);
                filter = imcrop(filter,[0,0,dims(1),dims(2)]);
            end
            im = subplot(1,2,1);
            imshow(IM)
            hold on
            scatter(centers(:,1),centers(:,2),'g')
            hold off
            AR = get(im,'DataAspectRatio');

            fil = subplot(1,2,2);    
            imagesc(filter)
            hold on
            scatter(centers(:,1),centers(:,2),'m')
            hold off
            linkaxes([im,fil], 'xy');
            set(fil,'DataAspectRatio',AR)
        end
    end
end