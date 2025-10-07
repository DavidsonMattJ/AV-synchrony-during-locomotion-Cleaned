% job_fitppantGauss
% this script loads individual subject data and fits a gaussian to the
% synchrony function for walk speed conditions.

% called from the JOBS_import_preprocess.m index script.

% savedatadir= string(rootPath) + '/AV Synchrony Exp/Processed_Data';
cd(savedatadir);

allppants = dir([pwd filesep 'p_*.mat']);

%% SET UP

job=[];

plotPPantFitts=0; % time-consuming, but prints individual fits to figure folder for sanity checks,

% >>>>>
%create a handle to a function called gaus that takes input parameters:
% x, array of x values
% mu, mean
% sig, SD
% amp, pos or negative curve
% vo, vertical offset.

%Full version would be:
% gaus = @(x,mu,sig,amp,vo)amp*exp(-(((x-mu).^2)/(2*sig.^2)))+vo;
% gaussEqn = 'a*exp(-((x-b)^2/(2*c^2)))+d';


%Simpler version (2 free params):

gaus = @(x,mu,sig)exp(-(((x-mu).^2)/(2*sig.^2)));
gaussEqn = 'exp(-((x-b)^2/(2*c^2)))';




% note because we know the shape of the gaussians (approx), we can help the
% fit by specifying some lower bounds

foptions =fitoptions(gaussEqn);
% for each coefficient, apply some sensible bounds.


% default fit params:
foptions.Lower= [-.3, .1]; %for [M,SD]
foptions.Upper= [.3, 1];
foptions.StartPoint= [.2, 10];
foptions.MaxIter= 2000;


