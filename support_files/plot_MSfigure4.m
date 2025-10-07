%% plot MS figure 4
% - step-cycle changes at shortest SOAs.

cd(savedatadir);
load('GFX_SOAdata.mat', 'GFX_Data_SOAs');
load('GFX_asymGaussData.mat', 'GFX_headY');

alignFlds= {'_FirstAligned', '_RespAligned'};
%
iAlign= 1; % of the above.
nGaitQ = size(GFX_Data_SOAs.propSameByGait_slow_FirstAligned,2);
normON=1;
inormmethod=3;


figure(4);clf
set(gcf,'units', 'normalized', 'Position', [.1 .1 .8 .8], 'color', 'w');

fntsize=14;
% first plot the head position summary info (1x3 , ppant average, quantile
% splits, targets per).

%
nppants= size(GFX_headY,1);
GFX_headboth = [];
for ippant=1:size(GFX_headY,1)
    GFX_headboth(1,ippant,:) = GFX_headY(ippant,1).gc; % resampled version.
    GFX_headboth(2,ippant,:) = GFX_headY(ippant,2).gc; % resampled version.

end
spdCols = {'b', 'r'};
subplot(2,3,1); % plot both.
hold on
for ispd= 1:2
    tmp =squeeze(GFX_headboth(ispd,:,:));
    mH = squeeze(mean(tmp,1));
    stE = std(tmp,0,1)./sqrt(nppants);
    shadedErrorBar(1:length(tmp), mH, stE, [spdCols{ispd}],1)
end
xlabel('step cycle (%)');
ylabel('detrended head height (m)');
text(1, .0175, 'Slow','color','b','fontsize',fntsize)
text(1, .015, 'Natural', 'Color','r','fontsize',fntsize)
set(gca,'fontsize',fntsize)
%
subplot(2,3,2); cla % maybe mean of both with the markers>
ylim([-.02 .02])
hold on
% add the patches first: % use a colour gradient:
reds = cbrewer('seq', 'Reds',10);
xp = [0 0 20 20];
yp = [-.02, .02 , .02 , -.02];

ph = patch(xp, yp, reds(1,:));
ph.FaceAlpha=.5;
text(mean(xp), -.0175, ['Q1'], 'HorizontalAlignment', 'center')

for iq=1:4
    xp= xp+20;
    ph = patch(xp, yp, reds(iq+1,:));
    ph.FaceAlpha=.5;

    text(mean(xp), -.0175, ['Q' num2str(iq+1)], 'HorizontalAlignment', 'center')
end

tmp = squeeze(mean(GFX_headboth,1));
mH = squeeze(mean(tmp,1));
stE = std(tmp,0,1)./sqrt(nppants);
shadedErrorBar(1:length(tmp), mH, stE, ['k'],1);
xlabel('step cycle (%)');
ylabel('detrended head height (m)');

set(gca,'fontsize',fntsize)

% final, show target onset counts.
plotData= GFX_Data_SOAs.nThisSOAthisGaitPhase_all;
%tally the sum of the two short SOAs (index
subplot(2,3,3); cla

tmpD = squeeze(plotData(:,:,3:5));
mB =[squeeze(mean(tmpD(:,:,1),1));  squeeze(mean(tmpD(:,:,2),1));squeeze(mean(tmpD(:,:,3),1))]; % mean per SOA.
stE =[CousineauSEM(squeeze(tmpD(:,:,1))); CousineauSEM(squeeze(tmpD(:,:,2)));CousineauSEM(squeeze(tmpD(:,:,3)))]; % mean per SOA.
hold on;
bh=bar( 1:5, mB', 'BarWidth', 1);
bh(1).FaceColor= [.5 .5 .5];
bh(2).FaceColor = [.9 .7 .1];
bh(3).FaceColor= [.75 .75 .75];

hold on;
errorbar_groupedfit(mB', stE');
ylim([0 55])
ylabel('stimulus onsets')
xlabel('step quintile')
set(gca,'fontsize', fntsize)
legend([bh(1), bh(2),bh(3)], {'SOA -50 ms','SOA +40 ms', 'SOA +130 ms'}, 'Location','NorthEast')

%
spdCols= {'k', 'b', 'r'};
SOAcols = [.5 .5 .5;... % from bar above
    .9 .7 .1;...
    .75 .75 .75];


titlesare={{['auditory leading'];['(-50 ms)']}, {['visual leading'];['(+40ms)']}, {['visual leading'];['(+130ms)']}};

psare={'\itns', '***','\itns'};

for iGplot=1:3 % 3 plots this script (combined SOAs, SOA3, and SOA4).

    if iGplot==1
        averageSOAs = 3;%
    elseif iGplot==2
        % a single index.
        averageSOAs= 4;
    elseif iGplot==3
        averageSOAs=5;

    end

    %extract data based on aligment.
    plotData= { GFX_Data_SOAs.(['propSameByGait_all' alignFlds{iAlign}]),...
        GFX_Data_SOAs.(['propSameByGait_slow' alignFlds{iAlign}]),...
        GFX_Data_SOAs.(['propSameByGait_fast' alignFlds{iAlign}])};

    % we will plot all data (1-3 are all, slow, normal speeds)
    for iSpeed = 1%:3
        
        pltd= plotData{iSpeed};
       
        pData =squeeze(nanmean(pltd(:,:,averageSOAs),3)); %mean over particular SOAs.

        

        % norm per ppant.
        if normON==1
            pData = normMatrix(pData,inormmethod); %relative change
            pData(isinf(pData))=nan;
        end
        % plot
        subplot(2,3,iGplot + 3); hold on;

        %         plot(1:nGaitQ, nanmean(pData,1), '-o','color',spdCols{iSpeed})
        bh=bar(1:nGaitQ, nanmean(pData,1));
        bh.FaceColor= SOAcols(iGplot,:);
        bh.EdgeColor = 'k';
        stE= CousineauSEM(pData);
        errorbar(1:nGaitQ, nanmean(pData,1), stE, 'LineStyle','none', 'color',spdCols{iSpeed}, 'linew',2)
        statsOUT = plotGoF_gauss(pData, 1:nGaitQ);
        xlim([0 nGaitQ+1])
        shg

        xstring={'1-24%', '25-49%', '50-74%', '75-100%'};

        hold on; plot(xlim , [0 0], 'k:');
        if normON==1
            ylim([-.05 .05])
        else
            axis tight
        end
        % add title:
        
        title(titlesare{iGplot});
        yl=get(gca, 'ylim');
        yp = yl(1) + (yl(2)-yl(1))*.9;
        %         text(0, yp, num2str(statsOUT.pvalsummary));
        text(3, .04, psare{iGplot}, 'HorizontalAlignment','center','fontsize',25)


        set(gca,'fontsize',fntsize,'Xtick', 1:5)
        xlabel('Step-cycle quintile')
        if iGplot==1
            ylabel({['Proportion "same" responses '];['(normalised)']})
        else
            ylabel('')
        end
        % add patches:

    end % iSpeed.


end% iGplot