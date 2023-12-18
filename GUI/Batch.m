function handles = Batch()
    
    % build the GUI
    handles = initGUI();
end

function handles = initGUI()
    disp("INIT GUI")
    % initialize GUI controls
    %hFig = figure('Menubar','none');
    hFig = figure(2);
    %hAx = axes('Parent',hFig);
    handles.fig = hFig;    
    
    set(hFig,'Position',[0,0,600,400])
end