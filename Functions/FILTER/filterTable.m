% Functions for Filtering Table Data
classdef filterTable
    methods(Static)

        % Filter Table Parameter with Provided Filter Parameters
        function [filteredTable, blinkInTransient, blinkCount] = filterTableData(tableData,filterType,filterOrder,filterVergenceCutoffPrimary, filterVergenceCutoffSecondary, filterSaccadeCutoffPrimary, filterSaccadeCutoffSecondary,samplingFrequency,transientBlinkSampleThreshold, filterPupilPrimary)
            % Evaluate Filter Type
            if strcmp(filterType,'bandpass')
                % Vergence Filter
                [bVergence,aVergence] = butter(filterOrder,[filterVergenceCutoffPrimary/(samplingFrequency/2), filterVergenceCutoffSecondary/(samplingFrequency/2)],filterType);
                % Saccade Filter
                [bSaccade,aSaccade] = butter(filterOrder,[filterSaccadeCutoffPrimary/(samplingFrequency/2), filterSaccadeCutoffSecondary/(samplingFrequency/2)],filterType);

            else
                % Vergence Filter
                [bVergence,aVergence] = butter(filterOrder,filterVergenceCutoffPrimary/(samplingFrequency/2),filterType);
                % Saccade Filter
                [bSaccade,aSaccade] = butter(filterOrder,filterSaccadeCutoffPrimary/(samplingFrequency/2),filterType);
            end

            % Always Filter Pupil with Low Pass and User-Passed Threshold
            % Pupil Filter
            [bPupil,aPupil] = butter(filterOrder,filterPupilPrimary/(samplingFrequency/2),'low');

            % Set Default Return with No Filtering
            filteredTable = tableData;

            % Create Boolean Flag for Blink in Transient (Default - False)
            blinkInTransient = NaN(size(tableData,1),size(tableData,2));

            % Create Numerical Count of Blinks in Files
            blinkCount = NaN(size(tableData,1),size(tableData,2));
           
            % Iterate Across Each Column (Data Channel)
            for columnIndex = 1:size(tableData,2)
                % Iterate Down Each Variable Data Entry
                for rowIndex = 1:size(tableData,1)
                    % Default Boolean 
                    blinkInTransientBoolean = false;

                    % Default Number of Blinks
                    currentBlinksInMovement = 0;

                    % Extract Cell Entry
                    tableDataCellEntry = tableData.(tableData.Properties.VariableNames{columnIndex})(rowIndex);
                    tableDataEntry = [];

                    % Check if Table Data Entry is Empty
                    if ~isempty(tableDataCellEntry{:})
                        tableDataEntry = tableDataCellEntry{:};
                        % Filter Down Columns
                        for variableIndex = 1:size(tableDataEntry.Properties.VariableNames,2)
                            % Determine General Filter Coefficients
                            if(contains(tableData.Properties.VariableNames{columnIndex},"Sacc",'IgnoreCase',true))
                                filterAValues = aSaccade;
                                filterBValues = bSaccade;
                            elseif(contains(tableData.Properties.VariableNames{columnIndex},"Step",'IgnoreCase',true))
                                filterAValues = aVergence;
                                filterBValues = bVergence;
                            end

                            % Filter Table Column
                            for (colIndex = 1:size(tableDataEntry.Properties.VariableNames,2))
                                % Use Pupil Filter for "Pupil" Containing
                                % Columns AND Vertical Columns
                                if(contains(tableDataEntry.Properties.VariableNames{variableIndex},"Pupil",'IgnoreCase',true) || contains(tableDataEntry.Properties.VariableNames{variableIndex},"Vertical",'IgnoreCase',true))
                                    tableDataEntry.(tableDataEntry.Properties.VariableNames{variableIndex}) = filter(bPupil,aPupil,[tableDataEntry.(tableDataEntry.Properties.VariableNames{variableIndex})]);
                                % Otherwise Filter with Determined
                                % Coefficeints
                                else
                                    tableDataEntry.(tableDataEntry.Properties.VariableNames{variableIndex}) = filter(filterBValues,filterAValues,[tableDataEntry.(tableDataEntry.Properties.VariableNames{variableIndex})]);
                                end
                            end

                        end

                        % Perform Blink Removal
                        [blinkRemovedTable, blinkInTransientBoolean, currentBlinksInMovement] = blinkRemoval.removeBlinks(tableDataEntry,transientBlinkSampleThreshold);
                    
          
                        % Replace Unfilter Data with Filtered Data Entry 
                        filteredTable.(filteredTable.Properties.VariableNames{columnIndex})(rowIndex) = {blinkRemovedTable};
                        % Capture boolean for Blink in Transient
                        blinkInTransient(rowIndex,columnIndex) = blinkInTransientBoolean;
                        % Capture Number of Blinks in Movement
                        blinkCount(rowIndex,columnIndex) = currentBlinksInMovement;
                    end
                end
            end
        end
    end
end