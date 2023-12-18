classdef Model < handle
    %MODEL This is the core functionality of the program. It's what
    %processes the image information to obtain the count data from Hank.

    %The externally visible parameters
    properties (SetObservable = true)        
        image_file     %The image file the centers came from
        grab_plates    %Get initial values for plate_cell
        plate_cell     %The plates and channels for the menu
        sel_cell       %A cell of the chosen settings
        GPU_set        %GPU_set = 1 -> GPU peak finder
        name_cell      %A cell with the delimeter info for names (non-Hank)
        dim_vals       %Patch dimensions
        current_view   %Prevents handle collision with viewers
    end

    methods    
        function obj = Model()
            disp("Initiating Model")
            plate_cell = obj.grab_plates;
            
            GPU_set = 0;            
            dim_vals = [0,0];            
            name_cell = {};
            current_view = 1;
               
            obj.GPU_set = GPU_set;
            obj.name_cell = name_cell;
            obj.dim_vals = dim_vals;
            obj.current_view = current_view;
            obj.plate_cell = plate_cell;
            
            %These are grabbed by grab_plates
            %[plate_num,~] = size(obj.plate_cell);
            %ch_num = max(obj.plate_cell{:,2});            
            %image_file = cell(plate_num,ch_num);
            %sel_cell = repmat({[0,0,0]},plate_num,ch_num);            
            %obj.image_file = image_file;
            %obj.sel_cell = sel_cell;                 
        end
        
        function plate_cell = get.grab_plates(obj)
            disp("Grabbing Plate Info")
            if isunix
                spc = '/';
            else
                spc = '\'; 
            end            

            plates = dir(['.' spc '*Plate*']);
            pfol = plates.folder;
            plates = {plates.name};
            for plate = 1:numel(plates)
                cd(plates{plate})
                if ~isempty(obj.name_cell)
                    namebrk = obj.name_cell;
                    nm_deli = namebrk(1:2:end);
                    nm_pos = cellfun(@(x) numel(num2str(x)),namebrk(2:2:end));
                    [~,~,~,ch] = index_maker_multi(['.' spc],nm_deli,nm_pos);
                else
                    try
                        [~,~,~,~,ch,~] = index_maker(['.' spc]);
                    catch
                        disp('Non-Standard filenames')
                        ch = 1;
                    end
                end
                plate_cell(plate,1:2) = {plates{plate}, ch};
                cd(pfol)
            end

            obj.plate_cell = plate_cell;
            [plate_num,~] = size(obj.plate_cell);
            ch_num = max(obj.plate_cell{:,2});
            obj.image_file = cell(plate_num,ch_num);
            obj.sel_cell = repmat({[0,0,0]},plate_num,ch_num);
        end
    end
end