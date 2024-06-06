classdef exportMetrics
    methods(Static)
       
        function [userSelectedFilePath,userSelectedFiles] = validateExportPath(userSelectedPath, selectedFiles, firstLoadBoolean)
          
            if(~contains(string(userSelectedPath), "ANALYSIS_METRICS", "IgnoreCase",true) | firstLoadBoolean)
               if(~firstLoadBoolean)
                msgbox("Select From ANALYSIS_METRICS Folder!", "Incorrect Pathway","error", "modal")
               end
                [userSelectedFilePath,userSelectedFiles] = loadData.getTableData();
                firstLoadBoolean = false;
                if(~isempty(userSelectedFilePath))
                    exportMetrics.validateExportPath(userSelectedFilePath,userSelectedFiles, firstLoadBoolean);
                else
                 msgbox("Export Cancelled", "Export Cancelled","warn", "modal")
                end
            else
                 userSelectedFilePath = userSelectedPath;
                 userSelectedFiles = selectedFiles;
            end
        end

        function exportMetricData()
            % Prompt User to Get Metric Table
            [userSelectedFilePath,userSelectedFiles] = exportMetrics.validateExportPath("...\REVAMPDATA\", "...\REVAMPDATA\", true);
            if(~isempty(userSelectedFilePath))
                    
                exportedMetricTable = [];
                % Single or Multiple Files Selected
                if(ischar(userSelectedFiles))
                   tableOfMetrics = loadData.loadTableData(userSelectedFilePath, userSelectedFiles);
                   exportedMetricTable = exportMetrics.exportTable(tableOfMetrics, userSelectedFilePath,userSelectedFiles);
                else
                   
                    for fileNum = 1:size(userSelectedFiles, 1)
                        tableOfMetrics = loadData.loadTableData(userSelectedFilePath, userSelectedFiles{fileNum});
                        exportedMetricTable = [exportedMetricTable; exportMetrics.exportTable(tableOfMetrics, userSelectedFilePath,userSelectedFiles)];
                    end
                end
                exportPath = exportMetrics.generateExportPath(string(userSelectedFilePath));
                mkdir(exportPath)
                writetable(exportedMetricTable, fullfile(exportPath, strrep(userSelectedFiles, ".mat", ".xlsx")));
            end
            
        end

        function newTable = exportTable(tableOfMetrics, userSelectedFilePath,userSelectedFiles)
            % Extract Section Names and # of Movements Per Section
            currentFileSectionNames = tableOfMetrics.Properties.VariableNames;
            sectionLogicalCells = cellfun(@(tableVariableName) cellfun(@(sectionData) ~isempty(sectionData),tableOfMetrics.(tableVariableName),'UniformOutput',false),currentFileSectionNames,'UniformOutput',false);
            sectionMovementCounts = cellfun(@(logicalCell) sum(cell2mat(logicalCell),1), sectionLogicalCells);

            blinkTransientPath = strrep(userSelectedFilePath, "ANALYSIS_METRICS", "BLINK_DATA\BLINK_IN_TRANSIENT");
            blinkCountPath = strrep(userSelectedFilePath, "ANALYSIS_METRICS", "BLINK_DATA\BLINK_COUNT");

            blinkTransientTable = loadData.loadTableData(blinkTransientPath, userSelectedFiles);
            blinkCountTable = loadData.loadTableData(blinkCountPath, userSelectedFiles);



            % Extract Metric Names
            labels = tableOfMetrics{1, 1}{1}.Properties.VariableNames;

            % Set Initial Export Table Headers
            columnTitles = {'SubjectID', 'Study_Name', 'Movement', 'Movement_Index'};

            % Create New Export Section Titles By Combining Eye and Metric
            eyeSelect = "Left_Eye_";
            for i = 1:size(labels, 2)
                columnTitles{end+1} = convertStringsToChars(strcat(eyeSelect, labels{i}));
            end

            eyeSelect = "Right_Eye_";
            for i = 1:size(labels, 2)
                columnTitles{end+1} = convertStringsToChars(strcat(eyeSelect, labels{i}));
            end

            eyeSelect = "Combined_";
            for i = 1:size(labels, 2)
                columnTitles{end+1} = convertStringsToChars(strcat(eyeSelect, labels{i}));
            end
            columnTitles{end+1} = 'Blink_In_Transient';
            columnTitles{end+1} = 'Blink_Count';
           % Set Variable Types for Export Sections
           varTypes = {'string', 'string', 'string'};
           for i = (length(varTypes) + 1):length(columnTitles)
               if(contains(columnTitles(i), 'Comments', 'IgnoreCase', true))
                    varTypes{end+1} = 'string';
               
               else
                   varTypes{end+1} = 'double';

               end

           end
           
           % Initialize Empty Export Table
           totalRows = sum(sectionMovementCounts);
           newTable = table('Size', [totalRows ,size(columnTitles, 2)], 'VariableNames', columnTitles, 'VariableTypes', varTypes);

           % Split Selected Filename to Extract Identifiers
           splitFilename = strsplit(userSelectedFiles, "_");


           % Input Values from Metric Table to Export Table
           rowNum = 0;
           for section = 1:size(tableOfMetrics, 2)
                for movementIndex = 1: sectionMovementCounts(section)
                    rowNum = rowNum + 1;
                    newTable{rowNum, 1} = string(splitFilename{1});
                    newTable{rowNum, 2}= strcat(splitFilename{3}, "_", splitFilename{4});
                    newTable{rowNum, 3} = string(tableOfMetrics.Properties.VariableNames{section});
                    newTable{rowNum, 4} = movementIndex;
                   
                    for row = 1:3
                        for col = 1:size(labels, 2)
                            newTable(rowNum , (row-1) * size(labels, 2) + col + 4) = cell2table({tableOfMetrics.(section){movementIndex}.(col)(row)});

                        end
                    end

                    newTable{rowNum, size(newTable.Properties.VariableNames, 2)} = blinkCountTable(movementIndex, section);
                    newTable{rowNum, size(newTable.Properties.VariableNames, 2)-1} = blinkTransientTable(movementIndex, section);


                end

           end

        end

        function exportPathway = generateExportPath(rawFilePath)

            % Prepare Export File Path and Save Export Table
            exportPath = strsplit(rawFilePath, "\");
            exportPath = exportPath(1:end-2);
            exportPathway = strrep(strjoin(exportPath, '\\'), "ANALYSIS_METRICS", "EXPORTED_METRICS");

        end
    end
end

