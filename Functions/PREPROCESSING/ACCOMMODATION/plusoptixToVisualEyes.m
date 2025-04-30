classdef plusoptixToVisualEyes
    methods(Static)
        function fileConverter(OS_ACC,OS_Pupil,OS_Vert,OD_ACC,OD_Pupil,OD_Vert,triggerData,selectedProtocol,fileName)
            %% Anonymous Functions

            % Creates a Padded Cell Matrix Based on Boolean and Distance
            padMatrix = @(cellData, distanceValue, roundBoolean) [cellData;cellData(end,:).*ones((roundBoolean*distanceValue),size(cellData,2))]; 

            % Evaluate the Sizing to See if Mod(N,50) > .5
            sizeCheck = @(cellData) padMatrix(cellData,50-mod(size(cellData,1),50),round((mod(size(cellData,1),50))/50));

            % Trim Matrix to be in lengths of 50*N
            % mod(50) is due to the sampling rate of PlusOptix being 50Hz
            squareMatrix = @(cellData) cellData(1:(size(cellData,1) - mod(size(cellData,1),50)),:);

            % VisualEyes Data Format Generator
            dataInjection = @(tableOfData,movementTitle) [movementTitle;"Collected";"Date Time";"Delta T";"0.02000";...
                       "Right Eye Horizontal";tableOfData(:,4);...
                        "Left Eye Horizontal";tableOfData(:,1);...
                        "Left Eye Vertical";tableOfData(:,3);...
                        "Left Eye Pupil";tableOfData(:,2);...
                        "Right Eye Vertical";tableOfData(:,6);...
                        "Right Eye Pupil";tableOfData(:,5);"End Trial"];
            
            %% Extract Only Meaningful Variables for Analysis
            % LeftPupilDiameter, LeftRefraction, RightPupilDiameter,% RightRefraction
            if(isempty(OS_Vert)||isempty(OD_Vert))
                OS_Vert = zeros(size(OS_ACC,1),1);
                OD_Vert = zeros(size(OD_ACC,1),1);
            end

            % Check Trigger Data
            if(isempty(triggerData))
                triggerData = zeros(size(OD_ACC,1),1);
            end

            % Form Data Blocks
            % LE ACC, LE PUP, LE VERT, RE ACC, RE PUP, RE VERT, Trigger
            extractedTableData = [OS_ACC,OS_Pupil,OS_Vert,OD_ACC,OD_Pupil,OD_Vert,triggerData];
            
            %% Split Accommodative Responses
            
            currentRowIndex = 1;
            movementDataArray = {};
            numberOfMovements = 1;
            
            % Check Through Data File for All Triggered Data 
            while(currentRowIndex <= size(extractedTableData,1))
                % Trigger Boolean is Always last (END) column of extractedTable var
            
                % If True Flag (Movement Recorded)
                if(extractedTableData(currentRowIndex,end)==1)
                    % Capture Being Index of Movement
                    movementStartIndex = currentRowIndex;
            
                    % Iterate until Trigger Turns False (End of Movement)
                    while(currentRowIndex <= size(extractedTableData,1) && extractedTableData(currentRowIndex,end)==1 )
                        currentRowIndex = currentRowIndex+1;
                    end
                    % Return All Data Except Trigger Column (end - 1)
                    movementDataArray{numberOfMovements} = extractedTableData(movementStartIndex:currentRowIndex,[1:end-1]);
                    numberOfMovements = numberOfMovements + 1;
                % Ignore Any Other Value
                else
                    currentRowIndex = currentRowIndex + 1;
                end
            
            end
            
            % Cell Function to Apply Anonymous Function to Size Matrix and Trim Matrix to 50
            sizedData = cellfun(sizeCheck, movementDataArray, 'UniformOutput', false);
            squaredData = cellfun(squareMatrix, sizedData, 'UniformOutput', false);
            
            % Format Data for Visual Eyes (Put the Raccoons in the Trench Coat)
            % Movement Headers Per Column
            % Sequence Index Per Row
            movementHeaderList = selectedProtocol.Properties.VariableNames;
            visualEyesCompatibleData = [];
            
            % Iterate through each Movement Type Header
            for (movementHeaderIndex = 1: size(selectedProtocol,2))
            
                % Get Movement Name
                movementHeaderName = movementHeaderList{movementHeaderIndex};
            
                % Get All Sequences Below Header Name which are NOT NaNs
                movementIndexNumbers = selectedProtocol{~isnan(selectedProtocol.(movementHeaderName)),movementHeaderIndex};
            
                % Collect All Movements Per Col and Index and Append to form .txt
                % compatible matrix
                dataCell = {squaredData{1,movementIndexNumbers}};
                for movementCounts = 1:size(dataCell,2)
                    currentData = dataCell(movementCounts);
                    visualEyesCompatibleData = [visualEyesCompatibleData;dataInjection(currentData{:},movementHeaderName)];
                end
            end
            
            % Save the Formatted Data at Text File for ReVAMP
            outputFileName = fullfile("revampData/RAW/",strcat(fileName,".txt"));
            writelines(visualEyesCompatibleData,outputFileName)
        end
    end
end




















