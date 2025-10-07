% job_fitppant_asymGauss
% this script loads individual subject data and fits an asymmetric gaussian to the
% LHS and RHS of the synchrony function.

% called from the JOBS_import_preprocess.m index script.


cd(savedatadir);

allppants = dir([pwd filesep 'p_*.mat']);
%%

job=[];
job.fitper_participant=1; % perform fits per participant
job.plotPPantFitts=0; % optional produce figures as we go.

% >>>>>
% now fitting an asymmetric gaussian to obtain width of LHS and RHS:
% note that this calls the function trySekewedGaussLR_nlin.m which needs to
% be on an accessible path/directory.

NLIN= 1; % 1 for NLINFIT; 0 or FMINSEARCH;
% Note: Only NLINFIT gives CIs and takes Weights

% e.g.:
%
% startingVals = [ 0  50  100   1 ];
% if NLIN
%     [ estimates,  resid, jacob, covarEst mse ] = nlinfit(SOAs, pSync,  @trySkewedGaussLR_nlin,startingVals );
%     ci = nlparci(estimates, resid, 'jacobian' , jacob); % calculate 95% confidence limits around estimates.
% else
%     options = optimset;
%     estimates = fminsearch(@trySkewedGaussLR,startingVals,options,SOAs ,pSync);
% end
% estimates = round(estimates*1000)/1000;
%
% a = estimates(1); % Mean
% b = estimates(2); % SD of left half
% c = estimates(3); % SD of right half





