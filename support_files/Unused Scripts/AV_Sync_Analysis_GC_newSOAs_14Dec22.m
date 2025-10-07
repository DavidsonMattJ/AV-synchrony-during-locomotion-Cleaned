
% RUN HEAD TRACKING ANALYSIS SCRIPT BEFORE THIS SCRIPT

%This script will load individual data, and process the basic results per
%SOA
% - Accuracy
% - RT

%change directory

%specify save directory:
savedatadir='/MATLAB Drive/AV Synchrony Exp/Processed_Data';

% cd Raw_Data -
cd('/MATLAB Drive/AV Synchrony Exp/Raw_Data')
rawdatadir= pwd;

summaryfiles = dir([pwd filesep '*trialsummary.csv']);

% Load Head tracking Quantile Files
cd('/MATLAB Drive/AV Synchrony Exp/Processed_Data/Quantile_Times_Data');
quantiledatadir = pwd;

quantilefiles = dir([pwd filesep '*Walking_Quantile_Times.csv']);

%%
% per participant, load the data, perform some analyses...
% for ippant = 1:length(summaryfiles)

for ippant = 1:length(summaryfiles)



    % MOVE THIS SECTION TO HEAD TRACKING FILE (TO BE RUN FIRST) THEN REFERENCE
    % IN THIS SCRIPT

    cd(rawdatadir);
    % read table.
    participantfile = summaryfiles(ippant).name;
    mytab = readtable(participantfile,'NumHeaderLines',0);
   
    %Remove Practice Trials from Analysis
nPracticeTrials = 20;

    idxActualTrials = find(mytab.trial >= nPracticeTrials);
    mytab = mytab(idxActualTrials, :);

    subjID= mytab.participant{1};
    subjID = strjoin(cellstr(subjID));

    %TESTING - REMOVE and REPLACE THIS IF STATEMENT LATER
   
    
    if strcmp(subjID, 'MMM')


        %% Load Participants Head Tracking Quantile Data

        %Change Directory to Quantile Data folder
        cd(quantiledatadir);

        %UNCOMMENT THIS
        % read table.
        %ppantQuantileFile = quantilefiles(ippant).name;

        % Find Correct File in Folder
        search_string = string(subjID);


        idxppantQfile = strfind(quantilefiles, '*MMM_Walking_Quantile_Times.csv');

        ppantQuantileFile = quantilefiles(idxppantQfile).name;

