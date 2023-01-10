%%IMPORTING MPC DATA TO MATLAB; CURRENTLY ONLY WORKS TO IMPORT 1 FILE AT A
%%TIME; THIS SCRIPT WILL GENERATE A FOLDER BASED ON THE SESSION (EX: 100%
%%DAY 1 = FOLDER CALLED "100_D1") 
    %note: if folder already exists, it will give a warning, but won't stop
    %the script from running; will add file to the existing folder 

%THIS SCRIPT PULLS ALL IMPORTANT SESSION INFORMATION: 
%SESSION DATE, SUBJECT ID, SESSION TYPE (REINFORCEMENT %), AND SESSION DATA
%
%ALL SESSION DATA IS SAVED IN A.PROC

clear;

%Choosing which file
[meta_import,meta_folder]=uigetfile('*.txt');
opts = delimitedTextImportOptions("NumVariables",12);
opts.DataLines = [5, Inf];
opts.Delimiter = ":";
meta.raw = table2array(readtable(fullfile(meta_folder,meta_import),opts));
[a,meta_import] = fileparts(meta_import);
meta.fileName = meta_import;

clearvars -except meta;

%need to work through these steps for every file: 
for j = 1:length(meta)

session_starts = find(contains(meta.raw,'Start Date'));
r_starts = find(contains(meta.raw,'R'));
q_starts = find(contains(meta.raw,'Q'));
sessions = length(session_starts);



start_cell = session_starts(j,1);
r_cell = r_starts(j,1);
q_cell = q_starts(j,1);

l = r_cell-q_cell-1;

   data(j).raw.q_data = str2double(meta.raw(q_cell+1:q_cell+l,2));
   data(j).raw.r_data = str2double(meta.raw(r_cell+1:r_cell+l,2));

   data(j).raw.meta = meta.raw(start_cell:start_cell+9,1:4);
   data(j).raw.fileName = meta.fileName;
   
q_data=data(j).raw.q_data;
r_data=data(j).raw.r_data*10; %multiply by 10 to convert from centiseconds to milliseconds 
data(j).raw.r_data=r_data;

trialStamps=find(q_data==12);
numTrials=length(trialStamps);
trialTimes=r_data(trialStamps);

%%important info we want for each session: 

%session date:
str = data(j).raw.fileName;
date = extractBefore(str,'_');
data(j).date = date; 

%subject ID:
subject = extractAfter(str,'m');
data(j).subject=subject; 

%FR used for the session 
extractFR = extractAfter(str,'fr');
FR=extractBefore(extractFR,'_');
FR=str2num(FR);
data(j).FR = FR; 

%session type (% of trials reinforced) 
sessionType = extractAfter(str,'_');
sessionType2 = extractAfter(sessionType, '_');
sessionType3 = extractBefore(sessionType2,'_');
data(j).sessionType = sessionType3; 

%what specific session was it? ex: what day of 100% reinforced? day 3?
%sessionSpecific = 100_3
sessionSpecific = extractBefore(sessionType2,'_m');
data(j).sessionSpecific = sessionSpecific; 


%separating out reinforced vs. nonreinforced trials 
t1 = find(q_data == 21 | q_data == 22);
if ~isempty(t1)
    t2= q_data(t1);
 %  t3 = [21;t2];
%else t3 =[];
end 



%loop through trialStamps(i,1) 
for i=1:numTrials
    
    
    %find all of the events (q_data) that happened within each trial 
    if i ~=numTrials
a=q_data(trialStamps(i,1):trialStamps(i+1,1));
aLength=length(a);
lessOne=aLength-1;
a=a(1:lessOne);
    end 
    if i==numTrials 
       a=data(j).raw.q_data(trialStamps(i,1):end,1);
    end
    

%trial type? (reinforced vs. Null) 
%reinforced = 1, Null = 0 
%note: the trial type is selected just before the trial actually starts.
%the first trial is always reinforced 
%data(1).trialType=1

if ~isempty(t1)
%if ~isempty(t3)
%if t3(i,1) == 21
if t2(i,1) ==21 
    trialType = 1;
end

%if t3(i,1) == 22
if t2(i,1) ==22 
trialType = 0;
end
else trialType = 1;
end

%find every time a lever press occurred and time of LP
press=find(a==5); %finding presses, real time of presses, rel time of presses (in each trial) 
absPressTime=r_data(trialStamps(i,1)+press(:,1)-1,1); %real time
relPressTime=r_data(trialStamps(i,1)+press(:,1)-1,1)-r_data(trialStamps(i,1),1); %relative press time (relative to time the trial started)


%number of presses? 
numPress=length(press);
shock=find(a==10);
absShockTime=r_data(trialStamps(i,1)+shock(:,1)-1,1);
relShockTime=r_data(trialStamps(i,1)+shock(:,1)-1,1)-r_data(trialStamps(i,1),1);
numShock=length(shock);
    
data(j).proc(i).trial = i;
   % data(1).trialType=1;
    data(j).proc(i).trialType=trialType;
    data(j).proc(i).starttime = r_data(trialStamps(i,1));
    data(j).proc(i).FR=FR;
    data(j).proc(i).numPress=numPress;
    data(j).proc(i).presstime_rel = relPressTime;
    data(j).proc(i).presstime_abs=absPressTime;
    data(j).proc(i).numShock=numShock;
    data(j).proc(i).relShockTime=relShockTime;
    data(j).proc(i).absShockTime=absShockTime;
end



data(j).animal = data(j).raw.meta{3,2};
data(j).date = erase(data(j).raw.meta{1,2},'/');
end

for i=1:length(data)
    if i==1
    mkdir(data(i).sessionSpecific);
    cd(data(i).sessionSpecific);
    end
    
A=data(i);

save(strcat('data_',A.subject,'_',A.date),'A');

if i==length(data)
cd ..
end


end 


clear 

