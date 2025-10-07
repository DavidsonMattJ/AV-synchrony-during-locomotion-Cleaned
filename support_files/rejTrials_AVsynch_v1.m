% rejTrials_AVsynch_v1


% certain bad trials (identified in figure folder).
% look at 'TrialHeadYPeaks', to see if the tracking dropped out on any
% trials. Or if participants were not walking smoothly.

% abbreviations for rejected trials:
% s = poor signal quality (drop-outs/discontinuities)
% g= poor gait extraction (head tracking unclear).

% step in to reject particular ppant+trial combos.
badtrials=[];
switch subjID
    case 'p_01'
        badtrials = [54,66,128 ];
    case 'p_02'
       badtrials=[];
    case 'p_03'
        badtrials=[];
    case 'p_04'
        badtrials=[];
    case 'p_05'
        badtrials=[];
        
    case 'p_06'
        badtrials=[];
    case 'p_07'
        badtrials=[];

    case 'p_08' % 
        badtrials=9; 
    case 'p_09'
        badtrials=[];
    case 'p_10'
        badtrials=[6,45,189,196];
        
    case 'p_11'
        badtrials=174;
    case 'p_12'       
        badtrials=[50,53,128, 169];
    case 'p_13'
        badtrials=[];
    case 'p_14'
        badtrials=[5,6,23:30, 43,136,139,152, 173];
    case 'p_15'
        badtrials=[22,36,53113,135];
    case 'p_16'
        badtrials=11;
    case 'p_17'
        badtrials=[6,111, 177];
    case 'p_18'
        badtrials=[];
    case 'p_19'
        
       badtrials=[];
    
    case 'p_20'
        badtrials=[9, 84];
    case 'p_21' % 
        badtrials=[6];
    
        
end

    
%%
if ismember(itrial,badtrials)
    disp(['Skipping bad trial ' num2str(itrial) ' for ' subjID]);
    skip=1;
end
%%