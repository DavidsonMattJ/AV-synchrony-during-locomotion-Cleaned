%JOBS_forPeerReview
%AV synchrony
% - calculate descriptives of targets presented (slow vs natural pace)
% 

% laptop (mac) directory:
% homedir = '/Users/matthewdavidson/Documents/GitHub/AV-Synchrony-during-locomotion';
%USYD directory
% homedir = '\Users\mdav0285\Documents\GitHub\AV-Synchrony-during-locomotion';
%UTS directory
homedir = '/Users/164376/Documents/GitHub/AV-Synchrony-during-locomotion';
addpath(genpath([homedir filesep 'Analysis']));

rawdatadir=  [homedir filesep 'Raw_Data'];
savedatadir= [homedir filesep 'Processed_Data'];
figdir = [homedir filesep 'Figures'];
jobs=[];

cd(savedatadir);

%%
jobs=[];
% calculate descriptives of tagets presented:
jobs.calc_targetdescriptives= 0;
jobs.calc_walkdescriptives= 0 ; %e.g. average speed in each condition.

%%
if jobs.calc_targetdescriptives

calc_targetdescriptives;

end

if jobs.calc_walkdescriptives

calc_walkdescriptives; 

end

