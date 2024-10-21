%% Export Selected Table Data from REVAMP Ecosystem
classdef exportMetrics
    methods(Static)

       % Confirm that the Table Data Selected is from post-analysis output
        function [userSelectedFilePath,userSelectedFiles] = validateExportPath(userSelectedPath, selectedFiles, firstLoadBoolean)
          % Compare if the File Path Contains known Directory for output
            if(~contains(string(userSelectedPath), "ANALYSIS_METRICS", "IgnoreCase",true) || firstLoadBoolean)
                % Ignore Error Message for First Entry to Export
                if(~firstLoadBoolean)
                    msgbox("Select From ANALYSIS_METRICS Folder!", "Incorrect Pathway","error", "modal")
                end
                % Prompt to Load Data
                [userSelectedFilePath,userSelectedFiles] = loadData.getTableData();

                % Set First Entry to false (if not already)
                firstLoadBoolean = false;

                % If user selected files validate selection before
                % returning else return dialog
                if(~isempty(userSelectedFilePath))
                    exportMetrics.validateExportPath(userSelectedFilePath,userSelectedFiles, firstLoadBoolean);
                else
                    msgbox("Export Cancelled", "Export Cancelled","warn", "modal")
                end
            % Correct Data
            else
                 userSelectedFilePath = userSelectedPath;
                 userSelectedFiles = selectedFiles;
            end
        end

        % Caller for Exporting Data
        function exportMetricData()
            % Prompt User to Get Metric Table
            [userSelectedFilePath,userSelectedFiles] = exportMetrics.validateExportPath("...\REVAMPDATA\", "...\REVAMPDATA\", true);
            
            % If User Cancels Ignore Empty Paths
            if(~isempty(userSelectedFilePath)) 
                % Set Defaults (Left Right Binocular)
                exportedMetricTable1 = [];
                exportedMetricTable2 = [];
                exportedMetricTable3 = [];
                exportedMetricTable = [];
              
                % Single (Char) or Multiple (Cells) Files Selected
                if(ischar(userSelectedFiles))
                   tableOfMetrics = loadData.loadTableData(userSelectedFilePath, userSelectedFiles);
                   [exportedMetricTable, numberOfSections, nameOfSections, numberOfDataChannels, nameOfDataChannels] = exportMetrics.exportTable(tableOfMetrics, userSelectedFilePath, userSelectedFiles);
                else
                    % Iterate over selection
                    for(fileNum = 1:size(userSelectedFiles, 1))
                        tableOfMetrics = loadData.loadTableData(userSelectedFilePath, userSelectedFiles{fileNum});
                        % Returns 3xn Cell of Left, Right, Binocular Data
                        % with n Number of Sections
                        [exportedMetrics, numberOfSections, nameOfSections, numberOfDataChannels, nameOfDataChannels] = exportMetrics.exportTable(tableOfMetrics, userSelectedFilePath,userSelectedFiles{fileNum});

                        % Vertically Concatenate Tables
                        % Number of Sections
                        for (sectionIndex = 1:numberOfSections)
                            % Number of Data Channels
                            for (dataChannelRowIndex = 1:numberOfDataChannels)
                                if(isempty(exportedMetricTable))
                                    exportedMetricTable = exportedMetrics;
                                else
                                    exportedMetricTable{dataChannelRowIndex,sectionIndex} = [exportedMetricTable{dataChannelRowIndex,sectionIndex};exportedMetrics{dataChannelRowIndex,sectionIndex}];
                                end
                            end
                        end
                    end
                end

                % Create Export Directory Path
                exportPath = exportMetrics.generateExportPath(string(userSelectedFilePath));

                % Generate Unique Time Stamp for Naming
                uniqueTimeStamp = strcat("DataExport_",string(round(posixtime(datetime('now', 'TimeZone', 'local')))),".xlsx");

                % Save Based on Per Data Channel with Section Names as
                % Sheets within Export
                
                % Down Rows
                for (dataChannelRowIndex = 1:numberOfDataChannels)
                    rowFileDirectoryPath = fullfile(exportPath,nameOfDataChannels{dataChannelRowIndex});
                        % Check if Directory Exists
                        if(~isfolder(rowFileDirectoryPath))
                            mkdir(rowFileDirectoryPath)
                        end
                    uniqueFileName = strcat(nameOfDataChannels{dataChannelRowIndex},"_",uniqueTimeStamp);
                    % Across Columns
                    for (sectionIndex = 1:numberOfSections)
                        writetable(rmmissing(exportedMetricTable{dataChannelRowIndex,sectionIndex},'DataVariables',{'SubjectID'}), fullfile(rowFileDirectoryPath,uniqueFileName),'Sheet',nameOfSections{sectionIndex});
                    end
                end
            end  
        end

        % Create Export of Analysis Metrics, Blink Count, Blink in
        % Transient Boolean, Calibration Metrics
        function [exportTableData, numberOfSections, nameOfSections, numberOfDataChannels, nameOfDataChannels] = exportTable(tableOfMetrics, userSelectedFilePath,userSelectedFile)
            % Extract Section Names and # of Movements Per Section
            currentFileSectionNames = tableOfMetrics.Properties.VariableNames;

            % Get Number of Movements in Section Names
            sectionLogicalCells = cellfun(@(tableVariableName) cellfun(@(sectionData) ~isempty(sectionData),tableOfMetrics.(tableVariableName),'UniformOutput',false),currentFileSectionNames,'UniformOutput',false);
            sectionMovementCounts = cellfun(@(logicalCell) sum(cell2mat(logicalCell),1), sectionLogicalCells);

            % Get Pathing for Supporting Table Data
            blinkTransientPath = strrep(userSelectedFilePath, "ANALYSIS_METRICS", "BLINK_DATA\BLINK_IN_TRANSIENT");
            blinkCountPath = strrep(userSelectedFilePath, "ANALYSIS_METRICS", "BLINK_DATA\BLINK_COUNT");
            gainValuePath = strrep(userSelectedFilePath, "ANALYSIS_METRICS", "CALIBRATION_METRICS");

            % Load Support Table Data 
            blinkTransientTable = loadData.loadTableData(blinkTransientPath, userSelectedFile);
            blinkCountTable = loadData.loadTableData(blinkCountPath, userSelectedFile);
            tempGainCalibrationTable = loadData.loadTableData(gainValuePath, userSelectedFile);
            tempGainCalibrationTable.("Binocular") = mean(tempGainCalibrationTable.Variables,2);

            % Tranpose Gain Table to be Uniform 
            gainCalibrationTable = array2table(table2array(tempGainCalibrationTable).','RowNames',tempGainCalibrationTable.Properties.VariableNames,'VariableNames',tempGainCalibrationTable.Properties.RowNames);
            
            % Extract Section Names from Table
            sectionNames = tableOfMetrics.Properties.VariableNames;

            % Extract Metric Names from First Table in Metric Data Set
            metricColNames = tableOfMetrics{1, 1}{1}.Properties.VariableNames;
            
            % Extract Metric Names from First Table in Metric Data Set
            gainColNames = gainCalibrationTable.Properties.VariableNames;

            % Extract Row Names from First Table in Metric Data Set
            metricRowNames = tableOfMetrics{1,1}{1}.Properties.RowNames;

            % Set Empty Variables for Table
            uniqueMetricColumnNames = strings(size(metricRowNames,1),size(metricColNames,2));
            uniqueGainColumnNames = strings(size(metricRowNames,1),size(gainColNames,2));

            % Create Unique Variable Names from Metric Table
            for(rowIndex = 1:size(metricRowNames,1))
                uniqueMetricColumnNames(rowIndex,:) = [cellfun(@(x) strcat(metricRowNames{rowIndex},"_",x),metricColNames)];
                uniqueGainColumnNames(rowIndex,:) = [cellfun(@(x) strcat(metricRowNames{rowIndex},"_Gain_",x),gainColNames)];
            end

            for(dataChannelSelection = 1:size(metricRowNames,1))

               % Set Default Leading Export Table Headers
               defaultHeaders = ["SubjectID", "Study_Name", "Movement", "Movement_Index","Blink_In_Transient","Blink_Count"];
               uniqueColumnNames = [defaultHeaders,uniqueMetricColumnNames(dataChannelSelection,:),uniqueGainColumnNames(dataChannelSelection,:)];
    
               % Set Default Variable Types for Export Sections to Double
               varTypes = repelem("double",1,size(uniqueColumnNames,2));
    
               % Set Default First 3 Headers to String
               varTypes(1,1:3) = "string";
    
               % Replace Double Type with String for any "Comments"
               varTypes(contains(uniqueColumnNames, 'Comments', 'IgnoreCase', true)) = "string";
               
               % Initialize Empty Export Table
               exportTableData(dataChannelSelection,1) = {table('Size', [max(sectionMovementCounts) ,size(uniqueColumnNames, 2)], 'VariableNames', uniqueColumnNames, 'VariableTypes', varTypes)};
    
               % Split Selected Filename to Extract Identifiers
               splitFilename = strsplit(userSelectedFile, "_");

            end

            % Duplicate Tables for Each Eye Based on Number of Table Cols
            % Preserve Rows (1) and Repeat Number of Cols
            exportTableData = repmat(exportTableData, [1 size(tableOfMetrics, 2)]);
    
               % Input Values from Metric Table to Export Table
    
               % Iterate Across Each Column (Section)
               for sectionIndex = 1:size(tableOfMetrics, 2)
                   % Iterate Down Each Row (Movement)
                    for movementIndex = 1:sectionMovementCounts(sectionIndex)  
                        % Fill Respective Tables with Data
                        for(dataChannelSelection = 1:size(metricRowNames,1))

                            % Fill Default Header Information
                            exportTableData{dataChannelSelection,sectionIndex}.SubjectID(movementIndex) = string(splitFilename{1});
                            exportTableData{dataChannelSelection,sectionIndex}.Study_Name(movementIndex)= string([splitFilename{3}, splitFilename{4}]);
                            exportTableData{dataChannelSelection,sectionIndex}.Movement(movementIndex) = string(sectionNames{sectionIndex});
                            exportTableData{dataChannelSelection,sectionIndex}.Movement_Index(movementIndex) = movementIndex;
        
                            % Fill Blink Data
                            exportTableData{dataChannelSelection,sectionIndex}.Blink_Count(movementIndex) = blinkCountTable(movementIndex, sectionIndex);
                            exportTableData{dataChannelSelection,sectionIndex}.Blink_In_Transient(movementIndex) = blinkTransientTable(movementIndex, sectionIndex);

                            % If you do not have the need 4 speed this will
                            % ensure all variables and entries are correct
                            % (otherwise code below commented section is
                            % much faster)
                           
                            % % Fill Export Table with Metric Table Data
                            % % Iterate across Column (Variables)
                            % for metricTableColumnIndex = 1:size(metricColNames, 2)
                            %     % Identify Current Column Name
                            %     currentMetricVariable = strcat(metricRowNames{dataChannelSelection},"_",metricColNames{metricTableColumnIndex});
                            %     exportTableData{dataChannelSelection}.(currentMetricVariable)(rowEntryIndex) = tableOfMetrics.(sectionIndex){movementIndex}.(metricTableColumnIndex)(dataChannelSelection);
                            % end
                            % 
                            % % Iterate Across Gain Column Variables
                            % for gainTableColumnIndex = 1:size(gainColNames, 2)
                            %     % Identify Current Column Name
                            %     currentGainVariable = strcat(metricRowNames{dataChannelSelection},"_Gain_",gainColNames{gainTableColumnIndex});
                            %     exportTableData{dataChannelSelection}.(currentGainVariable)(rowEntryIndex) = gainCalibrationTable.(gainTableColumnIndex)(dataChannelSelection);
                            % end

                            % Fill Entire Row Based on Offset of Default
                            % Variables
                            exportTableData{dataChannelSelection,sectionIndex}{movementIndex,(size(defaultHeaders,2)+1):end} = [tableOfMetrics.(sectionIndex){movementIndex}{dataChannelSelection,:},gainCalibrationTable{dataChannelSelection,:}];
                        end
                    end
               end

               numberOfSections = size(tableOfMetrics, 2);
               nameOfSections = sectionNames;
               nameOfDataChannels = metricRowNames;
               numberOfDataChannels = size(metricRowNames,1);
        end

        function exportPathway = generateExportPath(rawFilePath)

            % Prepare Export File Path and Save Export Table
            exportPath = strsplit(rawFilePath, "\");
            exportPath = exportPath(1:end-2);
            exportPathway = strrep(strjoin(exportPath, '\\'), "ANALYSIS_METRICS", "EXPORTED_METRICS");

        end
    end
end

