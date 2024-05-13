% Get User Selected Raw Data Filepaths
[rawDataFileNames,rawDataFilepaths] = uigetfile("..\REVAMP\revampDATA\RAW\*.txt", "MultiSelect","on");

% Get Save Directory for Modified Files
saveFilePathway = uigetdir("\Desktop\","Select Save Location");

% Parallel for Fast Processing
parWorkers = parpool(feature('numcores'));

% Iterate Across Selection
parfor (fileIndex = 1:size(rawDataFileNames,2),parWorkers)
    % Load .txt File
    rawDataArray = getTextData.importData(fullfile(rawDataFilepaths,rawDataFileNames{fileIndex}));

    % Get Row Indices of Key Word Pairs 
    % "Section Header" ... "End Trial"
    indexPairArray = movementParser.parseRawData(rawDataArray);

    % Turns off General Warnings for Table row additions with other
    % adjacent cols being empty
    warning('off','all')

    % Find Missing Data Headers
    missingHeaderIndex = find(ismissing(rawDataArray(indexPairArray(:,1))));
    findSteps = find(or(or(contains(rawDataArray(indexPairArray(:,1)),"Conv_"),contains(rawDataArray(indexPairArray(:,1)),"Div_")),ismissing(rawDataArray(indexPairArray(:,1)))));

    % Divide Missing Header Index
    missingDivergentHeaders = missingHeaderIndex(1:size(missingHeaderIndex,1)/2);
    missingConvergentHeaders = missingHeaderIndex(size(missingHeaderIndex,1)/2+1:end);

    % Inject Section Header
    rawDataArray(indexPairArray(missingDivergentHeaders,1)) = "Div_8_2";
    rawDataArray(indexPairArray(missingConvergentHeaders,1)) = "Conv_8_12";

    % Clean Up Section Names
    rawDataArray(indexPairArray(findSteps,1)) = strcat(rawDataArray(indexPairArray(findSteps,1)),"_Step");

    writematrix(rawDataArray,fullfile(saveFilePathway,rawDataFileNames{fileIndex}))
end

% Clean Up
delete(parWorkers);

