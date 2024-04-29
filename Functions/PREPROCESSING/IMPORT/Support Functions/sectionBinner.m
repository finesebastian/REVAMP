%% Parses Index Pairs and Sorts Movements into Table
classdef sectionBinner
    methods(Static)
        function dataTable = raw2table(indexPairArray,rawDataArray)
            % Turns off General Warnings for Table row additions with other
            % adjacent cols being empty
            warning('off','all')

            % Extract All Section Header Names
            % Selects all First Col Indices from Section Header Array to
            % Extract Section Headers from Raw Data to Uppercase
            allSectionHeaders(:,1) = rawDataArray(indexPairArray(:,1));

            % Standardize Naming Structure for found Section Headers
            standardizedSectionHeaders = sectionHeaderConformer.standardizeSectionHeader(allSectionHeaders);

            % Identify unique Section Headers
            unqiueSectionHeaders(:,1)= unique(standardizedSectionHeaders);

            % Create Data Table with Unique Section Headers
            % Initialized with Empty Cells
            dataTable = cell2table(cell(1,size(unqiueSectionHeaders,1)), ...
                'VariableNames',unqiueSectionHeaders(:));
            
            % Make Reference Table to count number of Section Header
            % Repetitions
            movementOccurenceTable = array2table(ones(1,size(unqiueSectionHeaders,1)), ...
                'VariableNames',unqiueSectionHeaders(:));

            % Iterate through all idenitifed Index Pairs to extract data and count
            % occurences of each Section Header
            for indexPairRow = 1:size(indexPairArray)
                % Get Row Pair (Section Header ... End Trial) Indices
                indexStartEnd = indexPairArray(indexPairRow,:);

                % Place Data into Table under Section Header
                dataTable.(standardizedSectionHeaders(indexPairRow))(movementOccurenceTable.(standardizedSectionHeaders(indexPairRow))) = {rawDataArray(indexStartEnd(1):indexStartEnd(2))};

                % Increment Row for Data Placement
                movementOccurenceTable.(standardizedSectionHeaders(indexPairRow)) = movementOccurenceTable.(standardizedSectionHeaders(indexPairRow)) + 1;
            end
            warning('on','all')
        end
    end
end