% idxppantQfile = find(~cellfun(@isempty, strfind(quantilefiles.name, search_string)));

        

        myQuantiletab = readtable(ppantQuantileFile,'NumHeaderLines',0);

        % Remove Practice Trials
        idxRealTrials = find(myQuantiletab.Trial >= nPracticeTrials);
        myQuantiletab = myQuantiletab(idxRealTrials, :);

        %% change no responses to nans (to avoid stuffing up averages).
        missedRTs = mytab.targRT==0;
        missedrts_indx = find(missedRTs);
        mytab.targRT(missedrts_indx)=nan;
        mytab.RTfromStim1 = mytab.targRT-mytab.stimSeqStartTime;
        mytab.RTfromStim2= mytab.RTfromStim1-mytab.SOA;

        %% exchange data from
        % Data = table2array( mytab(:, [9,14,15,16,18]));
        % AudLeadIdx = find(Data(:,3)==2);
        % Data(AudLeadIdx,2) = Data(AudLeadIdx,2) * -1;

        %find all stimOrder = AV.
        AudLeadIdx= mytab.stimOrderDesired==2;

        % change SOA to +- relevant to VA
        mytab.SOA(AudLeadIdx) = mytab.SOA(AudLeadIdx) *-1;

        walkingIdx = find(mytab.blockType~=0);
        walkingData = mytab(walkingIdx,:);

        % create slow data and fast data.
        slowtrials = walkingData.blockType==1;
        fasttrials = walkingData.blockType==2;

        slowData = walkingData(slowtrials,:);
        fastData = walkingData(fasttrials,:);


        SOAs = unique(walkingData.SOA);
        nSOAs = length(SOAs);
        %preallocate for all data (walk speeds combined)
        propSameSOA_all = nan(1,nSOAs);
        RTfromstim1_perSOA_all= nan(1,nSOAs);
        RTfromstim2_perSOA = nan(1,nSOAs);
        nThisSOA = nan(1,nSOAs);


        %alternatively, deal the same nan array to all these variables in one line.
        %[propSameSOA, RTfromstim1_perSOA, RTfromstim2_perSOA, nThisSOA]
        %=deal(nan(1,nSOAs));

        % for our 3 data types (all data, slow ,and fast).
        speedData ={walkingData, slowData, fastData};

        for iCond= 1:length(speedData)

            useData = speedData{iCond};

            propSame=[]; % proportion same per SOA
            rt1=[]; % RT from stim 1, per SOA.
            rt2=[]; % RT from stim 2, per SOA.
            nThisSOA=[];
            for iSOA=1:nSOAs

                % Number of targets with SOA(i)
                thisSOA = SOAs(iSOA);
                trialsWithSOA= find(useData.SOA== thisSOA);
                nThisSOA(iSOA) = length(trialsWithSOA);

                % Number of SOA(i) trials with 'SAME' response
                SameSOA = find(useData.responseType(trialsWithSOA)==1); % 1 is Same, 2 is Different, 0 is absent
                nSameSOA = length(SameSOA);

                % Proportion of Same Responses on those trials
                propSame(iSOA) = nSameSOA/nThisSOA(iSOA);

                %rt for this SOA.
                rt1(iSOA)  = mean(useData.RTfromStim1(trialsWithSOA), 'omitnan');
                rt2(iSOA)  = mean(useData.RTfromStim2(trialsWithSOA), 'omitnan');

            end

            %% now that the analyses are done, rename as per condition.
            if iCond==1
                % rename the data for 'all '

                propSame_all= propSame;
                RTfromStim1_all= rt1;
                RTfromStim2_all= rt2;
                nperSOA_all= nThisSOA;

            elseif iCond ==2
                %rename for slow speed

                propSame_slow= propSame;
                RTfromStim1_slow= rt1;
                RTfromStim2_slow= rt2;
                nperSOA_slow= nThisSOA;

            elseif iCond==3
                %rename for fast speed

                propSame_fast= propSame;
                RTfromStim1_fast= rt1;
                RTfromStim2_fast= rt2;
                nperSOA_fast= nThisSOA;

            end

        end % for all data, slow data only, fast data only.

        %% Process Gait Cycle Data
        
        % Create an extra column in the Summary file to hold walk phase.  Then for
        % each row in the summary file, cross reference the time with the Quantile
        % document to determine which bin it corresponds to, then find the walk
        % phase associated and copy it to the new column of the Summary File.

        mytab.WalkPhase = nan(height(mytab),1);  % (mytab loaded earlier from the Raw Summary data of the ppant)


        % Find the Raw Summary File that relates to this participant

        %
        nQuantiles = 4;

        % For each event (row) in the summary data there is a trial number and time.  Find which walk phase this time stamp
        %corresponds to in the Head Tracking Quantile data
        for iThisEvent = 1:height(mytab)

            % Find the trial number for the row.
            trialnumberThisEvent = mytab.trial(iThisEvent);

            % Find the time stamp of the row.
            timeThisEvent = mytab(iThisEvent, "stimSeqStartTime");
            timeThisEvent = table2array(timeThisEvent);      %convert to array so comparison of values can be done.

            % In the head tracking data, for trial = t, find the quantile (row) for
            % which qstarttime(s) < time < qstarttime(s+1)
            
            %Find Indexes for which event time is after qStart
           idxQuantilesThisTrial = find(myQuantiletab.Trial == trialnumberThisEvent);
            
           quantileDat = myQuantiletab(idxQuantilesThisTrial, :);
           startTimesThisTrial = quantileDat.qstartTime;      % Done because the next line can't be done with a table
           quantilesThisTrial = quantileDat.WalkPhase;
           % Create subset of data in trial that came before event.
            
           %Find Preceding Phase Start (last of qstartTimes before event):
           idxPrePhaseStart = max(find(timeThisEvent > startTimesThisTrial)); 
          
           % pull out q
           WalkPhasethisEvent = quantilesThisTrial(idxPrePhaseStart);

