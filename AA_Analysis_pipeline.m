%% %%%%%%
% AV synchrony while walking
% In this script we will sequentially perform the analysis for the paper.


%set up directories, e.g. at UTS:
homedir = '/Users/164376/Documents/GitHub/AV-Synchrony-during-locomotion copy';
addpath(genpath([homedir filesep 'Analysis']));
rawdatadir=  [homedir filesep 'Raw_Data'];
savedatadir= [homedir filesep 'Processed_Data'];
figdir = [homedir filesep 'Figures'];



cd(savedatadir);
%%

jobs=[];
jobs.Preprocess =1;
jobs.Analyse=1;
jobs.Plot=1;



%% Preprocess by importing from CSV, converting to Matlab, 
% and allocating trial events to step-cycle phases
if jobs.Preprocess==1

    % Import from CSV and save in matlab format:
    jobs01_import; 
  
    % Find peaks in head height as proxy for gait:
    jobs02_split_bycycle;
    
    %  Append gait-percentile information to trial events:
    jobs03_AssignWalkPhases; 
    jobs03B_epochGait_ts_calcWalkParams; %calculates average head tracking and walk parameters per participant, needed in Manuscript plots.
    
end
%% Analyse by calculating synchrony functions per participant, and apply Gaussian fits:

if jobs.Analyse==1
% calculate synchrony function per walking speed:
jobs04_calculateParticipantlevelSynchfn;  % main participant level effects.

% Fit Gausssian to Synchrony function per speed:
jobs05_fitppantGauss;

% Fit Asymmetric Gaussian per speed:
jobs06_fitppant_asymGauss; % fit and plo options.

% Concatenate all data:
jobs07_concatenateGroupData;
end

%% Plots for Manuscript: 
if jobs.Plot==1

    plot_MSfigure2;
    plot_MSfigure3;
    plot_MSfigure4;

end