%% Per ppant loop:
for ippant= 1:length(allppants)

    cd(savedatadir);
    load(allppants(ippant).name, 'ppantData_SOAs');

    %store all the data types we will fit in a matrix , to easily cycle
    %through
    % note that all synch functions have the same number of data points: (7)

    myGaussMatrix_bySpeed=[];
    myGaussMatrix_bySpeed(1,:)= ppantData_SOAs.propSame_all;
    myGaussMatrix_bySpeed(2,:)= ppantData_SOAs.propSame_slow;
    myGaussMatrix_bySpeed(3,:)= ppantData_SOAs.propSame_fast;
    % new addition, to test effect of trial counts
    myGaussMatrix_bySpeed(4,:)= ppantData_SOAs.propSame_fast_perm;


    % keep track of data in each location:
    fitsTitle={'pSame_all', 'pSame_slow', 'pSame_fast','pSame_fast_perm'};


    nsubs= length(allppants);

    [nGaits, nSOAs]= size(ppantData_SOAs.nThisSOAthisGaitPhase_all);

    speedFlds= {'_all', '_slow', '_fast','_fast_perm'};

    % prepare output structs
    participantGauss_Fits_bySpeed=[];

    for igspeed= 1:size(myGaussMatrix_bySpeed,1) %

        %pseudo code: interpolate the observed data to 1000 points, to improve the
        %fit.
        %fit a gaussian using the above model, retain the parameters within this
        %loop and save.

        thisData = myGaussMatrix_bySpeed(igspeed,:);

        % as per DA discussion, normalize all to 1 to increase fit strength:
        %norm between 0 and 1:

        % thisData_scld=  (thisData - min(thisData)) / (max(thisData) - min(thisData));
        %actually just norm height to 1, so that we dont shrink the width when
        %scaling to zero:
        thisData_upper=  thisData./ max(thisData);

        thisData= thisData_upper;
        %%
        fnan = find(isnan(thisData));
        if ~isempty(fnan)
            thisData(fnan)= (thisData(fnan-1) + thisData(fnan+1))/2;
        end


        % fix to floor, and connect the SOAs to facilitate Gaussian Fit:
        interpAt = linspace(-1, 1, 1000);
        propInterp= interp1([-1,SOAs',1], [0, thisData, 0], interpAt);


        % perform fit :
        [fit1, gof] = fit(SOAs, thisData', gaussEqn, foptions);

        %plot the results of the fit on top of the data:
        hold on;


        fit_mu= fit1.b;

        fit_sig= fit1.c;

        yf = gaus(interpAt, fit_mu, fit_sig);

        participantGauss_Fits_bySpeed(igspeed).datais= fitsTitle{igspeed};
        participantGauss_Fits_bySpeed(igspeed).gaussfit = [fit_mu, fit_sig];
        participantGauss_Fits_bySpeed(igspeed).gaussData_Y = yf;
        participantGauss_Fits_bySpeed(igspeed).gaussData_X = interpAt;
        participantGauss_Fits_bySpeed(igspeed).observedData = thisData;
        % add GoF for Peer Review:
        participantGauss_Fits_bySpeed(igspeed).gaussGoF= gof.rsquare;



    end % iGspeed (up to fast_nPerm)

    save(allppants(ippant).name,'participantGauss_Fits_bySpeed', '-append');
    disp(['finished all fits for ppant ' num2str(ippant)])
end % ppant


%%
if plotPPantFitts==1
    %%
    speedFlds= {'_all', '_slow', '_fast','_fast_perm'};
    alignFlds= {'_FirstAligned', '_VisAligned', '_AudAligned', '_LastAligned', '_RespAligned'};
    %%
    for ippant = 1:length(allppants)
        clf;
        set(gcf, 'units', 'normalized', 'position', [0.05 0.05  .95 .95], 'color', 'w');

        cd(savedatadir);
        load(allppants(ippant).name, 'participantGauss_Fits_bySpeed', 'subjID')

        cd(figdir)
        cd('Participant Gaussian fits (all)');

        %%
        SOAs= [-0.32, -.14, -.05, .04, .13, .22, .4];
        clf
        speedCols= {'k', 'b', 'r'};
        for igspeed= 1:length(participantGauss_Fits_bySpeed)

            subplot(1,2,1); hold on;
            thisData= participantGauss_Fits_bySpeed(igspeed).observedData;
            plot(SOAs, thisData, 'k-o', 'MarkerFaceColor', speedCols{igspeed});
            title(['Each speed, observed data, normalized']);
            hold on;
            ylim([0 1])
            %fix ylim
            yl= get(gca, 'ylim');
            xlim([SOAs(1) SOAs(end)])
            subplot(1,2,2); hold on;
            interpAt = participantGauss_Fits_bySpeed(igspeed).gaussData_X;
            % shrink size of interp to make the plots faster.

            %     propInterp= interp1(SOAs, thisData, interpAt);

            %     plot(interpAt, propInterp, 'r:'); % interpolated

            yf= participantGauss_Fits_bySpeed(igspeed).gaussData_Y;
            g=plot(interpAt, yf, '-', 'LineWidth',2, 'color', speedCols{igspeed}); % fit.
            %     legend(g, 'fit')

            ylim([0 1])

            % hold on, plot Mu.
            mu = participantGauss_Fits_bySpeed(igspeed).gaussfit(1);
            sigm = participantGauss_Fits_bySpeed(igspeed).gaussfit(2);
            ytop = dsearchn(interpAt', mu');
            hold on;
            % plot gauss mean:
            plot([mu mu], [0 yf(ytop)], 'color', speedCols{igspeed})
            % plot sig (at Half max).
            plot([mu-sigm/2 mu+sigm/2], [yf(ytop)/2+.05*igspeed ,yf(ytop)/2 + .05*igspeed ], 'linew', 1,'color', speedCols{igspeed})

            xlim([SOAs(1) SOAs(end)])

        end % igfit.
        shg
        %%
        print('-dpng', ['Participant ' num2str(ippant) ' ' subjID '_Gauss by speed']);
        %%
    end % ppant
end %plot job.