%            %Check feasibility
%            if ~(quantileDat.qstartTime(idxPrePhaseStart) <= timeThisEvent <= quantileDat.qstartTime(idxPrePhaseStart+1));
%                display("Potential Phase Error in trial " + mytab.trial(iThisEvent))   
%            end
            

%             idx time < timeThisEvent & idx+1 > timeThisEvent
%             %idxEventinQdata = find(quantileDat <= timeThisEvent)

           

%             % Take maxima of this data set to find closest preceding Walk Phase start
%             
%             %idxEventinQdata = (myQuantiletab.qstartTime <= timeThisEvent);
%             idxEventinQdata = find(startTimesThisTrial <= timeThisEvent);
% 
%             %Find Lowest value that satisfies this
%             %
%             % idxEventinQdata = min(idxEventinQdata);
% 
%             %find Walkphase value for this row
%             WalkPhasethisEvent = myQuantiletab(idxEventinQdata, "WalkPhase");
%             WalkPhasethisEvent = table2array(WalkPhasethisEvent);
% 
%             %save this value to (mytab.WalkPhase)
%             mytab.WalkPhase(iThisEvent) = WalkPhasethisEvent;

        end

%         for iQuantile = 1:nQuantiles
% 
% 
%             % Number of Targets presented in Walk Phase 1
%             idxThisPhase = mytab.WalkPhase == i
%             dataThisPhase = mytab(idxThisPhase);
% 





        %% change directory to processed folder.
        cd(savedatadir)
        %save data.
        disp(['saving data for participant ' num2str(ippant)]);

        savefilename = ['p_' num2str(ippant) '_' subjID ' _SOA_summary'];
        %save slow and fast, and overall data per subject.
        save(savefilename, ...
            'propSame_all', 'propSame_slow', 'propSame_fast',...
            'RTfromStim1_all', 'RTfromStim1_slow', 'RTfromStim1_fast',...
            'RTfromStim2_all', 'RTfromStim2_slow', 'RTfromStim2_fast',...
            'nperSOA_all', 'nperSOA_slow', 'nperSOA_fast', 'subjID', 'SOAs');

    else

        % TESTING - END OF IF STATEMENT
    end




end % end participant loop

% %% first plot, grand average proportion same.
% figure(1)
%     clf
%     hold on
%
% plottybrah = plot(SOAs, propSameSOA,'g-o')
% title("'Same' Responses Across All Walking Speeds")
% xlabel("Stimulus Onset Asynchrony (Negative values denote Auditory First")
% ylabel("Proportion 'Same' Response")
%
% for i=1:nSOAs
%
%     xlocation = SOAs(i);
%     ylocation = propSameSOA(i);
%     ourText = ['n = ' num2str(nThisSOA(i))];
%     tx = text(xlocation,ylocation,ourText);
%     tx.FontWeight = "bold";
% end
%
% %% start various plots
% % plot slow vs fast (proportions)
% figure(2)
% clf
% hold on
% plot(SOAs,propSameSlowSOA,'bo-')
% plot(SOAs,propSameFastSOA,'ro-')
% xlabel('Stimulus Onset Asynchrony (Seconds)')
% ylabel('Proportion of "Same" Responses')
%
% %% plot Response Times
%
% figure(3)
% clf
% hold on
% title('Response Time')
% xlabel('Stimulus Onset Asynchrony (Seconds)')
% ylabel('Response Time (Seconds)')
% plot(SOAs,meanRTSlowThisSOA, 'bo-')
% plot(SOAs,meanRTFastThisSOA, 'ro-')
% legend('Slow Walk Speed', 'Fast Walk Speed')
%
% %% Response Times adjusted for SOA - As longer SOA's require a longer time before both stimuli have been shown, this may
% % lead to longer Response times as participants may wait to see both stimuli before responding.  This is accounted for by
% % subtracting the SOA from the response time.
%
% figure(4)
% clf
% hold on
% title('Response Time adjusted for SOA')
% xlabel('Stimulus Onset Asynchrony (Seconds)')
% ylabel('Response Time minus SOA (Seconds)')
% plot(SOAs,meanRTfromSecondStimSlowThisSOA, 'bo-')
% plot(SOAs,meanRTfromSecondStimFastThisSOA, 'ro-')
% legend('Slow Walk Speed', 'Fast Walk Speed')
%



