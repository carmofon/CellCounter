function growth_plots(flat_stack,Log,Ori,dt,fixed_clr)
%Log = 1 -> Normalize log plot. Ori = 0 -> Treatments across columns.
%'flat_stack' is the stack from a single plate. It should have probably
%already gone through the matrixstats.

%%NEED TO UPDATE
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

    norm_stack = 1; %Default normalization
    flat_stack = cell2mat(flat_stack);
    [nr, nc, nt] = size(flat_stack);
    init_density = flat_stack(:,:,1);
    low_pop = min(init_density(:));
    high_pop = max(init_density(:));
    clr = parula(ceil(high_pop-low_pop));
    
    if Ori == 0
        grp_num = nc;
    else
        grp_num = nr;
    end
    
    for g = 1:grp_num %Groups (In this case things are grouped by columns)        
        if Ori == 0
            subplot(3,4,g)
        else
            subplot(2,4,g)
        end            
        for c = 1:nc
            for r = 1:nr
                pop = max(floor(flat_stack(r,c,1))-low_pop,1);
                if Log == 1
                    norm_stack = flat_stack(:,:,1);
                end
                plot_stack = flat_stack./norm_stack;                
                if nargin>4
                    draw_p = plot(dt*(1:nt),squeeze(plot_stack(r,c,:)),'Color',fixed_clr(g,:));
                else
                    draw_p = plot(dt*(1:nt),squeeze(plot_stack(r,c,:)),'Color',clr(round(pop),:));
                end
                hold off
                if Ori == 0
                    if c ~= g
                        draw_p.Color(4) = 0.01;
                    end
                else
                    if r ~= g
                        draw_p.Color(4) = 0.01;
                    end
                end
                hold on
            end
        end
        if Ori == 0
            title(['Column ' num2str(g)])
        else
            title(['Row ' num2str(g)])
        end            
        
        xlabel('Time')        
        axis square
        if Log == 1
            ylabel('Log and Normalized Population')
            set(gca, 'yscale', 'log')
        else
            ylabel('Scaled Population')
        end
    end
end