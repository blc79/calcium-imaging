%load the .mat cellTrace file (still formatted as a table 

prompt = "Subject ID?";
subjectID= input(prompt,'s');
subjectID =string(subjectID);

prompt2 = "Session ID?"
session = input(prompt2,'s');
session= string(session); 

cellTrace = table2array(m55fr1d1cellTrace);
%also would be good to remove first 2 rows (empty rows) from file 
cellTrace(1,:) = [];
cellTrace(1,:) = [];
filename = strcat(subjectID,'_',session,'_cellTrace.mat'); 
save(filename,'cellTrace');