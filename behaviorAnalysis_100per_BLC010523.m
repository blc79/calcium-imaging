%BEHAVIOR ANALYSIS: EXTRACTING INFO FROM A.PROC 

%AT THIS POINT, PROCESSING EACH MOUSE 1 AT A TIME 
%BE WITHIN THE SUBFOLDER WHERE YOU WANT YOUR DATA TO SAVE! 

%DATA WILL BE SAVED INTO A NEW .MAT FILE CALLED "BEHAVIOR DATA" 

%FOR NOW, HAVE TO MANUALLY SELECT FILE YOU WANT TO OPEN 

%once file is open, we can autopopulate subject ID and date
subjectID = A.subject; 
date = A.date; 

%navigate to A.proc 
data = A.proc;
numTrials = length(data);

%WE WANT TO CREATE AN INDEX FOR EACH TRIAL OF IF A SHOCK OCCURED AND HOW
%MANY; CAN USE THIS TO KNOW THE TRIAL RESPONSE TYPE 
shockByTrial = [];
for i =1:numTrials
    shockByTrial(i,1) = data(i).trial;
    shockByTrial(i,2) = data(i).numShock;
end 

%AVOID TRIALS; ZERO SHOCKS DELIVERED 
avoidTrials = [];
avSearch = find(shockByTrial(:,2) == 0);
for i =1:length(avSearch)
    avoidTrials(i,1) = shockByTrial(avSearch(i,1),1);
end 
%HOW MANY TRIALS WERE AVOID TRIALS? 
pAvoid = length(avoidTrials)/numTrials;

%ESCAPE TRIALS: MORE THAN 0 SHOCKS, LESS THAN 5 SHOCKS 
escapeTrials = [];
escSearch = find(shockByTrial(:,2) > 0 & shockByTrial(:,2) <5);
for i =1:length(escSearch)
    escapeTrials(i,1) =shockByTrial(escSearch(i,1),1);
end 
%PERCENT ESCAPE? 
pEscape = length(escapeTrials)/numTrials;

%TRIAL FAILURES: ALL 5 SHOCKS DELIVERED
failTrials = [];
fSearch = find(shockByTrial(:,2) == 5);
for i =1:length(fSearch)
    failTrials(i,1) = shockByTrial(fSearch(i,1),1);
end 
%PERCENT FAIL? 
pFail = length(failTrials)/numTrials;

%WE WANT TO SAVE ALL OF THIS INFO INTO A STRUCTURE; 
%A isn't very large: can save all of that info as well in "meta data" 
behaviorData = struct;
behaviorData.metaData = A; 
behaviorData.outcomes.pAvoid = pAvoid; 
behaviorData.outcomes.pEscape=pEscape;
behaviorData.outcomes.pFail = pFail; 
behaviorData.responseType.trialNum = numTrials; 
behaviorData.responseType.avoidTrials = avoidTrials; 
behaviorData.responseType.escapeTrials = escapeTrials;
behaviorData.responseType.failTrials = failTrials; 

clearvars -except behaviorData date subjectID;
%WHAT OTHER INFO DO WE WANT TO KNOW? 
%LATENCY TO LEVER PRESS ON EACH TRIAL 

% navigate to A.proc: saved within behaviorData.metaData: 
%want to extract behaviorData.metaData.proc.presstime_rel 
pressTimes = [];
for i =1:length(behaviorData.metaData.proc)
    pressTimes{i,1} = behaviorData.metaData.proc(i).presstime_rel; 
end 

%now we have all the values but in a cell array; want to be able to see
%each individual press time 
b = length(pressTimes); 
for j =1:b
    convertPress=pressTimes{j,1};
    a = length(convertPress);
    storePress(j,1:a)=convertPress;

end 

firstPress = storePress(1:b,1);
%%want to average across press latencies, but do not want to include trials
%%when an animal did not make a lever press 
hasPress = find(firstPress ~=0); 
pressResponse = firstPress(hasPress,1);
avgFirstPress = mean(pressResponse); 

%want to save press times during each trial, average press latency, and
%number of trials when they HAD a press 
%BE SURE TO SAVE THIS INFO IN SECONDS (CONVERT FROM MS) 
firstPressSec = firstPress/1000; 
avgFirstPressSec = avgFirstPress/1000; 

behaviorData.pressData.pressTimesByTrial = firstPressSec;
behaviorData.pressData.avgPressLatency = avgFirstPressSec; 
behaviorData.pressData.trialsWithPress = length(hasPress);
behaviorData.pressData.totalTrials = length(firstPress);

save(strcat(subjectID,'_',date,'_behaviorData'),'behaviorData');
clear; 