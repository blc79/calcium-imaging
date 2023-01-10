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

%FIRST THING TO DO IS SEPARATE NULL AND REINFORCED TRIALS: 
trialInfo = A.proc; 
reinforced = [];
null = [];
trialType = [];

a = length(trialInfo); %NUMBER OF TOTAL TRIALS IN SESSION
for i =1:a 
    trialType(i,1) = trialInfo(i).trialType; 
end 

for i = 1:length(A.proc)
    trialType(i,1) = A.proc(i).trialType;
end 

reinforcedTrialIdx = find(trialType == 1);
nullTrialIdx = find(trialType == 0); 

%WHAT INFO DO WE WANT TO KNOW ABOUT THE REINFORCED TRIALS? RESPONSE TYPES,
%RESPONSE TIMES 

%FIRST LETS FIND THE RESPONSE TYPE (AVOID, ESCAPE, FAIL) 
%reinforced trial IDX is an index of the reinforced trial numbers; we want
%to know how many shocks occured on each of those trials to tell us the
%response type: 
c =length(reinforcedTrialIdx);
reinforcedShocks = [];
for i = 1:c 
   reinforcedShocks(i,1) = trialInfo(reinforcedTrialIdx(i,1)).numShock; 
end 

%FIND THE AVOID TRIALS (ZERO SHOCKS DELIVERED) 
avoidTrials = [];
avSearch = find(reinforcedShocks(:,1)==0);
%avSearch gives us the positions  of reinforced shocks where 0 shocks were
%delivered; those same positions within reinforcedTrialIdx will tell us the
%actual trials that were avoided: 
for i =1:length(avSearch)
    avoidTrials(i,1) = reinforcedTrialIdx(avSearch(i,1),1);
end 
%we also want to know how many trials (of the reinforced trials) were
%avoided: 
pAvoid = length(avoidTrials)/length(reinforcedTrialIdx); 

%FIND ESCAPE TRIALS (GREATER THAN 0, LESS THAN 5 SHOCKS DELIVERED) 
escapeTrials = [];
escSearch = find(reinforcedShocks(:,1) > 0 & reinforcedShocks(:,1) <5);
%escSearch gives us the positions of reinforced shocks where 1-4 shocks
%were delivered; those same positions in reinforcedTrialIdx will tell us
%which trials were escaped: 
for i =1:length(escSearch)
    escapeTrials(i,1)=reinforcedTrialIdx(escSearch(i,1),1);
end
%percent escape? 
pEscape = length(escapeTrials)/length(reinforcedTrialIdx); 

%FIND FAILED TRIALS (ALL 5 SHOCKS DELIVERED) 
failTrials = [];
fSearch = find(reinforcedShocks(:,1) == 5);
for i =1:length(fSearch)
    failTrials(i,1)=reinforcedTrialIdx(fSearch(i,1),1);
end 
%percent fail? 
pFail = length(failTrials)/length(reinforcedTrialIdx); 

%WE WANT TO SAVE ALL OF THIS INFO WITHIN A STRUCTURE: 
%ALSO SAVE THE INFO STORED IN "A" 
behaviorData = struct; 
behaviorData.metaData = A;
behaviorData.outcomes.reinforced.pAvoid = pAvoid; 
behaviorData.outcomes.reinforced.pEscape = pEscape;
behaviorData.outcomes.reinforced.pFail = pFail;
behaviorData.responseType.reinforced.trialNum = length(reinforcedTrialIdx);
behaviorData.responseType.reinforced.avoidTrials = avoidTrials;
behaviorData.responseType.reinforced.escapeTrials = escapeTrials;
behaviorData.responseType.reinforced.failTrials = failTrials; 

%REPEAT THIS PROCESS FOR NULL TRIALS! 
%WHAT INFO DO WE WANT TO KNOW ABOUT NULL TRIALS? 
%we know that all 5 shocks will be delivered, regardless of behavior
%but we want to know how many overall presses are made per trial, and if
%they are avoid responses or escape responses

%STEP ONE; GET THE RELATIVE PRESS TIMES FOR ALL NULL TRIALS: 
pressTimes = [];
for i =1:length(A.proc)
    pressTimes{i,1} = A.proc(i).presstime_rel; 
end 

%now we have all the values but in a cell array; want to be able to see
%each individual press time 
b = length(pressTimes); 
for j =1:b
    convertPress=pressTimes{j,1};
    a = length(convertPress);
    storePress(j,1:a)=convertPress;

end 

%need to extract press info from just the null trials 
null_pressInfo = [];
for i =1:length(nullTrialIdx)
    null_pressInfo(i,:) = storePress(nullTrialIdx(i,1),:);
end 

%now that we have "null press info" we want to know how many presses
%happened before 22000 (time of light off / shock on) 

