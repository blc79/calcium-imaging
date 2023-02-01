
%THIS SCRIPT WILL DOWNSAMPLE GPIO FILE AND EXTRACT THE TIME POINTS OF
%EVENTS OF IMPORTANCE 
%LET'S OPEN THIS WITHIN THE SESSION FOLDER (EX: 100_D1) 

%load gpio.csv file; import entire selection 

prompt = "Subject ID?";
subjectID= input(prompt,'s');
subjectID =string(subjectID);

prompt2 = "Session date?"
date = input(prompt2,'s');
date = string(date); 

times= gpio(:,1); 
channel=gpio(:,2); 
value=gpio(:,3); 
channelArray=table2array(channel); 
timesArray=table2array(times);
valueArray=table2array(value);


%%need to export TRIG (the time the session actually starts recording) 

gpio_trig_column=find(channelArray=='BNC Trigger Input');
gpio_trig = [];
gpio_trig(:,1) = timesArray(gpio_trig_column);
gpio_trig(:,2)=valueArray(gpio_trig_column);
%first value we want to extract? GPIO2 (trial start)

gpio_2_column=find(channelArray == 'GPIO-2'); 

gpio_2 = [];
gpio_2(:,1) = timesArray(gpio_2_column);
gpio_2(:,2) = valueArray(gpio_2_column);

%this is sampled at 5000Hz; we do NOT need it sampled that fast: want to
%get it down to 50Hz: take every 100th value 
gpio_2_downsample=gpio_2(1:10:end,:);

%what are the other values I need? I need gpio3 and gpio4 
%same process (lever presses and shocks)
gpio_3_column = find(channelArray =='GPIO-3');
gpio_3=[];
gpio_3(:,1) = timesArray(gpio_3_column);
gpio_3(:,2) = valueArray(gpio_3_column);
gpio_3_downsample = gpio_3(1:10:end,:);

%same for gpio_4 
gpio_4_column = find(channelArray =='GPIO-4');
gpio_4 = [];
gpio_4(:,1) = timesArray(gpio_4_column);
gpio_4(:,2) = valueArray(gpio_4_column);
gpio_4_downsample = gpio_4(1:10:end,:); 

a = find(gpio_trig(:,2)==0);
sessionStart = gpio_trig(a,1);


gpio_files = struct;
gpio_files.sessionStart = sessionStart; 
gpio_files.gpio_2 = gpio_2_downsample;
gpio_files.gpio_3 = gpio_3_downsample;
gpio_files.gpio_4 = gpio_4_downsample;
clearvars -except gpio_files subjectID date; 

%separate out GPIO_2
gpio_2=gpio_files.gpio_2; 

%GPIO_2 is logging trial starts: need to find every time the value changes
%from high to low 

gpioValues = gpio_2(:,2);
 
lowNum = find(gpioValues < 1000);
%but are there consecutive lowNum values? 

a = length(lowNum);

for i = 2: a
    consec(i,1) = lowNum(i,1) - lowNum(i-1,1);
end 

toKeep = find(consec ~= 1);
trialStarts = lowNum(toKeep,1);

trialStartTimes = gpio_2(trialStarts,1);

gpio_files.trialStartTimes = trialStartTimes;

%%also worth saving leverOut times (2s after trial start) 
leverOutTimes = trialStartTimes +2; 
gpio_files.leverOutTimes = leverOutTimes; 


%reset variables 
clearvars -except trialStartTimes leverOutTimes gpio_files date subjectID;
%separate out GPIO_3 
gpio_3 = gpio_files.gpio_3;

%gpio_3 is logging lever presses; find every time value changes from high
%to low 

gpioValues = gpio_3(:,2);
 
lowNum = find(gpioValues < 1000);
%but are there consecutive lowNum values? 
checkPress = length(lowNum); 
if checkPress > 0 
a = length(lowNum);

for i = 2: a
    consec(i,1) = lowNum(i,1) - lowNum(i-1,1);
end 

toKeep = find(consec ~= 1);
leverPress = lowNum(toKeep,1);

leverPressTimes = gpio_3(leverPress,1);

gpio_files.leverPressTimes = leverPressTimes;
elseif checkPress == 0 
    gpio_files.leverPressTimes = [];
end 
%reset variables 

clearvars -except trialStartTimes gpio_files date subjectID;
%separate out GPIO_4 
gpio_4 = gpio_files.gpio_4; 

%gpio_4 is logging shocks; find every time value changes from high to low 
gpioValues = gpio_4(:,2);
 
lowNum = find(gpioValues < 1000);
%but are there consecutive lowNum values? 
checkShock = length(lowNum);
if checkShock > 0

a = length(lowNum);

for i = 2: a
    consec(i,1) = lowNum(i,1) - lowNum(i-1,1);
end 

toKeep = find(consec ~= 1);
shockStart = lowNum(toKeep,1);

shockTimes = gpio_4(shockStart,1);


gpio_files.shockTimes = shockTimes;
elseif checkShock == 0 
    gpio_files.shockTimes = [];
end 


%%adjusted times (based on sessionStart) 
gpio_files.trialStartTimes = gpio_files.trialStartTimes - gpio_files.sessionStart; 
gpio_files.leverOutTimes = gpio_files.leverOutTimes - gpio_files.sessionStart;
gpio_files.leverPressTimes = gpio_files.leverPressTimes - gpio_files.sessionStart;
gpio_files.shockTimes = gpio_files.shockTimes - gpio_files.sessionStart; 

save(strcat('m',subjectID,'_', date,'_gpio_files'),'gpio_files');
clear;
