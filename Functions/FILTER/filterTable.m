% Functions for Filtering Table Data
classdef filterTable
    methods(Static)

        % Filter Table Parameter with Provided Filter Parameters
        function [filteredTable, blinkInTransient, blinkCount, blinkIndex] = filterTableData(tableData,filterType,filterOrder, ...
                filterVergenceCutoffPrimary, filterVergenceCutoffSecondary, ...
                filterSaccadeCutoffPrimary, filterSaccadeCutoffSecondary, ...
                samplingFrequency,transientBlinkSampleThreshold, filterPupilPrimary, blinkFillMethod, accommodationDataBoolean)
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

            % Create Numerical Count of Blinks in Files
            blinkIndex = cell(size(tableData,1),size(tableData,2));
           
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

                        % Replace Missing Data with NEAREST nonmissing
                        % Specification Made through PlusOptix Specs 
                        % Range +5/-7 Diopters 
                        if(accommodationDataBoolean)
                            tableDataEntry{(abs(tableDataEntry{:,1}) > 7),1} = 0;
                            tableDataEntry{(abs(tableDataEntry{:,2}) > 7),2} = 0;


                            % % Check all missing Data Conditions
                            % if(sum(isnan(tableDataEntry{:,1})) == size(tableDataEntry{:,1},1))
                            %     tableDataEntry{:,1} = 0;
                            % elseif (sum(isnan(tableDataEntry{:,2})) == size(tableDataEntry{:,2},1))
                            %     tableDataEntry{:,2} = 0;
                            % end
                        end

                        % Filter Down Columns
                        for variableIndex = 1:size(tableDataEntry.Properties.VariableNames,2)
                            % Determine General Filter Coefficients
                            % Version
                            if(contains(tableData.Properties.VariableNames{columnIndex},"Sacc",'IgnoreCase',true))
                                filterAValues = aSaccade;
                                filterBValues = bSaccade;
                            % Else Default Vergence Filter Parameters
                            else
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

                        % Added Functionality for bypassing accommodation
                        % data
                        if(~accommodationDataBoolean)
    
                            % Perform Blink Removal
                            [blinkRemovedTable, blinkInTransientBoolean, currentBlinksInMovement, blinkIndices] = blinkRemoval.removeBlinks(tableDataEntry,transientBlinkSampleThreshold,blinkFillMethod);
                        
                            % Replace Unfilter Data with Filtered Data Entry 
                            filteredTable.(filteredTable.Properties.VariableNames{columnIndex})(rowIndex) = {blinkRemovedTable};
                            % Capture boolean for Blink in Transient
                            blinkInTransient(rowIndex,columnIndex) = blinkInTransientBoolean;
                            % Capture Number of Blinks in Movement
                            blinkCount(rowIndex,columnIndex) = currentBlinksInMovement;
                            % Capture Index Pair Matrix of Blinks 
                            blinkIndex(rowIndex,columnIndex) = {blinkIndices};

                        else
                            % Replace Unfilter Data with Filtered Data Entry 
                            filteredTable.(filteredTable.Properties.VariableNames{columnIndex})(rowIndex) = {tableDataEntry};
                        end
                    end
                end
            end
        end
    end
end