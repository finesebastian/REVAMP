%% Identify and Return Each Movements Starting ("Collected") and Ending ("End Trial") Header Index
classdef movementParser
    methods(Static)
        % Identifies Indices of Key Words and Returns Index Pairs
        function movementIndexPairArray = parseRawData(rawDataArray)
            % Identifies "Collected" String in .txt 
            % Provides Section Header (1 Row Above) 
            collectedHeaderIndex = find(strcmp(rawDataArray,"Collected"));

            % Extract Section Header (Collected (Row) - 1)
            movementIndexPairArray(:,1) = collectedHeaderIndex - 1;

            % Extract "End Trial" Indices for Each Section
            movementIndexPairArray(:,2) = find(strcmp(rawDataArray,"End Trial"));
            
        end
    end
end
