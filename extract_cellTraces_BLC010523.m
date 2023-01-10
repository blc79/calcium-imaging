%FROM EXTRACT GPIO SCRIPT, WE HAVE THE EXACT FRAME WHEN EVENTS OCCURED 
%WE WANT TO EXTRACT THE WINDOW OF CALCIUM ACTIVITY AROUND THAT EVENT
%OCCURING 

%STEP 1: 
    %open gpio file 
    %open cell trace file 

prompt = "Subject ID?";
subjectID= input(prompt,'s');
subjectID =string(subjectID);

prompt2 = "Session ID? (ex: fr1d1)"
session = input(prompt2,'s');
session= string(session); 

%we want to extract the time from cellVars
cellTrace_Times = cellVars.time; 

%we want to extract these peri-event histograms for each neuron (neurons
%represented in columns) 

%TRIAL START IDX: 
trialStartTimes = gpio_files.trialStartTimes; 

%another value that isn't saved in gpio file, but important to have, it
%lever extend times; this happens precisely 2s after trial start times: so
%add 2s to all values in trialStartTimes: 
leverOutTimes = trialStartTimes +2; 

%need to find the position in cellVars that are closest to the trial start
%TTL times from gpio 
for i = 1:length(trialStartTimes)
    n = trialStartTimes(i,1);
    [val, idx] = min(abs(cellTrace_Times - n));
    minVal(i,1) = idx;
end 

cellTrace_trialStartIdx = minVal; 

%LEVER EXTENSION: 

%need to find the position in cellTrace that are closest to the lever out
%times in GPIO 
%first, set variables back to 0 
n = [];
val = [];
idx = []; 
minVal = [];

for i = 1:length(leverOutTimes)
    n = leverOutTimes(i,1);
    [val, idx] = min(abs(cellTrace_Times - n));
    minVal(i,1) = idx;
end 

cellTrace_leverOutIdx = minVal;

%LEVER PRESS 

%get times from the gpio file: 
leverPressTimes = gpio_files.leverPressTimes;
%need to find the positions in cellTrace that are closest to the lever press 
%TTL times from gpio files
%set variables back to []
n = [];
val = [];
idx = [];
minVal = [];

for i = 1:length(leverPressTimes)
    n = leverPressTimes(i,1);
    [val, idx] = min(abs(cellTrace_Times - n));
    minVal(i,1) = idx;
end 

cellTrace_leverPressIdx = minVal;


%%SHOCK TIMES 
%get the times from the gpio file: 
shockTimes = gpio_files.shockTimes;

%need to find the pos in cellTrace that are closest to the shock
%TTL times
n=[];
val = [];
idx = [];
minVal = [];

for i = 1:length(shockTimes)
    n = shockTimes(i,1);
    [val, idx] = min(abs(cellTrace_Times - n));
    minVal(i,1) = idx;
end 

cellTrace_shockIdx = minVal;

%%WE NEED TO SAVE THESE INDICES 
%SAVE BACK INTO CELLVARS 
cellVars.eventIndices.cellTrace_trialStartIdx = cellTrace_trialStartIdx; 
cellVars.eventIndices.cellTrace_leverOutIdx = cellTrace_leverOutIdx;
cellVars.eventIndices.cellTrace_leverPressIdx = cellTrace_leverPressIdx;
cellVars.eventIndices.cellTrace_shockIdx = cellTrace_shockIdx; 

filename = strcat('m',subjectID,'_',session,'_cellTrace.mat'); 
save(filename,'cellVars');
clear;
