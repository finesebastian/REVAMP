% Functions for Filtering Table Data
classdef filterTable
    methods(Static)

        % Filter Table Parameter with Provided Filter Parameters
        function filteredTable = filterTableData(tableData,filterType,filterOrder,filterVergenceCutoffPrimary, filterVergenceCutoffSecondary, filterSaccadeCutoffPrimary, filterSaccadeCutoffSecondary,samplingFrequency, blinkSTDThreshold, blinkTrim)
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

            % Set Default Return with No Filtering
            filteredTable = tableData;
           
            % Iterate Across Each Column (Data Channel)
            for columnIndex = 1:size(tableData,2)
                % Iterate Down Each Variable Data Entry
                for rowIndex = 1:size(tableData,1)
                    % Extract Cell Entry
                    tableDataCellEntry = tableData.(tableData.Properties.VariableNames{columnIndex})(rowIndex);
                    tableDataEntry = [];
                    % Check if Table Data Entry is Empty
                    if ~isempty(tableDataCellEntry{:})
                        tableDataEntry = tableDataCellEntry{:};
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
                            tableDataEntry.(tableDataEntry.Properties.VariableNames{variableIndex}) = filter(filterBValues,filterAValues,[tableDataEntry.(tableDataEntry.Properties.VariableNames{variableIndex})]);
                        end
                        blinkRemovedTable = blinkRemoval.removeBlinks(tableDataEntry);
                    end
          
                    % Replace Unfilter Data with Filtered Data Entry 
                    filteredTable.(filteredTable.Properties.VariableNames{columnIndex})(rowIndex) = {blinkRemovedTable};
                end
            end
        end
    end
end