classdef sectionHeaderConformer
    methods (Static)
        function conformedSectionHeaderList = standardizeSectionHeader(rawSectionHeaderList)
            % Bring Section Headers to Uppercase
            upperCaseSectionHeaders = upper(rawSectionHeaderList);

            % Establish Patterns for Standardizing Names
            % Calibration
            calPattern = "CAL" + ("S"|"");
            % Degrees
            degPattern = "DEG" + ("S"|"");
            % Saccades
            saccPattern = "SACC" + ("ADES"|"ADE"|"");
            % Vergence Steps
            stepPattern = "STEP" + ("S"|"");
            % Ramps
            rampPattern = "RAMP" + ("S"|"");
            % Convergence
            convPattern = "CON" + ("VERGENCE"|"V"|"");
            % Divergence
            divPattern = "DIV" + ("ERGENCE"|"");

            % Evaluate Patterns
            % Remove Special Symbols
            specialCharRemovedSectionHeaders = replace(upperCaseSectionHeaders,"@"," ");
            % Steps
            conformedSectionNames = replace(specialCharRemovedSectionHeaders,stepPattern, " STEP ");
            % Saccades
            conformedSectionNames = replace(conformedSectionNames,saccPattern, " SACC ");
            % Ramps
            conformedSectionNames = replace(conformedSectionNames,rampPattern, " RAMP ");
            % Convergence
            conformedSectionNames = replace(conformedSectionNames,convPattern, " CONV ");
            % Divergence
            conformedSectionNames = replace(conformedSectionNames,divPattern, " DIV ");
            % Calibration
            conformedSectionNames = replace(conformedSectionNames,degPattern, " DEG ");
            % Degrees
            conformedSectionNames = replace(conformedSectionNames,calPattern, " CAL ");

            % Flush out spaces with underscores 
            despacedCaseSectionHeaders = replace(conformedSectionNames," ","_");
            % Remove extranneous underscores (two or more consectuive
            % underscores)
            underScoreConformedSectionHeaders = regexprep(despacedCaseSectionHeaders,'_(_+)',"_");

            % Validate First and Last Character are not Underscores
            leadingCharReplacement = cellfun(@(firstCharacter) strcat(replace(firstCharacter(1),"_",""),firstCharacter(2:end)), ...
                underScoreConformedSectionHeaders,'UniformOutput',false);
            trailingCharReplacement = cellfun(@(trailingCharacter) strcat(trailingCharacter(1:end-1),replace(trailingCharacter(end),"_","")), ...
                leadingCharReplacement,'UniformOutput',false);
            

            % Send it 
            conformedSectionHeaderList = convertCharsToStrings(trailingCharReplacement);
        end
    end
end