%FIND AVOID ATTEMPTS; THESE ARE ALL TRIALS WITH A LEVER PRESS BEFORE
%22000MS 
%go through all the null trials and get a log of if there was an avoid
%attempt or not: then can compare that with the actual trial within the
%session it was (stored in nullTrialIdx) 
avAttSearch = [];
pos = size(null_pressInfo,2);
for i =1:size(null_pressInfo,1) 
    tempAvoidAttempt = find(null_pressInfo(i,1:pos) < 22000 & null_pressInfo(i,1:pos) > 0); 
    v = length(tempAvoidAttempt);
    avAttSearch(i,1:v) = tempAvoidAttempt;
end 

%avAttSearch gives us the indices for each null trial of where there was an
%avoid attempt 
%same positions within nullTrialIdx tell us the actual trials with avoid
%attempts 
%GET A SUM OF AVATTSEARCH; ANY NONZERO VALUES HAVE AVOID ATTEMPTS; THIS WAY
%WE CAN FIND WHICH ACTUAL TRIALS IN THE SESSION ARE AVOID ATTEMPTS 
sumAvAtt = sum(avAttSearch,2); 
findAvAtt = find(sumAvAtt > 0); 
avoidAttemptTrials = nullTrialIdx(findAvAtt); 

%HOW MANY AVOID ATTEMPTS PER TRIAL? 
%HOW MANY OF THE NULL TRIALS HAD AVOID ATTEMPTS? 
pAvoidAttempt = length(findAvAtt)/length(sumAvAtt);

%total number of avoid attempts in the session? 
totalAvAttempt = sum(sumAvAtt);
avgAvAtt_forAllNullTrials = totalAvAttempt / length(sumAvAtt);
%on sessions that had an avoid attempt, how many on average did they have?
avgAvAtt_perAvoidAttemptTrials = totalAvAttempt / length(findAvAtt);

%SAME PROCESS FOR ESCAPE ATTEMPTS: 
%THESE ARE ALL TRIALS WITH A LEVER PRESS AFTER 22000MS 
%go through all the null trials and get a log of if there was an escape 
%attempt or not: then can compare that with the actual trial within the
%session it was (stored in nullTrialIdx) 
escAttSearch = [];
pos = size(null_pressInfo,2);
for i =1:size(null_pressInfo,1) 
    tempEscAttempt = find(null_pressInfo(i,1:pos) > 22000);
    v = length(tempEscAttempt);
   escAttSearch(i,1:v) = tempEscAttempt;
end 

%escAttSearch gives us the indices for each null trial of where there was an
%escape attempt 
%same positions within nullTrialIdx tell us the actual trials with escape
%attempts 
%GET A SUM OF ESCATTSEARCH; ANY NONZERO VALUES HAVE ESCAPE ATTEMPTS; THIS WAY
%WE CAN FIND WHICH ACTUAL TRIALS IN THE SESSION ARE ESCAPE ATTEMPTS 
sumEscAtt = sum(escAttSearch,2); 
findEscAtt = find(sumEscAtt > 0); 
escapeAttemptTrials = nullTrialIdx(findEscAtt);

%HOW MANY ESCAPE ATTEMPTS PER TRIAL? 
%HOW MANY OF THE NULL TRIALS HAD ESCAPE ATTEMPTS? 
pEscapeAttempt = length(findEscAtt)/length(sumEscAtt);

%total number of escape attempts in the session? 
totalEscAttempt = sum(sumEscAtt);
avgEscAtt_forAllNullTrials = totalEscAttempt / length(sumEscAtt);
%on sessions that had an avoid attempt, how many on average did they have?
avgEscAtt_perEscapeAttemptTrials = totalEscAttempt / length(findEscAtt);


%SAME PROCESS FOR NULL FAILS: 
%THESE ARE ALL NULL TRIALS WITHOUT ANY LEVER PRESSES 
%go through all the null trials and get a trials without a lever press: then can compare that with the actual trial within the
%session it was (stored in nullTrialIdx) 
nullFailSearch = [];
sumPress_nullTrials = sum(null_pressInfo,2);
for i =1:size(sumPress_nullTrials,1) 
    tempNullFail = find(sumPress_nullTrials(i,1) ==0);
    v = length(tempNullFail);
   nullFailSearch(i,1:v) = tempNullFail;
end 

%nullFailSearch gives us the indices for each null trial of where there was
%a null fail
%same positions within nullTrialIdx tell us the actual trials with null
%failures
%GET A SUM OF NULLFAILSEARCH; ANY NONZERO VALUES HAVE FAILS; THIS WAY
%WE CAN FIND WHICH ACTUAL TRIALS IN THE SESSION ARE NULL FAILS 

%NEED TO FIND A WAY TO SAVE TRIALS WITH NULL FAILS: HAVE TO FIND A SUBJECT
%THAT HAS ONE FIRST!!!! 

