%% Caller Class for all Preprocessing Methods and Data Flow
classdef revampPreprocessor
    methods(Static)
        % Main Caller Class for the Preprocessing Workflow
        function [generalRootPath, preprocessCompleteBoolean,dataFilepaths] = preprocessData()
    
            % Import .TXT Data convert to Table with Array Entries
            [generalRootPath, tabularDataFilePaths, parWorkers, importCompleteBoolean] = revampImport.importRawData();

            % Format Data Channels convert to Table with Table Entries
            [tableFormattingCompletionBoolean, processedDataFilepaths] = revampDataChannels.formatTableData(tabularDataFilePaths, parWorkers);

            % Return Status of Preprocessing for success of both modules
            if tableFormattingCompletionBoolean && importCompleteBoolean
                preprocessCompleteBoolean = true;

                % Return Processed Paths
                dataFilepaths = processedDataFilepaths;
            % Else Failure in Import (Usually Cancelled Import)
            else
                % Return False Completion
                preprocessCompleteBoolean = false;
                % Return Empty Filepaths
                dataFilepaths = [];
            end

        end

    end
end