if job.fitper_participant==1
    for ippant= 1:length(allppants)


        cd(savedatadir);
        load(allppants(ippant).name, 'ppantData_SOAs');
        SOAs = ppantData_SOAs.SOAs;
        SOAs_ms= SOAs*1000';
        %store all the data types we will fit in a matrix , to easily cycle
        %through
        % note that all synch functions have the same number of data points: (7)

        myGaussMatrix_bySpeed=[];
        myGaussMatrix_bySpeed(1,:)= ppantData_SOAs.propSame_all;
        myGaussMatrix_bySpeed(2,:)= ppantData_SOAs.propSame_slow;
        myGaussMatrix_bySpeed(3,:)= ppantData_SOAs.propSame_fast;
        %new for reviewer request
        myGaussMatrix_bySpeed(4,:)= ppantData_SOAs.propSame_fast_perm;


        % keep track of data in each location:
        fitsTitle={'pSame_all', 'pSame_slow', 'pSame_fast','pSame_fast_perm'};


        nsubs= length(allppants);

        % prepare output structure
        participant_asymGauss_Fits_bySpeed=[];


        for igspeed= 1:size(myGaussMatrix_bySpeed,1) %

            %pseudo code: interpolate the observed data to 1000 points, to improve the
            %fit.
            %fit a gaussian using the above model, retain the parameters within this
            %loop and save.

            thisData = myGaussMatrix_bySpeed(igspeed,:);

            % as per discussion with DA, normalize all to 1 to increase fit strength:
            %norm between 0 and 1::
            thisData_upper=  thisData./ max(thisData);

            thisData= thisData_upper;

            % %%
            % fnan = find(isnan(thisData));
            % if ~isempty(fnan)
            % thisData(fnan)= (thisData(fnan-1) + thisData(fnan+1))/2;
            % end


            % startingVals = [ 0  50  100   1 ]; % .1];
            % if NLIN
            %     [ estimates,  resid, jacob, covarEst mse ] = nlinfit(SOAs, pSync,  @trySkewedGaussLR_nlin,startingVals );
            %     ci = nlparci(estimates, resid, 'jacobian' , jacob); % calculate 95% confidence limits around estimates.
            % else
            %     options = optimset;
            %     estimates = fminsearch(@trySkewedGaussLR,startingVals,options,SOAs ,pSync);
            % end
            % estimates = round(estimates*1000)/1000;
            %
            % a = estimates(1); % Mean
            % b = estimates(2); % SD of left half
            % c = estimates(3); % SD of right half
            %%
            % here we perform the fit:, note the bounds may need to be adjusted for
            % accurate LHS/RHS fit.

            startingVals = [ 0  50  100   1 ]; % .1];

            [ estimates,  resid, jacob, covarEst mse ] = nlinfit(SOAs_ms', thisData,  @trySkewedGaussLR_nlin,startingVals );

            estimates = round(estimates*1000)/1000;




            % %% sanity check (plot fit on top of observed data).
            % clf;
            % subplot(211)% without tailing
            % plot(SOAs_ms, thisData, 'k-o');
            % hold on;
            fittedC =  trySkewedGaussLR_nlin(estimates, SOAs_ms');
            % hold on;
            % plot(SOAs_ms, fittedC, 'r');
            % subplot(212);
            % plot(SOAs_ms_tail, thisData_tail, 'k-o');
            % fittedC =  trySkewedGaussLR_nlin(estimates, SOAs_ms_tail);
            % hold on;
            % plot(SOAs_ms_tail, fittedC, 'r');
            %


            %%
            participant_asymGauss_Fits_bySpeed(igspeed).datais= fitsTitle{igspeed};
            participant_asymGauss_Fits_bySpeed(igspeed).gaussfit = [estimates];
            participant_asymGauss_Fits_bySpeed(igspeed).gaussData_Y = fittedC;
            participant_asymGauss_Fits_bySpeed(igspeed).gaussData_X = SOAs_ms;
            participant_asymGauss_Fits_bySpeed(igspeed).observedData = thisData;


        end % iGspeed

        save(allppants(ippant).name,'participant_asymGauss_Fits_bySpeed',  '-append');
        disp(['finished all fits for ppant ' num2str(ippant)])
    end % ppant
end % fit job

%%
if job.plotPPantFitts==1
    %%
    speedFlds= {'_all', '_slow', '_fast'};

    %%
    for ippant = 1:length(allppants)
        clf;
        set(gcf, 'units', 'normalized', 'position', [0.05 0.05  .95 .95], 'color', 'w');

        cd(savedatadir);
        load(allppants(ippant).name, 'participant_asymGauss_Fits_bySpeed','participant_asymGauss_Fits_bySpeedbyAlignbyGait', 'subjID')

        cd(figdir)
        cd('Participant asym Gaussian fits (all)');

        %%
        SOAs= participant_asymGauss_Fits_bySpeed(1).gaussData_X; % in ms
        clf
        speedCols= {'k', 'b', 'r'};
        for igspeed= 1:length(participant_asymGauss_Fits_bySpeed)
            %%
            subplot(1,2,1); hold on;
            thisData= participant_asymGauss_Fits_bySpeed(igspeed).observedData;
            plot(SOAs, thisData, 'k-o', 'MarkerFaceColor', speedCols{igspeed});
            title(['Each speed, observed data, normalized']);
            hold on;
            ylim([0 1])
            %fix ylim
            yl= get(gca, 'ylim');
            xlim([SOAs(1) SOAs(end)])
            subplot(1,2,2); hold on;
            yf = participant_asymGauss_Fits_bySpeed(igspeed).gaussData_Y;
            g=plot(SOAs, yf, '-', 'LineWidth',2, 'color', speedCols{igspeed}); % fit.
            %     legend(g, 'fit')

            ylim([0 1])

            % hold on, plot Mu.
            mu = participant_asymGauss_Fits_bySpeed(igspeed).gaussfit(1);
            sigm_LHS = participant_asymGauss_Fits_bySpeed(igspeed).gaussfit(2);
            sigm_RHS = participant_asymGauss_Fits_bySpeed(igspeed).gaussfit(3);
            ytop = max(yf);
            hold on;
            %
            % plot gauss mean:
            plot([mu mu], ylim, 'color', speedCols{igspeed})
            % plot sig (at Half max).
            plot([mu-sigm_LHS mu], [ytop/2+.05*igspeed ,ytop/2 + .05*igspeed ], 'linew', 1,'color', speedCols{igspeed})
            plot([mu mu+sigm_RHS], [ytop/2+.05*igspeed ,ytop/2 + .05*igspeed ], 'linew',4,'color', speedCols{igspeed})

            xlim([SOAs(1) SOAs(end)])

        end % igfit.
        shg
        %%
        print('-dpng', ['Participant ' num2str(ippant) ' ' subjID '_asymGauss by speed']);
        %%
    end % ppant
end % plot Job