%WE WANT TO SAVE ALL OF THIS INFO WITHIN A STRUCTURE: 
behaviorData.outcomes.null.pAvoidAttempt = pAvoidAttempt; 
behaviorData.outcomes.null.pEscapeAttempt = pEscapeAttempt;
behaviorData.outcomes.null.avgAvAtt_forAllNullTrials = avgAvAtt_forAllNullTrials;
behaviorData.outcomes.null.avgAvAtt_perAvoidAttemptTrials = avgAvAtt_perAvoidAttemptTrials; 
behaviorData.outcomes.null.avgEscAtt_forAllNullTrials = avgEscAtt_forAllNullTrials; 
behaviorData.outcomes.null.avgEscAtt_perEscapeAttemptTrials = avgEscAtt_perEscapeAttemptTrials; 
behaviorData.responseType.null.trialNum = length(nullTrialIdx);
behaviorData.responseType.null.avoidAttemptTrials = avoidAttemptTrials;
behaviorData.responseType.null.escapeAttemptTrials = escapeAttemptTrials;

%PRESS LATENCIES! 

% FIRST FOR REINFORCED TRIALS: THAT'S EASIER: 
%pull all reinforced trials from "storePress":
reinforced_pressInfo = [];
for i =1:length(reinforcedTrialIdx)
   reinforced_pressInfo(i,:) = storePress(reinforcedTrialIdx(i,1),:);
end 

%%want to average across press latencies, but do not want to include trials
%%when an animal did not make a lever press 
hasPress = find(reinforced_pressInfo ~=0); 
reinforced_pressTrials = reinforced_pressInfo(hasPress,1);
reinforced_avgFirstPress = mean(reinforced_pressTrials); 

%want to save press times during each trial, average press latency, and
%number of trials when they HAD a press 
%BE SURE TO SAVE THIS INFO IN SECONDS (CONVERT FROM MS) 
reinforced_pressResponse = reinforced_pressInfo / 1000;
reinforced_pressResponse = reinforced_pressResponse(:,1);
reinforced_avgPressLatency = reinforced_avgFirstPress / 1000; 

%same thing for null trials: first, let's store the time of the first
%press: 
%first press = first column of null_pressInfo 
null_firstPress = null_pressInfo(:,1); 
hasPress_null = find(null_firstPress ~=0);
null_pressTrials = null_firstPress(hasPress_null,1); 
null_avgFirstPress = mean(null_pressTrials); 

%want to save press times during each trial, average press latency, and
%number of triasl when they had a press: 
null_pressResponse = null_firstPress / 1000; 
null_avgPressLatency = null_avgFirstPress / 1000; 

%we want to save all of this press latency data: 
behaviorData.pressData.reinforcedPressResponse = reinforced_pressResponse;
behaviorData.pressData.reinforced_avgPressLatency = reinforced_avgPressLatency;
behaviorData.pressData.nullPressResponse = null_pressResponse;
behaviorData.pressData.null_avgPressLatency = null_avgPressLatency; 

%%OTHER VERY IMPORTANT INFO TO KNOW; WHAT IS THE LATENCY TO PROCESS AFTER A
%%NULL VS. REINFORCED TRIAL: 
%TRIALTYPE TELLS US WHAT TYPE OF TRIAL EACH TRIAL IS 

%we want to ask, for trials 2 through 50, what was the PREVIOUS trial type?
prevTrialType = circshift(trialType,1);
prevTrialType(1,1) = NaN; 

%now, find all trials that followed a reinforced trial: 
afterReinforced = find(prevTrialType ==1); 
afterNull = find(prevTrialType ==0);

%now we need to find the press latencies for these trials: 
logFirstPress = storePress(:,1);
afterReinforced_press = logFirstPress(afterReinforced,1); 
afterNull_press = logFirstPress(afterNull,1); 

%remove any trials when they didn't press from avg latency: 
afterReinforced_press_nonzero = find(afterReinforced_press ~= 0); 
afterReinforced_pressResponses = afterReinforced_press(afterReinforced_press_nonzero,1); 
afterReinforced_pressLatency = mean(afterReinforced_pressResponses)/1000; 

afterNull_press_nonzero = find(afterNull_press ~=0); 
afterNull_pressResponses = afterNull_press(afterNull_press_nonzero,1);
afterNull_pressLatency = mean(afterNull_pressResponses)/1000; 

%want to save this info: 
behaviorData.pressData.afterReinforced_pressLatency = afterReinforced_pressLatency; 
behaviorData.pressData.afterNull_pressLatency = afterNull_pressLatency; 
%I'm thinking about probability to make an avoid response or an escape
%response if you are following a null vs. reinforced trial: 
%we can get this info by looking at the press latency: 
afterReinforced_avAttSearch = find(afterReinforced_press < 22000 & afterReinforced_press > 0);
afterReinforced_pAvoidAttempt = length(afterReinforced_avAttSearch)/length(afterReinforced_press); 
afterNull_avAttSearch = find(afterNull_press < 22000 & afterNull_press > 0); 
afterNull_pAvoidAttempt = length(afterNull_avAttSearch)/length(afterNull_press);

%want to save this info: 
behaviorData.outcomes.afterReinforced_pAvoidAttempt = afterReinforced_pAvoidAttempt;
behaviorData.outcomes.afterNull_pAvoidAttempt = afterNull_pAvoidAttempt; 


%i think this is all of the data I want for now: 
sessionSpecific = A.sessionSpecific; 
save(strcat('m',subjectID,'_',sessionSpecific,'_behaviorData.mat'),'behaviorData');
clear;