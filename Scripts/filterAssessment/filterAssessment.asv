% Select File Pathway and File(s) to Process
 [userSelectedFilePath, userSelectedFile] = loadData.getTableData();
  currentTableData = loadData.loadTableData(userSelectedFilePath,userSelectedFile);
  data = extractMovementData(currentTableData);
  maxVelocities = [0];
 
    Fs = 500;            % Sampling frequency                    
    T = 1/Fs;             % Sampling period       
    L = size(data, 1);    % Length of signal
    t = (0:L-1)*T;        % Time vector

  for window = 3:2:51
       rawVelocity = movmedian([zeros(1, size(data, 2)); diff(data, 1, 1)], window, 1, "Endpoints", "shrink") .* 500;
       sectionFFT = createFFTData(rawVelocity(:, 1));
       sectionVelocity = mean(rawVelocity, 2);
       
      for i = 2:size(data, 2)
          sectionFFT = sectionFFT + createFFTData(rawVelocity(:, i));
      end
    [maxVelocity, maxVelocityIndex] = max(sectionVelocity);
    maxVelocities(end+1) = round(maxVelocity, 2);
    temp = figure;
    set(temp, "Visible", "off");
    plot((Fs/(size(sectionVelocity, 1)+1)) * (0:((size(sectionVelocity, 1)))/2), sectionFFT,"LineWidth",1)
    ylim([0 18]);
    title(strcat("FFT", string(window), " Single-Sided Spectrum"))
    ylabel("|P|")
    xlabel("Frequnecy (Hz)")

    temp2 = figure;
    set(temp2, "Visible", "off");
    plot(t, sectionVelocity,"LineWidth",1)
    ylim([-5 35]);
    xlim([0, size(sectionVelocity, 1)/Fs])
    hold on;
    plot(maxVelocityIndex/Fs, maxVelocity, "*");
    text(maxVelocityIndex/Fs + 0.2, maxVelocity - 0.01, strcat("Max = ", string(maxVelocity)));
    title(strcat("Filter Window ", string(window), " Combined Horizontal Velocity Plot"))
    ylabel("Velocity")
    xlabel("Time (s)")
    saveas(temp2, fullfile("C:\Users\visionDeveloper\Desktop\powerAnalysisPlots", strcat("velocity", string(window))), 'meta');
    hold off;
  
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