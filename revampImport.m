%% Caller Class for all Raw Data Import Methods and Data Flow
classdef revampImport
    methods(Static)
        function [generalRootPath, importedDataFilePaths, parWorkers, importRawCompleteBoolean] = importRawData()

            % Get User Selected Raw Data Filepaths
            [rawDataFileNames,rawDataFilepaths] = uigetfile("..\REVAMP\revampDATA\RAW\*.txt", "MultiSelect","on");

            % Check if User Cancelled Import
            if(~isequal(rawDataFileNames,0))

                % Pathing Schema
                parsedRootPath = strsplit(rawDataFilepaths, "\");
                rootPath = fullfile(parsedRootPath{1:end-2});
    
                % Create General Save Pathways
                generalRootPath = rootPath;

                % Default Empty FilePaths
                importedDataFilePaths{1} = '';
    
                % If Single File Selection Filename is Char Array (Single File Processing)
                if(ischar(rawDataFileNames))

                    try

                        % Empty Parworkers
                        parWorkers = [];
        
                        % Convert Char Array to 1x1 Cell Array
                        rawDataFileNames = {rawDataFileNames};
                    
                        % Load .txt File
                        userSelectedData = getTextData.importData(fullfile(rawDataFilepaths,rawDataFileNames{1}));
        
                        % Get Row Indices of Key Word Pairs 
                        % "Section Header" ... "End Trial"
                        movementIndexPairArray = movementParser.parseRawData(userSelectedData);
        
                        % Parse Movements into Table via section Headers
                        rawDataTable = sectionBinner.raw2table(movementIndexPairArray,userSelectedData);
        
                        % Naming Schema (Remove any Extra Unexpected Spaces in
                        % Filename)
                        parsedSubjectfolder = strsplit(erase(rawDataFileNames{1}," "), "_");
        
                        % Study Name
                        projectStudyName = strcat(parsedSubjectfolder{3:4});
        
                        % Create Subject File Name
                        subjectFile = strjoin(parsedSubjectfolder(1:end-1),"_")+".mat";

                        % Suppress Runtime Warnings
                        warning('off', 'all');

                        % Generate Saving Directories
                        mkdir(fullfile(generalRootPath,"IMPORTED_RAW",projectStudyName));
        
                        % Save Raw Data Table and Add to Pathing
                        fileSavePath = fullfile(generalRootPath,"IMPORTED_RAW",projectStudyName,subjectFile);
                        saveFunction.saveData(rawDataTable,fileSavePath,"-mat"); 
                        importedDataFilePaths{1} = fileSavePath;

                    catch
                        % Load .txt File Again
                        userSelectedData = getTextData.importData(fullfile(rawDataFilepaths,rawDataFileNames{1}));
    
                        % Naming Schema (Remove any Extra Unexpected Spaces in
                        % Filename)
                        parsedSubjectfolder = strsplit(erase(rawDataFileNames{1}," "), "_");
    
                        % Create Subject File Name
                        subjectFile = strjoin(parsedSubjectfolder(1:end-1),"_")+".mat";
                        
                        % Generate Rejected Saving Directories
                        mkdir(fullfile(generalRootPath,"REJECTED"));
        
                        % Save Raw Data
                        fileSavePath = fullfile(generalRootPath,"REJECTED",subjectFile);
                        saveFunction.saveData(userSelectedData,fileSavePath,"-mat"); 
                    end
    
                % Otherwise Parallel Processing
                else
        
                    % Create Parallel Pool
                    parWorkers = parpool(feature('numcores'));
    
                    % Process Data Selection
                    parfor (rawDataFileIndex = 1:size(rawDataFileNames,2),parforOptions(parWorkers))

                        try

                            % Load .txt File
                            userSelectedData = getTextData.importData(fullfile(rawDataFilepaths,rawDataFileNames{rawDataFileIndex}));
            
                            % Get Row Indices of Key Word Pairs 
                            % "Section Header" ... "End Trial"
                            movementIndexPairArray = movementParser.parseRawData(userSelectedData);
            
                            % Parse Movements into Table via section Headers
                            rawDataTable = sectionBinner.raw2table(movementIndexPairArray,userSelectedData);
            
                            % Naming Schema (Remove any Extra Unexpected Spaces in
                            % Filename)
                            parsedSubjectfolder = strsplit(erase(rawDataFileNames{rawDataFileIndex}," "), "_");
            
                            % Study Name
                            projectStudyName = strcat(parsedSubjectfolder{3:4});
            
                            % Create Subject File Name
                            subjectFile = strjoin(parsedSubjectfolder(1:end-1),"_")+".mat";

                            % Suppress Warnings in Client and Parallel Pool
                            warning('off','all')
                            
                            % Generate Saving Directories
                            mkdir(fullfile(generalRootPath,"IMPORTED_RAW",projectStudyName));
            
                            % Save Raw Data Table and Add to Pathing
                            fileSavePath = fullfile(generalRootPath,"IMPORTED_RAW",projectStudyName,subjectFile);
                            saveFunction.saveData(rawDataTable,fileSavePath,"-mat"); 
                            importedDataFilePaths{rawDataFileIndex,1} = fileSavePath;

                        catch
                            % Load .txt File Again
                            userSelectedData = getTextData.importData(fullfile(rawDataFilepaths,rawDataFileNames{rawDataFileIndex}));

                            % Naming Schema (Remove any Extra Unexpected Spaces in
                            % Filename)
                            parsedSubjectfolder = strsplit(erase(rawDataFileNames{rawDataFileIndex}," "), "_");

                            % Create Subject File Name
                            subjectFile = strjoin(parsedSubjectfolder(1:end-1),"_")+".mat";
                            
                            % Generate Rejected Saving Directories
                            mkdir(fullfile(generalRootPath,"REJECTED"));
            
                            % Save Raw Data
                            fileSavePath = fullfile(generalRootPath,"REJECTED",subjectFile);
                            saveFunction.saveData(userSelectedData,fileSavePath,"-mat"); 
                        end
                    end
        
                end
                
                % Send Boolean Report for Import Completion
                importRawCompleteBoolean = true;
            else
                % Send Boolean Report for Import Incomplete
                importRawCompleteBoolean = false;
                generalRootPath = [];
                importedDataFilePaths = [];
                parWorkers = [];
            end
        end
    end
end