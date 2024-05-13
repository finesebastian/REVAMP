% Class for Analyzing Metrics
classdef findMetrics
    methods(Static)
    
        % Find Peak Velocity
        function [foundPeakVelocity,foundTimeToPeakVelocity] = findPeakVelocity(referenceIndex, searchWindowSize, dataChannel, samplingRate)
            % Preliminary Index Validation
            % Index is too close to START of data channel
            if (referenceIndex - searchWindowSize <= 0)
                startSearchWindowIndex = 1;
            % Index is too close to END of data channel
            elseif(referenceIndex+searchWindowSize > size(dataChannel,1))
                endSearchWindowIndex = size(dataChannel,1);
            % Window is too large for data channel
            elseif(referenceIndex - searchWindowSize <= 0 && referenceIndex+searchWindowSize > size(dataChannel,1))
                startSearchWindowIndex = 1;
                endSearchWindowIndex = size(dataChannel,1);
            % Everything is OKAY
            else
                startSearchWindowIndex = referenceIndex - searchWindowSize;
                endSearchWindowIndex = referenceIndex + searchWindowSize;
            end

            % Create Data Segment
            searchInterval = dataChannel(startSearchWindowIndex:endSearchWindowIndex,1);

            % Return Found Peak Velocity
            [~, foundPeakVelocityIndex] = max(abs(searchInterval));
            foundPeakVelocity = searchInterval(foundPeakVelocityIndex);

            % Return Peak Velocity Index
            foundTimeToPeakVelocity = (startSearchWindowIndex + foundPeakVelocityIndex)/samplingRate;

        end

        % Find Response Amplitude utilizing two points of reference and two
        % booleans for validation
        function foundResponseAmplitude = findResponseAmplitude(startReferenceIndex, startReferenceBoolean, endReferenceIndex, endReferenceBoolean, dataChannel)
            % If both booleans are true find differnce in position
            if(startReferenceBoolean && endReferenceBoolean)
                foundResponseAmplitude = dataChannel(endReferenceIndex,1) - dataChannel(startReferenceIndex,1);

            % Else return NaN until both booleans are true
            else
                foundResponseAmplitude = nan;
            end
        end

        % Find Final Amplitude as last 10% of Movement
        function foundFinalAmplitude = findFinalAmplitude(dataChannel)
            % Determine 10% Interval
            finalAmplitudeInterval = floor(size(dataChannel,1)*.1);

            % Return Found Final Amplitude
            foundFinalAmplitude = mean(dataChannel(end-finalAmplitudeInterval:end));
        end

        % Return a conversion of index sample to sampling rate 
        function convertedLatency = findLatency(latencyReferenceIndex, samplingRate)
            convertedLatency = latencyReferenceIndex/samplingRate;
        end

    end
end