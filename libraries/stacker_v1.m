function [ stacker ] = stacker_v1(rows, columns, timeSteps, rep, channels, InPath, Results_list, CF)
%--Objective:
%       This function takes the text file of experimental values given by
%       our standard analysis of 96 well plates and puts them into a format that's easier to
%       manipulate in MATLAB.
%--Input:
%       rows [Int]: The number of rows used in your well plate.
%       columns [Int]: The number of columns used in your well plate.
%       timeSteps [Int]: The number of time points your experiment went
%       through.
%       rep [Int]: The number of images per well in your plate. Usually 4
%       or 1.
%       channels [Int]: The number of channels used in your count data.
%       Note that broadfield and phase contrast channels should be omitted
%       from this count because there isn't count data from those channels.
%       InPath [String]: The path from the directory this is being executed
%       from to the plate data.
%       Results_list [Cell]: A cell array of file names for the plate data
%       files.
%       CF [Double]: The scale factor for converting the well sample into
%       count data for the entire plate. This should be 11.38 for a 
%       4x objective on our microscope.
%--Output:
%       stacker [Array]: A 6 dimensional array of cell count data. The
%       dimensions are row,column,time,reps,channels, and plates respectively.
%       
%--Example:
%       Supposed you want the count from the 1st row, 2nd column,
%       3rd timepoint, 4th well image, 1st channel, and 1st plate.
%       stack = stacker_v1(#,#,#,#,#,S,{S},D);
%       DesiredData = stack(1,2,3,4,1,1);


plate_num = numel(Results_list);
stacker = zeros([rows columns timeSteps rep channels plate_num]);      
    for plate = 1:plate_num
        file = [InPath Results_list{plate}];
        Data = dlmread(file); %Import data.
        Index = Data(:,1:3);
        No_Index = ceil(Data(:,end-1:end)*CF); %Remove the indices in the data.
        for n = 1:length(Index)
            [c,r] = ind2sub([columns rows],Index(n,1));
            for chan=1:channels
                stacker(r,c,Index(n,2),Index(n,3),chan,plate) = No_Index(n,chan);
            end
        end
    end
end