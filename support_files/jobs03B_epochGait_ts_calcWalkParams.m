% jobs_epochGait_ts_calcWalkParams




%% show ppant numbers:
cd(savedatadir);

pfols= dir([pwd filesep 'p_*data.mat']);

resampSize=100; 

%%

nsubs = length(pfols);
for ippant =1:nsubs
    cd(savedatadir)    %%load data from import job.
    load(pfols(ippant).name, ...
        'HeadPos', 'summary_table', 'subjID');

    savename = pfols(ippant).name;
    disp(['Preparing gait time series data... ' savename]);

    %% Gait extraction.
    % Per trial (and event), extract gait samples (trough to trough), normalize along x
    % axis, and store various metrics.


    allevents = size(summary_table,1);

    %create a large empty matrix to staw raw gait, and resampled sizes
    %also:

    gait_ts_raw= zeros(1,500); % in samples
    gait_ts_resamp= deal(zeros(1,100)); % resampled to 100%


    
    [trialallocation, gaitDuration,gaitIdx, gaitSamps, gaitStart, gaitFin,walkSpd]= deal(nan);
    gait_ts_gData= table(trialallocation,gaitIdx,  gaitStart,gaitSamps,gaitDuration,walkSpd);

    igaitcounter=1; % reset per participant

    for itrial = 1:length(HeadPos)

        %find all gait onsets (in samples, focusing on first stim)
        gOnsets = HeadPos(itrial).Y_gait_troughs;

        % if empty, skip to next trial
        if isempty(gOnsets)
            continue
        end

        skiptrial=0;
        rejTrials_AVsynch_v1; % subjID is read in.
        if skiptrial==1
            continue
        end
        
        % detrend the gait to avoid slant effects?
        headY = detrend(HeadPos(itrial).Y);
        % headY = (HeadPos(itrial).Y);
        nGaits = length(gOnsets);
        % step through and extract from 2nd to second last:
        for igaitTrial = 3:nGaits-2

            gaitStFin= [gOnsets(igaitTrial),gOnsets(igaitTrial+1)];
            rawHead = headY(gaitStFin(1):gaitStFin(2));

            %also resample along x dimension:
            resampHead = imresize(rawHead', [1,resampSize]);

            if resampHead(50)< resampHead(1)
                % catch bugs
                continue
%             error('check trial/ trough alignment');
            end
            

            %gaitcount(within trial)
            gIdx = find(HeadPos(itrial).Y_gait_troughs==(gaitStFin(1)));
            
            gaitDur = gaitStFin(2)-gaitStFin(1); % in samps
            
            %>>>>> store:
        gait_ts_raw(igaitcounter,1:length(rawHead)) = rawHead;
        gait_ts_resamp(igaitcounter,:) = resampHead;
    
        gait_ts_gData.trialallocation(igaitcounter) = itrial;
        gait_ts_gData.gaitDuration(igaitcounter)= gaitDur;
        gait_ts_gData.gaitIdx(igaitcounter) = gIdx;
        gait_ts_gData.gaitStart(igaitcounter) = gaitStFin(1);
        gait_ts_gData.gaitSamps(igaitcounter) = length(rawHead);
        gait_ts_gData.walkSpd(igaitcounter) = HeadPos(itrial).walkSpeed;
        %prefill next row to suppress output warnings in command window:
        gait_ts_gData(igaitcounter+1,:) = gait_ts_gData(igaitcounter,:) ;
       igaitcounter=igaitcounter+1;
        end % all steps in trial
    end % all trials
    %remove last row (autofilled)
    gait_ts_gData(igaitcounter,:)=[];
    %convert zeros to nan to tidy plot:
    gait_ts_raw(gait_ts_raw==0)=nan;
    gait_ts_resamp(gait_ts_resamp==0)=nan;

   
disp(['saving step-cycle time series data for ' subjID])
cd(savedatadir);
save(savename, 'gait_ts_raw', 'gait_ts_resamp', 'gait_ts_gData', ...
   '-append');

end % per ppant

