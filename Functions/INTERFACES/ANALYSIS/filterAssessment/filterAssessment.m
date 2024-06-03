 

 % Select File Pathway and File(s) to Process
 [userSelectedFilePath, userSelectedFile] = loadData.getTableData();
  currentTableData = loadData.loadTableData(userSelectedFilePath,userSelectedFile);
  data = extractMovementData(currentTableData);
 
    Fs = 500;            % Sampling frequency                    
    T = 1/Fs;             % Sampling period       
    L = size(data, 1);    % Length of signal
    t = (0:L-1)*T;        % Time vector

  for window = 3:2:51
       sectionFFT = createFFTData(movmedian(diff(data(:, 1)), window));
       sectionVelocity = movmedian(diff(data(:, 1)), window);

      for i = 2:size(data, 2)
          sectionFFT = sectionFFT + createFFTData(movmedian(diff(data(:, i)), window));
          sectionVelocity = sectionVelocity + movmedian(diff(data(:, i)), window);
    
      end
    maxVelocity = max(sectionVelocity);
    temp = figure;
    set(temp, "Visible", "off");
    plot(sectionFFT,"LineWidth",1) 
    title(strcat("FFT", string(window), " Single-Sided Spectrum"))
    ylabel("|P|")
    saveas(temp, fullfile("C:\Users\visionDeveloper\Desktop\powerAnalysisPlots", strcat("fft", string(window))), 'meta');
    
    t = 1:(size(sectionVelocity))
    temp2 = figure;
    set(temp2, "Visible", "off");
    plot(sectionVelocity,"LineWidth",1) 
    title(strcat("Filter Window ", string(window), " Combined Horizontal Velocity Plot"))
    ylabel("Velocity")
    xlabel("Samples")
    saveas(temp2, fullfile("C:\Users\visionDeveloper\Desktop\powerAnalysisPlots", strcat("velocity", string(window))), 'meta');
  
  end


  

   
    
  function horizontalExtractedMovementData = extractMovementData(currentTableData)
            
            sectionName = "4_8_CONV_STEP";
            % Set default values
            horizontalExtractedMovementData = [];

            % Extract Non-empty cells (cells with movement data)
            selectedMovementData = {currentTableData.(sectionName){~cellfun(@isempty,currentTableData.(sectionName))}}';
            
            % Pull out streams
            horizontalExtractedMovementData = tableDataExtractor(selectedMovementData, "Combined Horizontal");            
 end

function extractedTableData = tableDataExtractor(cellTableArray, extractionHeader)
            % Determine Largest Sample Length for Plotting
            maxSamplesList = cellfun(@max,cellfun(@size,cellTableArray,'UniformOutput',false));
            minSamples = min(maxSamplesList);
           

            % Preallocate Space 
            % Number of Rows based on First Cell Array Value
            % Number of Cols based on Size of Cell Array
            extractedTableData = nan(minSamples,size(cellTableArray,1));
            for cellIndex = 1:size(cellTableArray,1)
                    extractedTableData(1:minSamples,cellIndex) = cellTableArray{cellIndex}.(extractionHeader)(1:minSamples);
            end
end

function FFTValues = createFFTData(extractedData)
            fouriervalues = fft(extractedData);
            tempfourier = abs(fouriervalues/(size(extractedData,1)));
            FFTValues = tempfourier(1:(size(extractedData,1)/2)+1);
            FFTValues(2:end-1) = 2* FFTValues(2:end-1);
        end