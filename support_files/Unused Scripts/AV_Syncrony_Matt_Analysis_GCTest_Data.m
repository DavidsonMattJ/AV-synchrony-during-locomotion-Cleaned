 %% this script will quickly 
%% load the position tracked data for one participant

%specify the row that contains column headers:
%Import the options of the csv file

%readfile='test1_2022-12-06_trialsummary.csv';
readfile=
opts=detectImportOptions(readfile);

%%
%Defines the row location of channel variable name
opts.VariableNamesLine = 1;

%Set proper Date format
%opts = setvaropts(opts,varname,'InputFormat','DD/mm/uuuu');

%Specifies that the data is comma seperated
opts.Delimiter =','; %Specifies that the data is comma seperated
%Read the table
mytable = readtable(readfile,opts, 'ReadVariableNames', true);

%% here we will for a given trial, select the x,y,z, position data of the head over time.

objectCategory = 'head';
dimensions= {'x', 'y', 'x'};
ntrials = unique(mytable.trial);
figure(1); 
clf;
for itrial = 1:length(ntrials)

    usetrial = ntrials(itrial);

    % disp(num2str(itrial);
%find all relevant rows.
dataColumn = mytable.position;
%find the logical intersection between different if statements.
% bool index of whether tracked object is head:
headRows_bool = (strcmp(mytable.trackedObject, 'head'));
%convert to row index.
headRows = find(headRows_bool);

xDimRows = find(strcmp(mytable.axis, 'x'));
yDimRows =  find(strcmp(mytable.axis, 'y'));

%find relevant rows that have data for this trial.
trialrows = find(mytable.trial== usetrial);
%find combination of rows that are this trial, and head object only.
temporaryIntersection = intersect(trialrows, headRows);
%find intersection of the above result, and y dimension only.
finalIntersection = intersect(temporaryIntersection, yDimRows);

%extract the 'position' data on these rows only.
trialData = dataColumn(finalIntersection,:);
%what time was this data recorded at?
trialtime = mytable.t(finalIntersection,:);

%clear last plot, show time on X axis, head position on Y
% figure(itrial);
subplot(5,4, itrial)
plot(trialtime,trialData);
title(['Trial ' num2str(itrial)]);
hold on;
% subplot(5,4,itrial);
% plot(trialtime, detrend(trialData), 'r')
end


%%