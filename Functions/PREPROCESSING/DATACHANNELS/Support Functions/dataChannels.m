%% Determine Number of Unique Headers within Table Data and Return Indices
classdef dataChannels
    methods(Static)
        % Intakes Individual Data Entry as Array Returns Table 
        function tabularDataChannels = parseTableData(tabularData, dataEntryVariableName)
            
            % Identify "Eye" Channel Headers
            eyeChannelHeaderIndex = find(contains(tabularData,"Eye"));
            
            % Gather Channel Names
            eyeChannelNames = tabularData(eyeChannelHeaderIndex);

            % Adjust Data Start Index for each Channel
            eyeChannelIndex = eyeChannelHeaderIndex + 1;

            % Empty Array
            channelData = zeros(eyeChannelIndex(2)-eyeChannelIndex(1)-1,size(eyeChannelIndex,1));

            % Seperate Data Channels via Found "Eye" Headers
            for channelIndex = 1:size(eyeChannelIndex,1)
                if(channelIndex+1 > size(eyeChannelIndex,1))
                    % Last Data Stream with "End Trial" -1 offset at end
                    channelData(:,channelIndex) = tabularData(eyeChannelIndex(channelIndex):(end-1));
                else
                    % Offset -2 for the Header Index to end of Data Stream
                    channelData(:,channelIndex) = tabularData(eyeChannelIndex(channelIndex):(eyeChannelIndex(channelIndex+1)-2));
                end
            end

            % Create Calculated Data Channels
            calculatedChannels = calculatedDataChannels.calculateDataChannels(eyeChannelNames,channelData,dataEntryVariableName);
            % eyeChannelNames = vertcat(eyeChannelNames,["Binocular Horizontal";"Binocular Vertical";"Binocular Pupil"]);

            % Create Table with Data Channel Headers as VariableNames 
            tabularDataChannels = array2table(calculatedChannels,"VariableNames",eyeChannelNames);

        end
    end
end