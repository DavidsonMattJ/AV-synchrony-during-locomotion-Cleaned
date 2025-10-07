% jobs_gaitSpecificParticipantLevel
% -- called from JOBS_import_preprocess;

%% THIS SECTION UPDATES FILE PATH FOR DESKTOP OR ONLINE VERSION

MatlabOnline = 0

if MatlabOnline == 0
    rootPath = 'C:/Users/mobil/Gabriel/MATLAB_Drive';
else
    rootPath = 'MATLAB DRIVE'
end

%% GAIT SPECIFIC PARTICIPANT LEVEL SCRIPT BEGINS HERE

% this script loads the presaved participant level data (matlab tables).
% and separates it into calculates proportion 'same' responses per SOA.
% saves at the same location.

% - load data
% - extract trials per SOA type
% - calculate proportion same
% save
savedatadir= string(rootPath) + '/AV Synchrony Exp/Processed_Data';
cd(savedatadir);

allppants = dir([pwd filesep 'p_*.mat']);
%%
% load data, do x y z





for ippant= 1%:length(allppants)

cd(savedatadir);
load(allppants(ippant).name, 'summary_table');
load(allppants(ippant).name);

disp("Processing Gait Specific Participant Level Data for Participant "+ippant);




mytable = summary_table;

  %% change no responses to nans (to avoid stuffing up averages).
        missedRTs = mytable.targRT==0;
        missedrts_indx = find(missedRTs);
        mytable.targRT(missedrts_indx)=nan;
        mytable.RTfromStim1 = mytable.targRT-mytable.stimSeqStartTime;
        mytable.RTfromStim2= mytable.RTfromStim1-mytable.SOA;

        %% exchange data from

        %find all stimOrder = AV.
        AudLeadIdx= mytable.stimOrderDesired==2;

        % change SOA to +- relevant to VA
        mytable.SOA(AudLeadIdx) = mytable.SOA(AudLeadIdx) *-1;


        
        walkingIdx = find(mytable.blockType~=0);
        walkingData = mytable(walkingIdx,:);
        
        
% Divide data by walk speed, SOA, gait cycle.
% eg. slow, SOA(1), GaitPhase = 1
        
        % create slow data and fast data.
        slowtrials = walkingData.blockType==1;
        fasttrials = walkingData.blockType==2;

        slowData = walkingData(slowtrials,:);
        fastData = walkingData(fasttrials,:);


        SOAs = unique(mytable.SOA);
        nSOAs = length(SOAs);
       
        %preallocate for all data (walk speeds combined)
        propSameSOA_all = nan(1,nSOAs);
        RTfromstim1_perSOA_all= nan(1,nSOAs);
        RTfromstim2_perSOA = nan(1,nSOAs);
        nThisSOA = nan(1,nSOAs);

        idxAllGait1 = find(walkingdata.
        
        idxSlowGait1
        
        idxSlowGait2
        
        idxSlowGait3
        
        idxSlowGait4

        %alternatively, deal the same nan array to all these variables in one line.
        %[propSameSOA, RTfromstim1_perSOA, RTfromstim2_perSOA, nThisSOA]
        %=deal(nan(1,nSOAs));

        % for our 3 data types (all data, slow ,and fast).
        speedData ={walkingData, slowData, fastData};
% 
%         for iCond= 1:length(speedData)
% 
%             useData = speedData{iCond};
% 
%             propSame=[]; % proportion same per SOA
%             rt1=[]; % RT from stim 1, per SOA.
%             rt2=[]; % RT from stim 2, per SOA.
%             nThisSOA=[];
%             for iSOA=1:nSOAs
% 
%                 % Number of targets with SOA(i)
%                 thisSOA = SOAs(iSOA);
%                 trialsWithSOA= find(useData.SOA== thisSOA);
%                 nThisSOA(iSOA) = length(trialsWithSOA);
% 
%                 % Number of SOA(i) trials with 'SAME' response
%                 SameSOA = find(useData.responseType(trialsWithSOA)==1); % 1 is Same, 2 is Different, 0 is absent
%                 nSameSOA = length(SameSOA);
% 
%                 % Proportion of Same Responses on those trials
%                 propSame(iSOA) = nSameSOA/nThisSOA(iSOA);
% 
%                 
% 
%                 %rt for this SOA.
%                 rt1(iSOA)  = mean(useData.RTfromStim1(trialsWithSOA), 'omitnan');
%                 rt2(iSOA)  = mean(useData.RTfromStim2(trialsWithSOA), 'omitnan');
% 
%             end
% 
%             %% now that the analyses are done, rename as per condition.
%             if iCond==1
%                 % rename the data for 'all '
% 
%                 propSame_all= propSame;
%                 RTfromStim1_all= rt1;
%                 RTfromStim2_all= rt2;
%                 nperSOA_all= nThisSOA;
% 
% %                 %Fit Gaussian to Synchrony function
% %                 gaussian_allwalks = fitdist(propSame_all, 'Normal');
% % 
% %                 mean_allwalks = gaussian_allwalks.mu
% %                 sd_allwalks = gaussian_allwalks.sigma
% 
% 
%             elseif iCond ==2
%                 %rename for slow speed
% 
%                 propSame_slow= propSame
%                 RTfromStim1_slow= rt1;
%                 RTfromStim2_slow= rt2;
%                 nperSOA_slow= nThisSOA;
% 
% %                 figure(1)
% %                 hold on
% %                 plot(SOAs,propSame_slow)
% 
% %                %Fit Gaussian to Synchrony function
% %                 gaussian_slow = fitdist(propSame_all, 'Normal');
% %                 y= pdf(gaussian_slow, SOAs)
% %                 plot(y)
% %                 mean_slow = gaussian_slow.mu;
% %                 sd_slow =  gaussian_slow.sigma;
% 
%             elseif iCond==3
%                 %rename for fast speed
% 
%                 propSame_fast= propSame;
%                 RTfromStim1_fast= rt1;
%                 RTfromStim2_fast= rt2;
%                 nperSOA_fast= nThisSOA;
% 
% %                 %Fit Gaussian to Synchrony function
% %                 gaussian_fast = histfit(propSame_all, 'Normal');
% %                 mean_fast =  gaussian_fast.mu;
% %                 sd_fast = gaussian_fast.sigma;
% 
%             end
% 
%         end % for all data, slow data only, fast data only.
%    
%         disp([' saving participant  ' num2str(ippant) '(prop same)'])
%         % append data to save file:
%         subjID= summary_table.participant{1};
%         save(allppants(ippant).name, 'propSame_all', 'propSame_slow', 'propSame_fast',...
%             'RTfromStim1_all', 'RTfromStim1_slow', 'RTfromStim1_fast',...
%             'RTfromStim2_all', 'RTfromStim2_slow', 'RTfromStim2_fast',...
%             'nperSOA_all', 'nperSOA_slow', 'nperSOA_fast',  'SOAs', 'subjID', '-append');
% % Removed temporarily -  ...
%            % 'mean_all', 'mean_slow', 'mean_fast', 'sd_all', 'sd_slow', 'sd_fast',
% %
% 
end
% End of participant loop


