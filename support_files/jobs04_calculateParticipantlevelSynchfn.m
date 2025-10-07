% jobs_calculateParticipantlevelSynchfn
% -- called from jobs_import_preprocess;

%% CALCULATE PARTICIPANT LEVEL SOA DATA BEGINS HERE

% this script loads the presaved participant level data (matlab tables).
% calculates proportion 'same' responses per SOA.
% saves at the same location.

% - load data
% - extract trials per SOA type
% - calculate proportion same
% save
% savedatadir= string(rootPath) + '/AV Synchrony Exp/Processed_Data';
cd(savedatadir);

allppants = dir([pwd filesep 'p_*.mat']);
%% SET UP

% Number of slices of Gait Cycle
nGaitPhases = 5; % MD updated, more flexible this way. (fits fail with nQuants >4)

% Create an array of percentages for allocation:
qbounds = [1, ceil(quantile(1:100, nGaitPhases-1)), 100];
gQindx=[]; % stash the percentage index for each quantile (might be different sizes).

for iq= 1:nGaitPhases
    if iq < nGaitPhases
        gQindx{iq} = qbounds(iq):(qbounds(iq+1)-1);
    else
        gQindx{iq} = qbounds(iq):(qbounds(iq+1));
    end
end
% For reviewer: the effect of sparser bins:
% nGaitPhasesFine = 10; % MD updated, more flexible this way.
% 
% % have a list of percentages for allocation:
% qbounds = [1, ceil(quantile(1:100, nGaitPhasesFine-1)), 100];
% gQindxFine=[]; % stash the percentage index for each quantile (might be different sizes).
% 
% for iq= 1:nGaitPhasesFine
%     if iq < nGaitPhasesFine
%         gQindxFine{iq} = qbounds(iq):(qbounds(iq+1)-1);
%     else
%         gQindxFine{iq} = qbounds(iq):(qbounds(iq+1));
%     end
% end

showReviewFigure = 0; % show the result of bootstrapped downsampling to match trial counts
%%

