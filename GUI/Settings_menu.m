function handles = Settings_menu(m)
    %VIEW  a GUI representation of analysis
    
    % build the GUI
    handles = initGUI(m);    
end

function handles = initGUI(model)
    %Get sample image filename
    if isunix
        spc = '/';
    else
        spc = '\'; 
    end
    files = dir([model.plate_cell{1} spc '*.tif']);    

    % initialize GUI controls
    hFig = figure('NumberTitle', 'off', 'Name', 'Get Name Information');
    
    %Actual filename
    y0 = 350;
    uicontrol('Parent',hFig, 'Style','text', ...
        'Min',1, 'Max',1000, 'Value',200, 'Position',[20 y0 60 20],'String','Name:');
    uicontrol('Parent',hFig, 'Style','edit', 'String',files(1).name,...
        'Min',1, 'Max',10, 'Value',5, 'Position',[80 y0 400 20]);    
    
    %Titles
    yT = 320;
    uicontrol('Parent',hFig, 'Style','text', ...
        'Min',1, 'Max',1000, 'Value',200, 'Position',[80 yT 60 20],'String','Chunk:');
    uicontrol('Parent',hFig, 'Style','text', ...
        'Min',1, 'Max',1000, 'Value',200, 'Position',[180 yT 60 20],'String','Delimeter:');
    uicontrol('Parent',hFig, 'Style','text', ...
        'Min',1, 'Max',1000, 'Value',200, 'Position',[260 yT 60 20],'String','Value:');
    
    %Position
    y1 = 300;
    uicontrol('Parent',hFig, 'Style','text', ...
        'Min',1, 'Max',1000, 'Value',200, 'Position',[20 y1 60 20],'String','Position:');
    pos_chunk = uicontrol('Parent',hFig, 'Style','edit',...
        'Min',1, 'Max',10, 'Value',5, 'Position',[80 y1 80 20]);    
    %PULL FROM MODEL
    pos_del = uicontrol('Parent',hFig, 'Style','text', ...
        'Value',200, 'Position',[180 y1 60 20],'String','DEL');
    pos_val = uicontrol('Parent',hFig, 'Style','text', ...
        'Value',200, 'Position',[260 y1 60 20],'String','1');    
    
    %Replicates
    y2 = 280;
    uicontrol('Parent',hFig, 'Style','text', ...
        'Min',1, 'Max',1000, 'Value',200, 'Position',[20 y2 60 20],'String','Replicates:');
    rep_chunk = uicontrol('Parent',hFig, 'Style','edit',...
        'Min',1, 'Max',10, 'Value',5, 'Position',[80 y2 80 20]);
    %PULL FROM MODEL
    rep_del = uicontrol('Parent',hFig, 'Style','text', ...
        'Value',200, 'Position',[180 y2 60 20],'String','DEL');
    rep_val = uicontrol('Parent',hFig, 'Style','text', ...
        'Value',200, 'Position',[260 y2 60 20],'String','1');      

    %Time   
    y3 = 260;
    uicontrol('Parent',hFig, 'Style','text', ...
        'Min',1, 'Max',1000, 'Value',200, 'Position',[20 y3 60 20],'String','Time:');
    time_chunk = uicontrol('Parent',hFig, 'Style','edit',...
        'Min',1, 'Max',10, 'Value',5, 'Position',[80 y3 80 20]);
    %PULL FROM MODEL
    time_del = uicontrol('Parent',hFig, 'Style','text', ...
        'Value',200, 'Position',[180 y3 60 20],'String','DEL');
    time_val = uicontrol('Parent',hFig, 'Style','text', ...
        'Value',200, 'Position',[260 y3 60 20],'String','1');      
    
    %Channel   
    y4 = 240;
    uicontrol('Parent',hFig, 'Style','text', ...
        'Min',1, 'Max',1000, 'Value',200, 'Position',[20 y4 60 20],'String','Channel:');
    chan_chunk = uicontrol('Parent',hFig, 'Style','edit',...
        'Min',1, 'Max',10, 'Value',5, 'Position',[80 y4 80 20]);
    %PULL FROM MODEL
    chan_del = uicontrol('Parent',hFig, 'Style','text', ...
        'Value',200, 'Position',[180 y4 60 20],'String','DEL');
    chan_val = uicontrol('Parent',hFig, 'Style','text', ...
        'Value',200, 'Position',[260 y4 60 20],'String','1');
    
    %Name Index Button
    set_btn = uicontrol('Parent',hFig,'Style','pushbutton',...
        'String','Set Values','Position',[80 220 80 20],'UserData',{'pos','1','rep','1','time','1','chan','1'});
    
    %Set Dimensions
    uicontrol('Parent',hFig, 'Style','text','Position',[20 180 100 20],'String','Patch Dimensions:');
    x_dim = uicontrol('Parent',hFig, 'Style','edit','Value',0, 'Position',[130 180 50 20]);
    y_dim = uicontrol('Parent',hFig, 'Style','edit','Value',0, 'Position',[190 180 50 20]);
    
    %Dim Button
    dim_btn = uicontrol('Parent',hFig,'Style','pushbutton',...
        'String','Set Values','Position',[80 160 80 20],'UserData',[]);    

    % return a structure of GUI handles
    handles = struct('fig',hFig,...
                     'pos',pos_chunk,'pos_del',pos_del,'pos_val',pos_val,...
                     'rep',rep_chunk,'rep_del',rep_del,'rep_val',rep_val,...
                     'time',time_chunk,'time_del',time_del,'time_val',time_val,...
                     'chan',chan_chunk,'chan_del',chan_del,'chan_val',chan_val,...
                     'btn',set_btn,'XDim',x_dim,'YDim',y_dim,'DimBtn',dim_btn);
end