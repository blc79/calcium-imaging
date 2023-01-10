%load the .mat cellTrace file (still formatted as a table) 

prompt = "Subject ID?";
subjectID= input(prompt,'s');
subjectID =string(subjectID);

prompt2 = "Session ID?"
session = input(prompt2,'s');
session= string(session); 

a =who;
cellTrace = table2array(m55fr1d1cellTrace);
%also would be good to remove first 2 rows (empty rows) from file 
cellTrace(1,:) = [];
cellTrace(1,:) = [];

cellVars = struct; 
cellVars.rawCells = cellTrace(:,2:end); 
cellVars.time = cellTrace(:,1); 

%once we have cellTrace, the first thing we need to do is normalize each
%cell: deltaF/F = F0 - Fbaseline / Fbaseline 
    %where Fbaseline is the mean of activity taken across the entire
    %session: 

rawCells = cellVars.rawCells; 
byCellMean = mean(rawCells,1); 

for i =1:size(rawCells,2)
    deltaF(:,i) = rawCells(:,i) - byCellMean(1,i);
end 

for i =1:size(deltaF,2)
    dFF(:,i) = deltaF(:,i) / byCellMean(1,i);
end 

cellVars.dFF = dFF;

%%%%alternate approach: like in Vijay's paper: 
byCellMedian = median(rawCells,1); 
byCellMax = max(rawCells); 
byCellMin =min(rawCells); 

subtractMedian = [];
for i =1:size(rawCells,2)
    subtractMedian(:,i) = rawCells(:,i) - byCellMedian(1,i); 
end 

maxMinusMin = byCellMax - byCellMin; 

vijayNormalFluor = [];
for i =1:size(subtractMedian,2)
    vijayNormalFluor(:,i) = subtractMedian(:,i)/maxMinusMin(1,i); 
end 

cellVars.vijayNormalFluor = vijayNormalFluor; 
filename = strcat(subjectID,'_',session,'_cellTrace.mat'); 
save(filename,'cellVars');
clear 