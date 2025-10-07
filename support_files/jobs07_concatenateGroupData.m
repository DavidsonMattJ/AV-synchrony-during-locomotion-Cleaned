% jobs_concatenate_all

% -- called from JOBS_import_preprocess;


% Gather output from earlier jobs and concatenate group level effects



%specify save directory:

cd(savedatadir);

allppants = dir([pwd filesep 'p_*data.mat']);
%%

nsubs= length(allppants);

GFX_Data_SOAs=[];
GFX_headY=[]; 

GFX_gauss_Cond_x_Yfit= zeros(nsubs, 3, 1000); % dims: subjects, cond(all,slow,fast), sample.
GFX_gauss_Cond_xparam=zeros(nsubs, 3, 2); % last dim: mean and width of gaussian fit.(and amp)

GFX_asymgauss_Cond_x_Yfit= zeros(nsubs, 3, 7); % dims: subjects, cond(all,slow,fast), sample.
GFX_asymgauss_Cond_xparam=zeros(nsubs, 3, 3); % last dim: mean and LHS , RHS width of gaussian fit.

for ippant= 1:nsubs
    
    
    cd(savedatadir);
    load(allppants(ippant).name, 'ppantData_SOAs',...
        'participantGauss_Fits_bySpeed',...
        'participant_asymGauss_Fits_bySpeed');
    
    if ippant==1
        allflds = fields(ppantData_SOAs);
        
    end
    %% Start by concatenating the SOA data:
    disp(['concatenating participant ' num2str(ippant)])
    for ippantfield= 1:length(allflds)
        tmpdata = ppantData_SOAs.([allflds{ippantfield}]);
        if size(tmpdata,1)==1 % array
            GFX_Data_SOAs.([allflds{ippantfield}])(ippant,:) = tmpdata;
        else % matrix:
            GFX_Data_SOAs.([allflds{ippantfield}])(ippant,:,:) = tmpdata;
            
        end
    end % each field

%% For each condition (speed) concatenate the Gaussian fits (symmetric and Asymmetric)

    for icond= 1:4 % all, slow, fast, fast_nperm:
        %% first store the Gaussian for plotting:
        GFX_gauss_Cond_x_Yfit(ippant,icond,:) = participantGauss_Fits_bySpeed(icond).gaussData_Y; %

        % % % now store the parameters for specific between condition stats:
        GFX_gauss_Cond_xparam(ippant,icond,1)= participantGauss_Fits_bySpeed(icond).gaussfit(1); % b is coefficient for mean.
        GFX_gauss_Cond_xparam(ippant,icond,2)= participantGauss_Fits_bySpeed(icond).gaussfit(2); % c is coefficient for SD.
        %added for peer review - compare GoF
        GFX_gauss_Cond_xparam(ippant,icond,3)= participantGauss_Fits_bySpeed(icond).gaussGoF; % 

        %% and the same for the Asymmetric data:
        GFX_asymgauss_Cond_x_Yfit(ippant,icond,:) = participant_asymGauss_Fits_bySpeed(icond).gaussData_Y; %

        % % % now store the parameters for specific between condition stats:
        GFX_asymgauss_Cond_xparam(ippant,icond,1)= participant_asymGauss_Fits_bySpeed(icond).gaussfit(1); % b is coefficient for mean.
        GFX_asymgauss_Cond_xparam(ippant,icond,2)= participant_asymGauss_Fits_bySpeed(icond).gaussfit(2); % c is coefficient for SD (LHS).
        GFX_asymgauss_Cond_xparam(ippant,icond,3)= participant_asymGauss_Fits_bySpeed(icond).gaussfit(3); % c is coefficient for SD (LHS).

    end

end % ppant
%%% also store the X axis for plots.
gauss_xvec = participantGauss_Fits_bySpeed(1).gaussData_X; % same for all conds.

save('GFX_SOAdata' , 'GFX_Data_SOAs','GFX_gauss_Cond_xparam','GFX_asymgauss_Cond_xparam', 'gauss_xvec');
%