for ippant= 1:length(allppants)
    
    cd(savedatadir);
    load(allppants(ippant).name, 'summary_table');
    
    disp("Processing Participant Level Data for Participant "+ippant);
    
    
    mytab = summary_table;
    
    ppantData_SOAs=[];
    %% change no responses to nans (to avoid biasing the averages).
    missedRTs = mytab.targRT==0;
    missedrts_indx = find(missedRTs);
    mytab.targRT(missedrts_indx)=nan;
    % create new RT columns:
    mytab.RTfromStim1 = mytab.targRT-mytab.stimSeqStartTime;
    mytab.RTfromStim2= mytab.RTfromStim1- abs(mytab.SOA);
    %%
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
    
    % for our 3 data types (all data, slow ,and fast).
    speedData ={walkingData, slowData, fastData};
    
    save_speed ={'_all', '_slow', '_fast'};
    
    for iCond= 1:length(speedData)
        
        useData = speedData{iCond};
        
        % For this speed condition, create a matrix to hold SOA data for
        % each gait phase
        
        %Preallocating tables for holding Propsame By Gate and SOA
        nanSetup = nan(nGaitPhases,nSOAs);
              
        propSame=[]; % proportion same per SOA
        rt1=[]; % RT from stim 1, per SOA.
        rt2=[]; % RT from stim 2, per SOA.
        nThisSOA=[];
        
        % >> store:
        ppantData_SOAs.SOAs = SOAs;
        
        % for each SOA, calculate the relevant DVs: 
        for iSOA=1:nSOAs
            
            % Number of targets with SOA(i)
            thisSOA = SOAs(iSOA);
            % trial indx.
            trialsWithSOA= find(useData.SOA== thisSOA);
            dataThisSOA = useData(trialsWithSOA, :);
            
            nThisSOA(iSOA) = length(trialsWithSOA);
            
            % Number of SOA(i) trials with 'SAME' response
            SameSOA = find(useData.responseType(trialsWithSOA)==1); % 1 is Same, 2 is Different, 0 is absent
            nSameSOA = length(SameSOA);
            
            % Proportion of Same Responses on those trials
            %             propSame(iSOA) = nSameSOA/nThisSOA(iSOA);
            
            %rt for this SOA.
            %             rt1(iSOA)  = mean(useData.RTfromStim1(trialsWithSOA), 'omitnan');
            %             rt2(iSOA)  = mean(useData.RTfromStim2(trialsWithSOA), 'omitnan');
            
            %>> store, note we include the speed suffix based on condition:
            ppantData_SOAs.(['nTrialsSOA' save_speed{iCond}])(iSOA)          = length(trialsWithSOA);
            ppantData_SOAs.(['rt1' save_speed{iCond}])(iSOA)                 = mean(useData.RTfromStim1(trialsWithSOA), 'omitnan');
            ppantData_SOAs.(['rt2' save_speed{iCond}])(iSOA)                 = mean(useData.RTfromStim2(trialsWithSOA), 'omitnan');
            ppantData_SOAs.(['propSame' save_speed{iCond}])(iSOA)            = nSameSOA/nThisSOA(iSOA);
            
            % adapted to account for alignment with stim or response:
            % first case is aligning to the first stim in the AV
            % sequence
            % second case is aligning to the response.
            
            alignAt={'_First',  '_Resp'};
            for ialign= 1:length(alignAt) % each event type above:
                
                usefield = ['StepPcnt' alignAt{ialign}];
                
                for iGaitPhase = 1:nGaitPhases
                    
                    % find trials that have a gpcnt for this quantile
                    % member
                    findpcnts = gQindx{iGaitPhase};
                    
                    %intersection of this SOA, and whichever gait quantile:
                    idxThisSOAthisGaitPhase = find(ismember(dataThisSOA.(usefield), findpcnts));
                    
                    %                     idxThisSOAthisGaitPhase = find(dataThisSOA.(usefield)== iGaitPhase);
                    % using the specific field below:
                    %                     idxThisSOAthisGaitPhase = find(dataThisSOA.(usefield)== iGaitPhase);
                    
                    dataThisSOAthisGaitPhase = dataThisSOA(idxThisSOAthisGaitPhase,:);
                    
                    nThisSOAthisGaitPhase = height(idxThisSOAthisGaitPhase);
                    
                    idxSameThisSOAthisGaitPhase = find(dataThisSOAthisGaitPhase.responseType == 1);
                    
                    nSameThisSOAthisGaitPhase = height(idxSameThisSOAthisGaitPhase);
                    
                    propSameThisSOAthisGaitPhase = nSameThisSOAthisGaitPhase / nThisSOAthisGaitPhase;
                    
                    %propSameByGaitandSOA(iGaitPhase,iSOA) = propSameThisSOAthisGaitPhase;
                    
                    %>> store, note we include the speed suffix based on condition:
                    ppantData_SOAs.(['nThisSOAthisGaitPhase' save_speed{iCond}])(iGaitPhase,iSOA)= nThisSOAthisGaitPhase;
                    ppantData_SOAs.(['propSameByGait' save_speed{iCond} alignAt{ialign} 'Aligned'])(iGaitPhase, iSOA)= propSameThisSOAthisGaitPhase;
                    ppantData_SOAs.(['rt1_ByGait' save_speed{iCond} alignAt{ialign} 'Aligned'])(iGaitPhase, iSOA)= mean(dataThisSOAthisGaitPhase.RTfromStim1, 'omitnan');
                    ppantData_SOAs.(['rt2_ByGait' save_speed{iCond} alignAt{ialign} 'Aligned'])(iGaitPhase, iSOA)= mean(dataThisSOAthisGaitPhase.RTfromStim2, 'omitnan');
                    
                    
                    
                end %End gate Phase Loop
                
                %while within the SOA and respAlign loop, calc percentwise
                %propSame:
                alignedPropSame=nan(1,100);
                N_alignedPropSame=nan(1,100);
                RT1_aligned=nan(1,100);
                RT2_aligned=nan(1,100);
                usefield = ['StepPcnt' alignAt{ialign}];

            % for each pcntge, calculate prop same:
            for ipcnt=1:100
                pcnt_idx= find(ismember(dataThisSOA.(usefield), ipcnt));
                % what prop same this idx?
                resps= dataThisSOA.responseType(pcnt_idx);
                nSame = find(resps==1);
                propSame_idx = length(nSame)/length(resps);
                alignedPropSame(ipcnt)= propSame_idx;
                N_alignedPropSame(ipcnt)= length(resps);
                if ~isempty(pcnt_idx)
                RT1_aligned(ipcnt)= nanmean(dataThisSOA.RTfromStim1(pcnt_idx));
                RT2_aligned(ipcnt)= nanmean(dataThisSOA.RTfromStim2(pcnt_idx));
                end
            end


            ppantData_SOAs.(['propSameByGaitPcnt_perSOA_' save_speed{iCond} alignAt{ialign} 'Aligned'])(iSOA,:) = alignedPropSame;
            ppantData_SOAs.(['nStimByGaitPcnt_perSOA_' save_speed{iCond} alignAt{ialign} 'Aligned'])(iSOA,:) = N_alignedPropSame;
            ppantData_SOAs.(['RT1_ByGaitPcnt_perSOA_' save_speed{iCond} alignAt{ialign} 'Aligned'])(iSOA,:) = RT1_aligned;
            ppantData_SOAs.(['RT2_ByGaitPcnt_perSOA_' save_speed{iCond} alignAt{ialign} 'Aligned'])(iSOA,:) = RT2_aligned;
       
              
            end % each align type: rename as we go.
        end  % End of SOA loop
        

        %% As per response to reviewers:
        %including here a script to calculate the above DVs using a
        %bootstrapped version of the natural condition (to reduce total
        %trial counts to match the slow condition, x 1000 perms.)
            
        if iCond==3

            % append_bootstrappedDVs;
            %pseudocode: 
            %per SOA: 1) use nperSOA slow cond.
            %         2) for nPerms x downsample from total trial count
            %         3)calc propSame per down sampled SOA.
            %         4) store mean and SD after nPerms.
            
            %specify the subset we will choose from:
            nPerm=2000;
            for iSOA= 1:nSOAs
                matchSOAcount = ppantData_SOAs.nTrialsSOA_slow(iSOA);

                % Number of targets with SOA(i)
                thisSOA = SOAs(iSOA);
                % trial indx.
                trialsWithSOA= find(useData.SOA== thisSOA);

                %
                if matchSOAcount >= length(trialsWithSOA)
                    disp(['warning, not no trial count difference for participant ' num2str(ippant) ', SOA ' num2str(iSOA)]);

                ppantData_SOAs.(['rt1' save_speed{iCond} '_perm'])(iSOA)            = ppantData_SOAs.(['rt1' save_speed{iCond}])(iSOA); % could also nan
                ppantData_SOAs.(['rt2' save_speed{iCond} '_perm'])(iSOA)                 = ppantData_SOAs.(['rt2' save_speed{iCond}])(iSOA);
                ppantData_SOAs.(['propSame' save_speed{iCond} '_perm'])(iSOA)            = ppantData_SOAs.(['propSame' save_speed{iCond} ])(iSOA);
                    continue
                end

                [propSame_perm, rt1_perm, rt2_perm]= deal(nan(1,nPerm));
                for iperm=1:nPerm
                    templist_idx = randperm(length(trialsWithSOA),matchSOAcount);
                    templist = trialsWithSOA(templist_idx);


                    dataThisSOA = useData(templist, :);

                    nThisSOA = length(templist);

                    % Number of SOA(i) trials with 'SAME' response
                    SameSOA = find(useData.responseType(templist)==1); % 1 is Same, 2 is Different, 0 is absent
                    nSameSOA = length(SameSOA);

                    propSame_perm(iperm) = nSameSOA/nThisSOA;
                    rt1_perm(iperm) =  mean(useData.RTfromStim1(templist), 'omitnan');
                    rt2_perm(iperm) =  mean(useData.RTfromStim2(templist), 'omitnan');
                end



                %>> store, note we include the speed suffix based on condition:                
                ppantData_SOAs.(['rt1' save_speed{iCond} '_perm'])(iSOA)                 = mean(rt1_perm);
                ppantData_SOAs.(['rt2' save_speed{iCond} '_perm'])(iSOA)                 = mean(rt2_perm);
                ppantData_SOAs.(['propSame' save_speed{iCond} '_perm'])(iSOA)            = mean(propSame_perm);

                %% sanity check (show figure for response to reviewers).
                % this figure will show the individual estimates from each
                % perm (in histogram), and vertical lines for observed
                % (full trial count), and mean of permutations (retained)
               if showReviewFigure
                clf;
                histogram(propSame_perm);
                yt= get(gca, 'ylim');
                % observed = 
                obsdata = ppantData_SOAs.propSame_fast(iSOA);
                nObsdata = ppantData_SOAs.nTrialsSOA_fast(iSOA);
                permMeandata = ppantData_SOAs.propSame_fast_perm(iSOA);
                nDSdata = ppantData_SOAs.nTrialsSOA_slow(iSOA);
                hold on; 
                a=plot([obsdata,obsdata], [0 yt(2)], 'r-', 'linew',2);
                b=plot([permMeandata,permMeandata], [0 450], 'b-', 'linew',2);
                ylabel('counts')
                xlabel('proportion "Same" responses');
                legend([a,b],{['Natural speed = ' num2str(obsdata) ' (n_t_r_i_a_l_s = ' num2str(nObsdata) ')'],...
                    ['Natural speed downsampled = ' num2str(permMeandata)  ' (n_t_r_i_a_l_s = ' num2str(nDSdata) ') x 2000 perms ']}, 'Location', 'North')
                
                set(gca,'fontsize', 15)
                ylim([0 500]);
                shg
               end
            end

        end
        % 
        
                
        % outside of SOA loop, calculate the proportion same over the
        % gait-percentages. per response alignment (i.e. all SOAs 
        for ialign= 1:length(alignAt) % each event type above:
            
            alignedPropSame=nan(1,100);
            N_alignedPropSame=nan(1,100);
            rt1_aligned_all=nan(1,100);
            rt2_aligned_all=nan(1,100);
            
            usefield = ['StepPcnt' alignAt{ialign}];

            % for each pcntge, calculate prop same: (all SOAs)
            for ipcnt=1:100
                pcnt_idx= find(ismember(useData.(usefield), ipcnt));
                % what prop same this idx?
                resps= useData.responseType(pcnt_idx);
                nSame = find(resps==1);
                propSame_idx = length(nSame)/length(resps);
                alignedPropSame(ipcnt)= propSame_idx;
                N_alignedPropSame(ipcnt)= length(resps);
                
                
                rt1_aligned_all(ipcnt) = nanmean(useData.RTfromStim1(pcnt_idx));
                rt2_aligned_all(ipcnt) = nanmean(useData.RTfromStim2(pcnt_idx));

            end


            ppantData_SOAs.(['propSameByGaitPcnt' save_speed{iCond} alignAt{ialign} 'Aligned']) = alignedPropSame;
            ppantData_SOAs.(['nStimByGaitPcnt' save_speed{iCond} alignAt{ialign} 'Aligned']) = N_alignedPropSame;
            ppantData_SOAs.(['rt1_ByGaitPcnt' save_speed{iCond} alignAt{ialign} 'Aligned']) = rt1_aligned_all;
            ppantData_SOAs.(['rt2_ByGaitPcnt' save_speed{iCond} alignAt{ialign} 'Aligned']) = rt2_aligned_all;
        end
    end % End of Speed condition loop - for all data, slow data only, fast data only.
    
    disp([' saving participant  ' num2str(ippant) '(synch functions)'])
    % append data to save file:
    subjID= summary_table.participant{1};
    save(allppants(ippant).name, 'ppantData_SOAs','-append');
    
    
end
% End of Participant loop.

