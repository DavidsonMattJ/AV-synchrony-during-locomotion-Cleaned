
% This script loads the raw csvs and saves as a matlab table. 
% -- called from JOBS_import_preprocess;

%% THIS SECTION UPDATES FILE PATH FOR DESKTOP OR ONLINE VERSION

cd(rawdatadir)
% prepare paths to load data:
allppants_frame = dir([pwd filesep '*framebyframe.csv']);
allppants_summary = dir([pwd filesep '*trialsummary.csv']);


%% load and save the csv as a Matlab table.

usefiles = {allppants_frame, allppants_summary};

for ifiletype=1:2

    
        readfiles = usefiles{ifiletype};

    for ippant = 1:length(readfiles)
        cd(rawdatadir);
        readfile = readfiles(ippant).name;

        opts=detectImportOptions(readfile);
        %Defines the row location of channel variable name
        opts.VariableNamesLine = 1;
        %Specifies that the data is comma seperated
        opts.Delimiter =','; 
        %Read the table
        mytab = readtable(readfile,opts, 'ReadVariableNames', true);
        
        %initial and index.
        if ippant<10
            pnum = ['0' num2str(ippant)];
        else
            pnum = num2str(ippant);
        end
        saveID = ['p_' mytab.participant{1} '_' pnum];

        cd(savedatadir);
        subjID = readfile(1:2);

        disp(['Saving file ' num2str(ifiletype) ' for ppant ' num2str(ippant)]);
        %%
        if ifiletype==1
            framebyframe_table= mytab;
            disp(['saving framebyframe data for participant ' num2str(ippant)]);
            save([saveID '_data'], 'framebyframe_table', 'subjID');
        else
            summary_table= mytab;
            disp(['saving summary table data for participant ' num2str(ippant)]);
            save([saveID '_data'], 'summary_table', '-append');

        end
        
    end % participants


   

end % filetype

%% 



