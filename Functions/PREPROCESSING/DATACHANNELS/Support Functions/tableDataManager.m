%% Intake Table and Process Individual Entries
classdef tableDataManager
    methods(Static)
        function organizedTableData = processTableData(tableData,plusOptixBoolean)

            % Iterate Through Table Data for Data Channel Organization
            for colIndex = 1:size(tableData,2)

                % Iterates down the Rows and Across the Cols for
                % VariableName Consistency
                for rowIndex = 1:size(tableData,1)
                   
                    % Decompose Table Data Entry to Array
                    dataEntry = tableData{rowIndex,colIndex};
                    dataEntry = dataEntry{1};

                    % Evaluate if Table Data Entry is Empty
                    if(~isempty(dataEntry))

                        % Process DataEntry with Table Data Returned
                        tabularDataChannels = dataChannels.parseTableData(dataEntry, (tableData.Properties.VariableNames{colIndex}),plusOptixBoolean);
    
                        % Replace Initial Entry with returned Table Entry
                        % Extract Variable Name that Increments with ColIndex
                        tableData.(tableData.Properties.VariableNames{colIndex})(rowIndex) = {tabularDataChannels};
                    end


                end
            end

            % Create Return Variable
            organizedTableData = tableData;
        end
    end
end