%% Caller Class for Formatting Data Channels within Imported Data
classdef revampDataChannels
    methods(Static)
        function [tableFormattingCompletionBoolean, processedDataFilepaths] = formatTableData(tabularDataFilePaths, parWorkers, plusOptixBoolean)

            % If File(s) Are all Rejected
            if(~isempty(tabularDataFilePaths))

                % Determine Single File or Multi-File Selection
                if(size(tabularDataFilePaths,1) == 1)

    
                    % Load Table Data
                    importedTabularData = load(tabularDataFilePaths{1});
                    importedTabularData = importedTabularData.importedData;
    
                    % Organize Table Data 
                    organizedTabularData = tableDataManager.processTableData(importedTabularData, plusOptixBoolean);
    
                    % Save Organized Data Tables
                    processedFilePath = strrep(tabularDataFilePaths{1},'IMPORTED_RAW',"UNFILTERED_UNCALIBRATED");
                    processedFilePathSplit = strsplit(strrep(tabularDataFilePaths{1},"IMPORTED_RAW","UNFILTERED_UNCALIBRATED"),"\");
                    

                    % Save Data
                    mkdir(strjoin(processedFilePathSplit(1:end-1),"\"))
                    saveFunction.saveData(organizedTabularData,processedFilePath,"-mat"); 
    
                    % Return Filepathway
                    processedDataFilepaths = convertStringsToChars(processedFilePath);
    
                else

                    % Preallocate Cell Array of File Paths
                    processedDataFilepaths = cell(size(tabularDataFilePaths,1),1);

                    % Parallel Processing for Table Internal Data Channels
                    parfor (filePathIndex = 1:size(tabularDataFilePaths,1),parforOptions(parWorkers))

                        if(~isempty(tabularDataFilePaths{filePathIndex}))
                            
                            % Load Table Data
                            importedTabularData = load(tabularDataFilePaths{filePathIndex});
                            importedTabularData = importedTabularData.importedData;
        
                            % Organize Table Data 
                            organizedTabularData = tableDataManager.processTableData(importedTabularData,plusOptixBoolean);
        
                            % Save Organized Data Tables
                            processedFilePath = strrep(tabularDataFilePaths{filePathIndex},"IMPORTED_RAW","UNFILTERED_UNCALIBRATED");
                            processedFilePathSplit = strsplit(strrep(tabularDataFilePaths{filePathIndex},"IMPORTED_RAW","UNFILTERED_UNCALIBRATED"),"\");

                            % Suppress Warnings in Client and Parallel Pool
                            warning('off','all')

                            % Save Data 
                            mkdir(strjoin(processedFilePathSplit(1:end-1),"\"))
                            saveFunction.saveData(organizedTabularData,processedFilePath,"-mat"); 

                            % Save File Pathway
                            processedDataFilepaths{filePathIndex} = convertStringsToChars(processedFilePath);
                        end
                    end
    
                    % End Parallel Processing
                    delete(parWorkers)
                end

                % Send Boolean Report for Table Formatting Complete
                tableFormattingCompletionBoolean = true;

            else
                % Send Boolean Report for Table Formatting Incomplete
                tableFormattingCompletionBoolean = false;
                processedDataFilepaths = [];
            end

        end
    end
end
