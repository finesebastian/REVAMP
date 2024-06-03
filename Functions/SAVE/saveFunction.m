%% Save for Given Data, Location, Folder
classdef saveFunction
    methods(Static)
        % Parallel Processing Compatible Save Function
        function saveData(importedData,savePath,fileType)

            % Save "importedData" variable
            save(savePath,"importedData",fileType)
        end
    end
end
