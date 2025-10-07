%calc_walkdescriptives

%% Here we will load participant information (table format), and calculate
% descriptive statistics related to walk features, 
%such as average speed and consistency etc. this
% is based on Perception PR author #1

%pseudo:
% - load ppant data, 
% - extract
% - stash
% - save


%% load participant data
cd(savedatadir)
% list pfolders:
pfols =dir([pwd filesep 'p_*']);
nppants = length(pfols);
disp([num2str(nppants) ' participant folders detected']);

%extract n-targets per ppant
GroupwalkDS=[];
[natSpeedarray,slowSpeedarray]=deal([]);
%%
for ippant = 1:nppants
    clear summary_table

    load(pfols(ippant).name, 'summary_table', 'HeadPos', 'gait_ts_gData');

    %% for each trial, calculate the average speed and assign for later averaging.
    for itrial=1:length(HeadPos)
    
        timethistrial = HeadPos(itrial).times;
        %omit first and last second from calculation
    [startFin] = dsearchn(timethistrial,[1, max(timethistrial)-1]');

    %over this time window, calculate the average speed as the displacement
    %on the X dimension over time
    %
    changeinPos = diff(HeadPos(itrial).X);
    changeinTime= diff(HeadPos(itrial).times); % use because occasional frame delays.

    speedperPos = changeinPos./changeinTime; % distance / time
    %avthistrial
    avSpeed = mean(speedperPos(startFin(1):startFin(2))); 
    %store accordingly:
    switch HeadPos(itrial).walkSpeed
        case 1 % slow
    slowSpeedarray= [slowSpeedarray, avSpeed];
        case 2 % natural
            natSpeedarray= [natSpeedarray, avSpeed];
    end

    end
    GroupwalkDS(ippant).slowSpeedAv = mean(abs(slowSpeedarray));
    GroupwalkDS(ippant).natSpeedAv = mean(abs(natSpeedarray));

    disp(['finished speed cals for participant ' num2str(ippant)]) 

  %% calculate average step length, per walking speed.  

  slowtrials  = find(gait_ts_gData.walkSpd==1);
  nattrials  = find(gait_ts_gData.walkSpd==2);
  GroupwalkDS(ippant).slowStepDur= mean(gait_ts_gData.gaitDuration(slowtrials))/90;
  GroupwalkDS(ippant).natStepDur= mean(gait_ts_gData.gaitDuration(nattrials))/90;

end
%% calculate and display descriptives for whole sample: 
%average mean speed and SD:
clc
grandSlowSpeed= [GroupwalkDS(:).slowSpeedAv];
grandNatSpeed= [GroupwalkDS(:).natSpeedAv];

mSlow = mean(grandSlowSpeed);
mNat = mean(grandNatSpeed);

seSlow = std(grandSlowSpeed)/sqrt(nppants);
seNat = std(grandNatSpeed)/sqrt(nppants);
disp('>>')
disp(['Slow speed M = ' num2str(mSlow) ', SE=' num2str(seSlow)])
disp('>>')
disp(['Nat speed M = ' num2str(mNat) ', SE=' num2str(seNat)])
    

disp('>>')
grandSlowDur= [GroupwalkDS(:).slowStepDur];
grandNatDur= [GroupwalkDS(:).natStepDur];

mSlow = mean(grandSlowDur);
mNat = mean(grandNatDur);

seSlow = std(grandSlowDur)/sqrt(nppants);
seNat = std(grandNatDur)/sqrt(nppants);

disp(['Slow Step Duration M = ' sprintf('%.2f', mSlow) ', SE=' sprintf('%.2f',seSlow) ', min-max [' sprintf('%.2f',min(grandSlowDur)) ', ' sprintf('%.2f',max(grandSlowDur))])
disp('>>')
disp(['Natural Step Duration M = ' sprintf('%.2f', mNat) ', SE=' sprintf('%.2f',seNat) ', min-max [' sprintf('%.2f',min(grandNatDur)) ', ' sprintf('%.2f',max(grandNatDur))])
    