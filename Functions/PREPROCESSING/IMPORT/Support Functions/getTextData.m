%% Provide User Selected File Paths to load Raw (.txt) Data to String Array
classdef getTextData
    methods(Static)
        % Loads .txt "Raw" Data with options
        function userSelectedData = importData(rawFilePath)
            % Set up the Import Options and import the data
            opts = delimitedTextImportOptions("NumVariables", 1);
            
            % Specify range and delimiter
            opts.DataLines = [1, Inf];
            opts.Delimiter = ",";
            
            % Specify column names and types
            opts.VariableTypes = "string";
            
            % Specify file level properties
            opts.ExtraColumnsRule = "ignore";
            opts.EmptyLineRule = "read";
            
            % Import the data
            userSelectedData = readmatrix(rawFilePath, opts);
            
            % Clear temporary variables
            clear opts
        end
    end
end

