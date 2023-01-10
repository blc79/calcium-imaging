%%%HIGHER LEVEL SEPARATION OF RESPONSE TYPES: 

%DON'T JUST GET ALL LEVER PRESS INDICES; SEPARATE BY RESPONSE TYPE (AVOID
%VS. ESCAPE) 

    %WILL ALSO BE ABLE TO SEPARATE OUT RESPONSES BASED ON IF LEVER/LIGHT WAS
    %ATTENDED VS. NOT 
        %RESPONSE TO FIRST SHOCK IN TRIAL, VS. SECOND, THIRD, ETC 

%OPEN CELLTRACE FILE AND BEHAVIOR DATA FILE
    %within cellVars.eventIndices, we can see the trialStartIdx for each
    %trial; separate by if that trial went on to result in an avoid,
    %escape, or failure: 
    trialStartIdx = cellVars.eventIndices.cellTrace_trialStartIdx;
    avoidTrials = behaviorData.responseType.avoidTrials;
    avoidTrials_trialStartIdx = trialStartIdx(avoidTrials); 

    escapeTrials = behaviorData.responseType.escapeTrials; 
    escapeTrials_trialStartIdx = trialStartIdx(escapeTrials); 

    failTrials = behaviorData.responseType.failTrials;
    failTrials_trialStartIdx = trialStartIdx(failTrials); 

    %same thing for lever out indices: 
    leverOutIdx = cellVars.eventIndices.cellTrace_leverOutIdx;
        avoidTrials_leverOutIdx = leverOutIdx(avoidTrials);
        escapeTrials_leverOutIdx = leverOutIdx(escapeTrials);
        failTrials_leverOutIdx = leverOutIdx(failTrials);

   %lever press indices: 
   leverPressIdx = cellVars.eventIndices.cellTrace_leverOutIdx; 
        avoidTrials_leverPressIdx = leverPressIdx(avoidTrials);
        escapeTrials_leverPressIdx = leverPressIdx(escapeTrials);
        
  %shock indices:
        

   