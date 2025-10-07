%calc_targetdescriptives

%% Here we will load participant information (table format), and calculate
% descrriptive statistics such as n per condition, delay between, etc. this
% is based on PR comment #1

%pseudo:
% - load ppant data, 
% - extract
% - stash
% - save

%% set directories
%UTS directory
homedir = '/Users/164376/Documents/GitHub/AV-Synchrony-during-locomotion';

addpath(genpath([homedir filesep 'Analysis']));

rawdatadir=  [homedir filesep 'Raw_Data'];
savedatadir= [homedir filesep 'Processed_Data'];


%% load participant data
cd(savedatadir)
% list pfolders:
pfols =dir([pwd filesep 'p_*']);
nppants = length(pfols);
disp([num2str(nppants) ' participant folders detected']);

%extract n-targets per ppant
GroupDS=[];
GroupcountsperSOA=[];
for ippant = 1:nppants
    clear summary_table

    load(pfols(ippant).name, 'summary_table');

    % find index of practice trials (to remove)
    notpracindx = find(summary_table.isPrac==0);

    %% find index of all 'slow' and 'normal' blocks targets;
    printSpeed = {'slow', 'natural'};

    for ispeed=1:2 %1 is slow, 2 is natural
       targindx= find(summary_table.blockType==ispeed);

       % intersect for relevant index.
       C = intersect (targindx, notpracindx);
        GroupDS.(['nTotalTargsSpeed_' num2str(ispeed)])(ippant) = length(targindx); 
        
        % also include trial counts per SOA type: 
        allSOAs = [summary_table.SOA(C)];
        
        % note this is just ranked absolute list:
        % so [.04, .05, .13,.14, .22, .32, .4]
        typeSOAs = unique(allSOAs); 
        %
        countSOAs=[];
        
        for iSOA= 1:length(typeSOAs)
            
            countSOAs(iSOA) = length(find(allSOAs==typeSOAs(iSOA)));

        end


% store data:
GroupcountsperSOA(ippant,ispeed,:)= countSOAs;

        end
    


    %% also calculate n per trial (on average)
    blocks = unique(summary_table.block);
    nPerSlow=[];
    nPerNormal=[];
    for iblock = 1:blocks(end) % first block 0 is practice.
        for itrial= 0:19 % index starts at 0 in Unity.

            ntargs = intersect(find(summary_table.block==iblock), find(summary_table.trialID==itrial));
            if summary_table.blockType(ntargs(1))==1 % slow pace
                nPerSlow= [nPerSlow, length(ntargs)]; % append (don't know the size, we'll take the average)
            else
                nPerNormal= [nPerNormal, length(ntargs)];
            end

        end

    end
% store data:
GroupDS.(['meanperTrialTargsSpeed_1'])(ippant) = mean(nPerSlow);
GroupDS.(['meanperTrialTargsSpeed_2'])(ippant) = mean(nPerNormal);
GroupDS.(['minperTrialTargsSpeed_1'])(ippant) = min(nPerSlow);
GroupDS.(['maxperTrialTargsSpeed_1'])(ippant) = max(nPerSlow);
GroupDS.(['minperTrialTargsSpeed_2'])(ippant) = min(nPerNormal);
GroupDS.(['maxperTrialTargsSpeed_2'])(ippant) = max(nPerNormal);


%% now calculate the trial counts per SOA, per walkspeed(and range)



    disp(['fin loop for ppant ' num2str(ippant)]);

end

%% summarise in command window:
%
txtmsg= ['>> Total slow targets (M,SD): ' ...
    sprintf('%.2f', mean(GroupDS.nTotalTargsSpeed_1)) ',' ... 
    sprintf('%.2f', std(GroupDS.nTotalTargsSpeed_1)) ...
    newline  ...
    '>> Total natural targets (M,SD): ' ...
    sprintf('%.2f', mean(GroupDS.nTotalTargsSpeed_2)) ',' ... 
    sprintf('%.2f', std(GroupDS.nTotalTargsSpeed_2)) ...
    newline  ...
    '>> mean per trial slow targets (M,SD): ' ...
    sprintf('%.2f', mean(GroupDS.meanperTrialTargsSpeed_1)) ',' ... 
    sprintf('%.2f', std(GroupDS.meanperTrialTargsSpeed_1)) ...
    ', [min,max], [' num2str(min(GroupDS.minperTrialTargsSpeed_1)) ', ' ...
     num2str(max(GroupDS.maxperTrialTargsSpeed_1))   ']'...
    newline  ...
    '>> mean per trial natural targets (M,SD): ' ...
    sprintf('%.2f', mean(GroupDS.meanperTrialTargsSpeed_2)) ',' ... 
    sprintf('%.2f', std(GroupDS.meanperTrialTargsSpeed_2)) ...
    ', [min,max], [' num2str(min(GroupDS.minperTrialTargsSpeed_2)) ', '...
     num2str(max(GroupDS.maxperTrialTargsSpeed_2))   ']'];


disp(txtmsg);

%% SOA print:
%mean, SD, [min,max]
% order should be [-.32, -.14, -.05, .04, .13, .22,.4] 
%current [.04, .05, .13, .14, .22, .32 ,.4];
% .:. new = [6,4,2,1,3,5,7]; 
clc
newOrder = [6,4,2,1,3,5,7];
for iSOA= 1:7%:length(newOrder)
    corrSOA = newOrder(iSOA);
    dispSOA = typeSOAs(corrSOA);
% disp(['>>>>>>>>><<<<<<<<<<<<<<'])
% disp (['>> SOA stats for SOA ' num2str(iSOA) '= ' num2str(dispSOA)]);
% disp(['Slow, Mean = ' num2str(squeeze(mean(GroupcountsperSOA(:,1,corrSOA)))) ]);
% disp(['SD = ' num2str(squeeze(std(GroupcountsperSOA(:,1,corrSOA))))]);
% disp(['[min = ' num2str(squeeze(min(GroupcountsperSOA(:,1,corrSOA))))]);
% disp(['max = ' num2str(squeeze(max(GroupcountsperSOA(:,1,corrSOA)))) ']']);
% 
% disp(['Natural, Mean = ' num2str(squeeze(mean(GroupcountsperSOA(:,2,corrSOA)))) ]);
% disp(['SD = ' num2str(squeeze(std(GroupcountsperSOA(:,2,corrSOA))))]);
% disp(['[min = ' num2str(squeeze(min(GroupcountsperSOA(:,2,corrSOA))))]);
% disp([' max = ' num2str(squeeze(max(GroupcountsperSOA(:,2,corrSOA)))) ']']);

% FOr easy copy-paste, change to 1 or 2 to print slow or natural: 
disp([num2str(squeeze(mean(GroupcountsperSOA(:,2,corrSOA)))) '(' num2str(squeeze(std(GroupcountsperSOA(:,2,corrSOA)))) '),'...
    '[' num2str(squeeze(min(GroupcountsperSOA(:,2,corrSOA)))) ', ' num2str(squeeze(max(GroupcountsperSOA(:,2,corrSOA)))) '];']); 

end

%% also send as JASP output:
jasptab_SOAcounts= table();

%
speedNames={'Slow', 'Natural'};

for ispeed=1:2
    for iSOA=1:7

        colname= ['nper' speedNames{ispeed} '_SOA_' num2str(iSOA)];
        jasptab_SOAcounts.(colname)= [GroupcountsperSOA(:,ispeed,iSOA)];
    end
end
%%
writetable(jasptab_SOAcounts, 'GFX_SOAcounts.csv');


