% General Class for Loading and Returning Table Data
classdef loadData
    methods(Static)
        
        % Create File Dialog for User to Select File Location(s)
        function [userSelectedFilePath,userSelectedFiles] = getTableData()
                % General Pathing to Select Multiple from Directory
                [userSelectedFiles,userSelectedFilePath] = uigetfile('..\REVAMP\revampDATA\*.mat','MultiSelect','on');

                % Transpose Cols to Rows for Readability
                if(~ischar(userSelectedFiles))
                    userSelectedFiles = userSelectedFiles';
                end
    
                % Validate Selection Else Return 0
                if(userSelectedFilePath == 0)
                    % Return Empty
                    userSelectedFilePath = [];
                    userSelectedFiles = [];
                end
        end

        % Load Selected Table Data with Filename and File Pathway
        function userSelectedTableData = loadTableData(filePathway, fileName)
            % Evaluate if File Pathway is Provided
            if(~isempty(filePathway))
                tableFilePath = fullfile(filePathway,fileName);
            % If Empty load data from relative (or given) filename on path
            else
                tableFilePath = fileName;
            end
            % Return Table Data from provided filePath and fileName
            userSelectedTableData = load(tableFilePath);
            userSelectedTableData = userSelectedTableData.importedData;
        end
    end
end