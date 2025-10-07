
% job02_split_by_cycle must be run before this script.

% called from jobs_import_preprocess


%% This script will take the time stamps of events in the summary files
% and cross reference them with gait timing data to determine which walk
% phase the participant was in when each event occurred.

cd(savedatadir);
allppants = dir([pwd filesep 'p_*.mat']);

%% Load Each Participants Head Tracking Data

% per participant, load the data, perform some analyses...

for ippant = 1:length(allppants)

    cd(savedatadir);

    subjectID = allppants(ippant).name;

    %Load Summary data for participant
    load(allppants(ippant).name, 'summary_table', 'subjID', 'HeadPos');


    disp(['Loading Summary Data for Participant ' num2str(ippant)]);

    nRowsSummary = size(summary_table,1);


    %STEPS
    %For each line in the summary file (event) take the trial number and event time.
    %Find the data in the quantile times for that trial
    %Find quantile times in this trial that came before the event qStart < tEvent
    %Find maximum value of the remaing times
    %Take the Walk phase of this line and assign it to the walk phase for this
    %event in the the summary table.

    %For each line in the summary file (event) take the trial number and event time.

    for iEvent = 1:nRowsSummary

        %     disp('Starting Loop'+iEvent);

        trialThisEvent = summary_table.trial(iEvent);
        eventTime = summary_table.stimSeqStartTime(iEvent); % first stim, regardless of modality.
        visTime = summary_table.vistargOnset(iEvent);
        audTime = summary_table.audCodedTime(iEvent);
        respTime = summary_table.targRT(iEvent);


        % skip this trial if previously IDd as requiring exclusion:
        skip=0;
        itrial = trialThisEvent+1;
        rejTrials_AVsynch_v1;
        if skip
            continue % next event if this trial should be ignored.
        end


        if HeadPos(itrial).walkSpeed==0
            % place nan instead.
            summary_table.StepPcnt(iEvent) = nan;
            summary_table.StepPcnt_Vis(iEvent) = nan;
            summary_table.StepPcnt_Aud(iEvent) = nan;
            summary_table.StepPcnt_Resp(iEvent) = nan;

            continue % jump to next iter of for loop
        end


        trs_samp= HeadPos(itrial).Y_gait_troughs;
        trs_sec= HeadPos(itrial).Y_gait_troughs_sec;

        testTimes = trs_sec;

        % include a max (last stim shown in AV seq).
        if visTime>eventTime
            lastStim = visTime;
        else
            lastStim=audTime;
        end
        %nearest gaitonset, repeat a process for different events.
        testEvents= {eventTime, visTime, audTime, lastStim, respTime};

        % step through each of these gait events, (perform the same operation
        % each time), then save in a new column.
        % We're converting the time(sec) onset of each event into a
        % percentage, relative to occurrence within the co-occuring
        % single-step cycle. (1-100%).

        % later scripts will bin into quantiles/ quintiles etc.

        saveFlds_pcnt= {'StepPcnt_First','StepPcnt_Vis',...
            'StepPcnt_Aud','StepPcnt_Last','StepPcnt_Resp'};


        for igEvent= 1:length(testEvents)
            thisEvent= testEvents{igEvent};

            gO = find(testTimes<thisEvent, 1, 'last');

            if isempty(gO)
                disp(['Warning! no gait info for iEvent: ' num2str(iEvent) '(miss)' ]);
                summary_table.([saveFlds_pcnt{igEvent}])(iEvent) = nan;

            elseif gO == length(testTimes)
                % in this case, we are in the last step of the trial, so skip.
                summary_table.([saveFlds_pcnt{igEvent}])(iEvent) = nan;

            else

                % event as percentage:
                % extract the event as % step.[0 100]
                gaitsamps =trs_samp(gO):trs_samp(gO+1); % avoid counting edge bins twice.
                gaitTimes = HeadPos(itrial).times(gaitsamps);
                resizeT= imresize(gaitTimes', [1,100]);
                %             gPcnt = dsearchn(resizeT', thisEvent);

                % or take as proportion of total.
                tDur = gaitTimes(end)- gaitTimes(1);
                tE= thisEvent-gaitTimes(1);
                gPcnt= round((tE/tDur)*100);

                % > add to table:
                summary_table.([saveFlds_pcnt{igEvent}])(iEvent) = gPcnt;


            end

        end % each gevent (columns to add)

    end % each row of summarytable.

    disp(['Loop for ppant' num2str(ippant ) ', event '  num2str(iEvent)  ' COMPLETE']);
    % End of per event loop
    save(allppants(ippant).name, 'summary_table', '-append');

end
%End of Participant loop.
