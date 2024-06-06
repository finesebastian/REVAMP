% Find Impulses within Point to Point Velocity Trace 
classdef blinkRemoval
    methods(Static)
        function blinkIndices = findBlinks(tableData)
            % Calculated variables
            combinedVertical = abs(tableData.("Left Eye Vertical")) + abs(tableData.("Right Eye Vertical"));

            % Moving median 50 samples / 500 Hz = 0.1 seconds
            smoothedCombinedVertical = movmedian(combinedVertical, 50);

            % Evaluate if there are any outliers
            % TF, LowerLimit, UpperLimit, Center
            % Defined by 3 Median Absolute Deviations
            outlierBooleanMatrix = isoutlier(smoothedCombinedVertical);

            % Check for the Outliers if their Amplitude is >5 to the
            % relative median of the vertical trace
            outlierBooleanMatrix(outlierBooleanMatrix) = combinedVertical(outlierBooleanMatrix)>5+median(combinedVertical(outlierBooleanMatrix));

            % Check if Boolean Values (0 - False, 1 - True) sums are >0
            % (has Outliers) or =0 (No Outliers)
            if(sum(outlierBooleanMatrix)~=0)
                % Outliers Have Been Identified
                % Create Map of Onset/Offset of Outliers
                outlierIndex = [0;diff(outlierBooleanMatrix)];

                % Create Default Data for Boundaries
                initialBoundary = [];
                endBoundary = [];

                % Check Start Condition Outlier
                if(outlierBooleanMatrix(1))
                    % First Data Point in blink is 1
                    initialBoundary = 1;
                end

                % Check End Condition Outlier
                if(outlierBooleanMatrix(end))
                    endBoundary = size(outlierIndex,1);
                end

                % Create Pairs of Start/End with Evaluations
                % 1 Denotes a rise 0 -> 1 (Start) w/ 25 Sample Buffer
                indexPairs(:,1) = [initialBoundary;find(outlierIndex ==1) - 25];
                % -1 Denotes a fall 1 -> -1 (End) w/ 25 Sample Buffer
                indexPairs(:,2) = [find(outlierIndex == -1) + 25;endBoundary];

                % Ensure no values below 0 or above size(file)
                indexPairs(indexPairs <= 0) = 1;
                indexPairs(indexPairs > size(outlierBooleanMatrix,1)) = size(outlierBooleanMatrix,1);

                % Assess Edge Conditions
                % Blink Starts Movement Row 1 Col 2 < Row 1 Col 1
                if(indexPairs(1,1) > indexPairs (1,2))
                    % Prepare Shift Matrix
                    tempPairs = ones(size(indexPairs,1)+1,2);

                    % Shift First Col
                    tempPairs(2:end,1) = indexPairs(:,1);

                    % Original Second Col
                    tempPairs(1:end-1,2) = indexPairs(:,2);

                    % Update Values if Blink at Start Exists
                    indexPairs = tempPairs;
                end

                % Assess Edge Conditions
                % Blink End of Movement 
                % Row End Col 2 < Row End Col 1
                if(indexPairs(end,1) > indexPairs (end,2))
                    % Prepare Shift Matrix
                    indexPairs(end,2) = size(outlierIndex,1); 
                end

                overlappingIndex = false;
                rowsToRemove = [];

                % Evaluate Proximity of Identified Blink Pairs to Merge 
                % Subtract One Row for Forward Comparison
                for(rowIndex = 1:(size(indexPairs,1)-1))
                    rowComparisonIndex = rowIndex + 1;
                    % Check if Next Pair is Nearby
                    while(rowComparisonIndex <= size(indexPairs,1) && indexPairs(rowIndex,2) + 25 > indexPairs(rowComparisonIndex,1) )
                        % Merge Index Pairs of Col from Last to Col of
                        % First
                        indexPairs(rowIndex,2) = indexPairs(rowComparisonIndex,2);
                        % Store Duplicate Row
                        rowsToRemove = [rowsToRemove;rowComparisonIndex];
                        % Set Boolean for Row Removal
                        overlappingIndex = true;

                        % Index Comparison
                        rowComparisonIndex = rowComparisonIndex + 1;
                    end
                end

                % If Overlapping Indicies Remove Copies
                if(overlappingIndex)
                    indexPairs(rowsToRemove,:) = [];
                end

                % Return all Index Values
                blinkIndices = indexPairs;

            % No outliers
            else
                blinkIndices = [];
            end
            
        end

        % Replaces blinks with NaNs then with surrounding means
        function [blinkRemovedArray,blinkInTransientBoolean, numberOfBlinks] = removeBlinks(tableData,transientBlinkSampleThreshold)
            % Determine If Outliers Exist
            blinkIndexPairs = blinkRemoval.findBlinks(tableData);

            % Set Default Boolean
            blinkInTransientBoolean = false;

            % Set Default Blink Count
            numberOfBlinks = 0;

            % Outliers Found
            if(~isempty(blinkIndexPairs))
                numberOfBlinks = size(blinkIndexPairs,1);

                % Check First Pair for "Transient Blink Index" (Default 750) 
                if(blinkIndexPairs(1,1) <= transientBlinkSampleThreshold)
                    blinkInTransientBoolean = true;
                end

                % Iterate through index pairs
                for(blinkIndex = 1:size(blinkIndexPairs,1))
                    % Fill Table Outlier Pairs with NaN
                    tableData{(blinkIndexPairs(blinkIndex,1):blinkIndexPairs(blinkIndex,2)),:} = NaN;

                    % Check Index Pair 
                    % Start - Next Fill
                    if (blinkIndexPairs(blinkIndex,1) == 0)
                        % Fill with Next Value since beginning portion is
                        % missing (+1 Row index must exist otherwise blink
                        % would still continue)
                        tableData = fillmissing(tableData,"next");

                    % End - Previous Fill
                    elseif (blinkIndexPairs(blinkIndex,2) == size(tableData,1))
                        % Fill with Previous Value since end portion is
                        % missing (-1 Row index must exist otherwise blink
                        % would still continue)
                        tableData = fillmissing(tableData,"previous");

                    % Otherwise P-Chip Fill
                    else
                        tableData = fillmissing(tableData,"pchip");    
                    end
                end
            end
                % Run Small Window Filter to Smooth Edges
                tableData{:,:} = movmedian(tableData{:,:},50,1,"Endpoints","shrink");
                blinkRemovedArray = tableData;
        end
    end
end