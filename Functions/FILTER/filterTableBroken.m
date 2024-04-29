% Functions for Filtering Table Data
classdef filterTable
    methods(Static)

        % Filter Table Parameter with Provided Filter Parameters
        function filteredTable = filterTableData(tableData, filterType, filterOrder, filterVergenceCutoffPrimary, filterVergenceCutoffSecondary, filterSaccadeCutoffPrimary, filterSaccadeCutoffSecondary,samplingFrequency, blinkSTDThreshold, blinkTrim, filterPupilCutoffPrimary)
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

            % Pupil Filter
            [bPupil,aPupil] = butter(filterOrder,filterPupilCutoffPrimary/(samplingFrequency/2),'low');



            % Set Default Return with No Filtering
            filteredTable = tableData;
           
            % Iterate Across Each Column (Data Channel)
            for columnIndex = 1:size(tableData,2)
                % Iterate Down Each Variable Data Entry
                for rowIndex = 1:size(tableData,1)
                    % Extract Cell Entry
                    tableDataCellEntry = tableData.(tableData.Properties.VariableNames{columnIndex})(rowIndex);
                    % Check if Table Data Entry is Empty
                    tableDataEntry = tableDataCellEntry{:};
                    if ~isempty(tableDataCellEntry{:})
                        % Find column index of "left eye vertical"
                        leftVerticalColIndex = find(contains(tableDataEntry.Properties.VariableNames,"left eye vertical",'IgnoreCase',true),1);

                        % Find column index of "right eye vertical"
                        rightVerticalColIndex = find(contains(tableDataEntry.Properties.VariableNames,"right eye vertical",'IgnoreCase',true),1);

                        % Add absolute values of left and right eye vertical to amplify outliers
                        summedVertical = abs(tableDataEntry{:, leftVerticalColIndex}) + abs(tableDataEntry{:, rightVerticalColIndex});
                        

                        % Identify potential index for blinks
                        x = movmedian(summedVertical, 50);
                        blinkImpulseArray = blinkRemoval.findBlinks( ...
                            filter(bPupil, aPupil,x), blinkSTDThreshold, blinkTrim);
                        
                        % Filter Down Columns
                        for variableIndex = 1:size(tableDataEntry.Properties.VariableNames,2)
                            if(contains(tableData.Properties.VariableNames{columnIndex},"Sacc",'IgnoreCase',true))
                                filterAValues = aSaccade;
                                filterBValues = bSaccade;
                            else
                                filterAValues = aVergence;
                                filterBValues = bVergence;
                            end
                                
                            % Filter Table Column
                            % Filtering for Pupil Columns
                            if(contains(tableDataEntry.Properties.VariableNames{variableIndex},"Pupil",'IgnoreCase',true))
                                  tableDataEntry.(tableDataEntry.Properties.VariableNames{variableIndex}) = ...
                                   blinkRemoval.removeBlinks(filter(bPupil,aPupil,[tableDataEntry.(tableDataEntry.Properties.VariableNames{variableIndex})]),blinkImpulseArray);
                            %Filtering Other Properties
                            else
                                tableDataEntry.(tableDataEntry.Properties.VariableNames{variableIndex}) = ...
                                blinkRemoval.removeBlinks(filter(filterBValues,filterAValues,[tableDataEntry.(tableDataEntry.Properties.VariableNames{variableIndex})]),blinkImpulseArray);
                            end
                        end
                    end
                
                 
                    % Replace Unfilter Data with Filtered Data Entry 
                    filteredTable.(filteredTable.Properties.VariableNames{columnIndex})(rowIndex) = {tableDataEntry};
                end
            end
        end
    end
end