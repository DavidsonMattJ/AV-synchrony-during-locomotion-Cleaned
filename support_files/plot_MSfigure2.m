%plot_MSfigure2

%Script to plot the second manuscript figure
% (gaussian fits to proportion same at both speeds).

%called from :


%UTS directory
cd(savedatadir)
load('GFX_GaussData.mat')
%set up input Data:
plotData= {  GFX_Data_SOAs.propSame_all, GFX_Data_SOAs.propSame_slow, GFX_Data_SOAs.propSame_fast,GFX_Data_SOAs.propSame_fast_perm,};
walkingCond= {'walking (all)', 'walking slowly', 'walking naturally',  'walking naturally (downsampled)'};

%  set up figure
clf
set(gcf,'color','w','units','normalized','position',[.1 .1 .8 .8]);
fntsize= 12;
useCols={'b', 'r', 'k', 'k'};

SOAs=[-.32, -.14, -.05, .04, .13,.22,.4];

%% UPDATED TO ACCOMODATE REVIEWER COMMENTS.
% can now plot slow vs natural pace (as in MS), or
% plot slow vs natural pace (trials downsampled).
% to toggle between, select/deselect:

dataindex= [2,3]; % for MS version (slow vs natural)
% dataindex= [2,4]; % for downsampled version. (slow vs natural downsampled)

%% Panel 1
% plot proportion 'same' per SOA, group effects:


for iplot = 1:2

    pltd= plotData{dataindex(iplot)};

    [~,pltd2]= CousineauSEM(pltd); % adjusted for within participant comparisosn.

    subplot(221);
    hold on;

    % might be bit too messy for individual data poonts
    jits= [-.01, .01]; % offset to show separate speeds:

    %plot individual data points first
    for iSOA=1:length(SOAs)

        sc=scatter(repmat(SOAs(iSOA),1,size(pltd2,1)) + jits(iplot), pltd2(:,iSOA)');
        sc.MarkerFaceColor = useCols{iplot};
        sc.MarkerFaceAlpha =.1;
        sc.MarkerEdgeColor= [.8 .8 .8];
    end

    % now plot mean and errorbars:
    pM= squeeze(mean(pltd,1));
    plot(SOAs, pM, 'o:', 'color', useCols{iplot}, ...
        'MarkerFaceColor', useCols{iplot}, 'MarkerSize',2,...
        'LineWidth',2);
    stE= CousineauSEM(pltd);
    %add errorbar
    errorbar(SOAs, pM, stE, 'Color', useCols{iplot}, 'Linestyle', 'none', 'LineWidth',2);


    % in place of legend, just have coloured text:
    if iplot==1
        text(-.4, 1, walkingCond{dataindex(iplot)}, 'color', 'b', 'FontWeight','bold', 'Fontsize',fntsize)
    elseif iplot==2
        text(-.4, .925, walkingCond{dataindex(iplot)}, 'color', 'r', 'FontWeight','bold', 'Fontsize', fntsize)
    end

end % for both speeds.

% add extra elements:
plot([0,0], ylim, 'k:');
text(-.4, .1, 'auditory leading', 'HorizontalAlignment','left');
text(.4, .1, 'visual leading','HorizontalAlignment','right');


%tidy axes:
box off
xlim([-.45 .45]);
ylim([0 1]);
ylabel('proportion "Same" ')
xlabel('visual to auditory asynchrony')
set(gca,'fontsize',fntsize);



%% Panel 2
% average of (normalised) Gaussian fits.

subplot(2,2,2); cla

[nsubs,nconds, nsamps]= size(GFX_gauss_Cond_x_Yfit);
%switch colours
useCols_tmp = {'k', 'b', 'r', 'r'};
for icond= dataindex
    plotme = squeeze(GFX_gauss_Cond_x_Yfit(:,icond,:));
    hold on
    pM = mean(plotme,1);
    stE= CousineauSEM(plotme);
    
    plot(gauss_xvec, pM, '-','color', useCols_tmp{icond}, 'linew',2)
    % add SOA location.
    xS = dsearchn(gauss_xvec', SOAs');
    plot(gauss_xvec(xS), pM(xS), 'o', 'linew',2,'color',useCols_tmp{icond})

end

% add extra elements:
plot([0,0], ylim, 'k:');
text(-.4, .1, 'auditory leading', 'HorizontalAlignment','left');
text(.4, .1, 'visual leading','HorizontalAlignment','right');

%tidy axes:
xlim([-.45 .45]);
ylim([0 1]);
box off
ylabel({['proportion "Same"'];['(normalised)']});
xlabel('visual to auditory asynchrony')
title('Average of individual fits');
set(gca,'fontsize',fntsize);

%% panel 3 and panel 4
%  the gaussian parameters:

titlesAre = {'Mean (sec)', 'standard deviation (sec)', 'GoF'}; % GoF not shown in figure
ylimsat= [-.05 .25; 0 0.55 ; 0, 1];
usesubspots= [5,6];

for iparam=1:2 % mean, std

    paramData = squeeze(GFX_gauss_Cond_xparam(:, :,iparam)); %

    subplot(2,4, usesubspots(iparam)); cla

    barM = mean(paramData,1);
    stE = CousineauSEM(paramData);

    bh=bar(1:2, [barM(dataindex(1)), nan]); hold on; % speed 1
    bh.FaceColor= 'b';
    bh.FaceAlpha= .2;
    bh=bar(1:2, [nan, barM(dataindex(2))]); hold on; % speed 2
    bh.FaceColor= 'r';
    bh.FaceAlpha= .2;

    errorbar(1:2, barM([dataindex(1), dataindex(2)]), stE([dataindex(1), dataindex(2)]), 'LineWidth',2, 'Color','k', 'LineStyle','none');


    %include scatter of individual data points
    sc=scatter(ones([1,size(paramData,1)]), paramData(:,dataindex(1)),12);
    sc.MarkerEdgeColor= 'b';
    sc.SizeData=50;

    hold on;
    sc=scatter(repmat(2, [1,size(paramData,1)]), paramData(:,dataindex(2)),12);
    sc.MarkerEdgeColor= 'r';
    xlim([.5 2.5])
    xlabel('walk speed');
    set(gca,'XTickLabel', {walkingCond{dataindex(1)}, walkingCond{dataindex(2)}})
    sc.SizeData=50;


    % connect the dots?
    % for ippant = 1:size(paramData,1);
    plot([1,2], paramData(:,[dataindex(1),dataindex(2)]), '-', 'color', [.7 .7 .7]);

    %include t test results? Displayed in Command window:
    [h,pval, ci,stats]= ttest(paramData(:,dataindex(1)), paramData(:,dataindex(2))); % compare slow and fast speeds
    txtmsg = ['t(' num2str(stats.df) ')=' sprintf('%.2f',stats.tstat) ', p \rm = ' sprintf('%.3f', pval) ];
    
    d= computeCohen_d(paramData(:,dataindex(1)), paramData(:,dataindex(2)), 'paired');
    disp('>>>>>>')
    disp([titlesAre{iparam} ' of gaussian ttest'])
    disp(txtmsg)
    disp(['Cohens D = ' num2str(d)]);
    disp(['M(SD) = ' walkingCond{dataindex(1)} '= ' sprintf('%.2f',mean(paramData(:,dataindex(1)))) ...
        '(' sprintf('%.2f', std(paramData(:,dataindex(1)))) '), min-max = ' sprintf('%.2f',min(paramData(:,dataindex(1)))) '- ' sprintf('%.2f',max(paramData(:,dataindex(1))))  ]);
    disp(['M(SD) = ' walkingCond{dataindex(2)} '= ' sprintf('%.2f',mean(paramData(:,dataindex(2)))) ...
        '(' sprintf('%.2f', std(paramData(:,dataindex(2)))) '), min-max = ' sprintf('%.2f',min(paramData(:,dataindex(2)))) '- ' sprintf('%.2f',max(paramData(:,dataindex(1))))  ]);

    % adust height if plotting the mean parameter:
    ysigat = diff(ylimsat(iparam,:))*.85;
    if iparam==1
        ysigat= ysigat-abs(ylimsat(1,1));
    end

    %% add t test results to figure:
    
    if pval <.001
        psum='***'; fntsizep= fntsize+10;
        valign='middle';
    elseif  pval < .01
        psum= '**';fntsizep= fntsize+10;
        valign='middle';
    elseif pval < .05
        psum = '*';fntsizep= fntsize+10;
        valign='middle';
    elseif pval >.05
        psum= 'ns';fntsizep= fntsize;
        valign='bottom';
    end
    %%
    text(1.5, ysigat, psum, 'HorizontalAlignment','center', 'VerticalAlignment', valign,'fontsize', fntsizep);
    %add connections.
    plot([1,2], [ysigat, ysigat], 'k-');
    %%

    %tidy axes:
    ylim(ylimsat(iparam,:))
    ylabel(titlesAre{iparam});
    title(['Gaussian ' titlesAre{iparam}]);
    set(gca,'fontsize', fntsize)
    
end

%% Panel 5
% add the LHS vs RHS data. (auditory leading, visual leading).
cd(savedatadir);
load('GFX_asymGaussData.mat','GFX_asymgauss_Cond_xparam');
subplot(2,2,4); cla

%%% need to do a bit of wrangling, as we have 2x2 in this bar plot.
xlocs= [.8,1.2; ...
    1.8 2.2];
cla
titlesAre= {'LHS', 'RHS'};

for  iLHS=1:2 % LHS and RHS
    paramData = squeeze(GFX_asymgauss_Cond_xparam(:, :,iLHS+1)); % all  walk speeds (2nd dim), params (mu, sigmaLeft,sigmaRight; 3rd dim).
    paramData= paramData./1000;
    barM = mean(paramData,1);

    % bar first:
    stE = CousineauSEM(paramData);

    
    bh=bar(xlocs(iLHS,:), [barM(dataindex(1)), nan]); hold on; % 'slow'
    bh.FaceColor= 'b';
    bh.FaceAlpha= .2;
    bh=bar(xlocs(iLHS,:), [nan, barM(dataindex(2))]); hold on; % 'normal'
    bh.FaceColor= 'r';
    bh.FaceAlpha = .2;


    errorbar(xlocs(iLHS,:), barM([dataindex(1),dataindex(2)]), stE([dataindex(1), dataindex(2)]), 'LineWidth',2, 'Color','k', 'LineStyle','none');
    % add scatter and connect the dots:
    sc=scatter(repmat(xlocs(iLHS,1), [1,size(paramData,1)]), paramData(:,dataindex(1)),12);
    sc.MarkerEdgeColor= 'b';
    sc.SizeData= 50;
    hold on;
    sc=scatter(repmat(xlocs(iLHS,2), [1,size(paramData,1)]), paramData(:,dataindex(2)),12);
    sc.MarkerEdgeColor= 'r';
    sc.SizeData= 50;

    % connect the dots:
    plot(xlocs(iLHS,:), paramData(:,[dataindex(1),dataindex(2)]), '-', 'color', [.7 .7 .7]);

    %% t test results?
    [h,pval, ci,stats]= ttest(paramData(:,dataindex(1)), paramData(:,dataindex(2))); % compare slow and fast speeds

    txtmsg = ['t(' num2str(stats.df) ')=' sprintf('%.2f',stats.tstat) ', p = ' sprintf('%.3f', pval) ];
    ylim([0 .8])
    ysigat = diff([0 .8])*.85; % check [0 .7] matches below

    %% add t test results:

    
    if pval <.001
        psum='***'; fntsizep= fntsize+10;
        valign='middle';
    elseif  pval < .01
        psum= '**';fntsizep= fntsize+10;
        valign='middle';
    elseif pval < .05
        psum = '*';fntsizep= fntsize+10;
        valign='middle';
    elseif pval >.05
        psum= 'ns';fntsizep= fntsize;
        valign='bottom';
    end%

    text(mean(xlocs(iLHS,:)), ysigat, psum, 'HorizontalAlignment','center', 'VerticalAlignment', valign, 'fontsize', fntsizep);
    %add connections.
    plot([xlocs(iLHS,1),xlocs(iLHS,2)], [ysigat, ysigat], 'k-');

    %
    d= computeCohen_d(paramData(:,dataindex(1)), paramData(:,dataindex(2)), 'paired');
    disp('<><>')
    disp([titlesAre{iLHS} ' of gaussian ttest'])
    disp(txtmsg)
    disp(['Cohens D = ' num2str(d)]);

    % tidy axes:
    title('Asymmetric standard deviation (sec)');
    xlabel('walk speed');
    ylabel('standard deviation (sec)')
    set(gca,'XTickLabel', {'slow', 'natural'}, 'XTick', sort(xlocs(:)),'fontsize', fntsize);

end %iLHS
text(1, .75, 'auditory leading (LHS)', 'HorizontalAlignment','center');
text(2, .75, 'visual leading (RHS)', 'HorizontalAlignment','center');
plot([1.5 1.5], ylim, 'k:')
xlim([.5 2.5]);
ylim([0 .8])
%%
cd(figdir)
exportgraphics(gcf, 'MS_figure2.pdf')

%%
%% export for rm ANOVA (in Jasp?).
outtab= table();
tsides = {'LHS', 'RHS'};
for  iparam=1:2 % LHS and RHS
    paramData = squeeze(GFX_asymgauss_Cond_xparam(:, :,iparam+1)); % all 3 walk speeds (2nd dim), params (mu, sigLeft,sigRight; 3rd dim).
    paramData= paramData./1000;
    slowD= paramData(:,2);
    fastD= paramData(:,3);
    fastpermD= paramData(:,4);


    outtab.([tsides{iparam} '_slow']) = slowD;
    outtab.([tsides{iparam} '_fast']) = fastD;
    outtab.([tsides{iparam} '_fast_perm']) = fastpermD;
end

%
writetable(outtab, 'PropSame_asymmetric.csv');
%%
% extra stats for paper/review
% tmpmat = table2array(outtab);
% LHSmean = mean(tmpmat(:,1:2),2);
% RHSmean = mean(tmpmat(:,3:4),2);
% [h,pval, ci,stats]= ttest(LHSmean, RHSmean); % compare slow and fast speeds
%
% txtmsg = ['\itt\rm(' num2str(stats.df) ')=' sprintf('%.2f',stats.tstat) ', \itp \rm = ' sprintf('%.3f', pval) ];
%
%
% d= computeCohen_d(LHSmean, RHSmean, 'paired');
% disp(['mean LHS=' num2str(mean(LHSmean)) ', SD=' num2str(std(LHSmean))])
% disp(['mean RHS=' num2str(mean(RHSmean)) ', SD=' num2str(std(RHSmean))])
% disp(txtmsg)
% disp(['Cohens D = ' num2str(d)]);

%% for peer review, also compare the Goodness of Fit statistics:
%Figure 2
figure(2);
clf;
for iparam=3 % mean, std, GoF of gaussian:

    paramData = squeeze(GFX_gauss_Cond_xparam(:, :,iparam)); %

    % subplot(2,4, usesubspots(iparam)); cla

    barM = mean(paramData,1);
    stE = CousineauSEM(paramData);

    bh=bar(1:2, [barM(dataindex(1)), nan]); hold on; % 'slow', (1) is 'all'
    bh.FaceColor= 'b';
    bh.FaceAlpha= .2;
    bh=bar(1:2, [nan, barM(dataindex(2))]); hold on; % 'normal'
    bh.FaceColor= 'r';
    bh.FaceAlpha= .2;

    errorbar(1:2, barM([dataindex(1), dataindex(2)]), stE([dataindex(1), dataindex(2)]), 'LineWidth',2, 'Color','k', 'LineStyle','none');


    %include scatter of individual data points
    sc=scatter(repmat(1, [1,size(paramData,1)]), paramData(:,dataindex(1)),12);
    sc.MarkerEdgeColor= 'b';
    sc.SizeData=50;

    hold on;
    sc=scatter(repmat(2, [1,size(paramData,1)]), paramData(:,dataindex(2)),12);
    sc.MarkerEdgeColor= 'r';
    xlim([.5 2.5])
    xlabel('walk speed');
    set(gca,'XTickLabel', {walkingCond{dataindex(1)}, walkingCond{dataindex(2)}})
    sc.SizeData=50;


    % connect the dots?
    % for ippant = 1:size(paramData,1);
    plot([1,2], paramData(:,[dataindex(1),dataindex(2)]), '-', 'color', [.7 .7 .7]);

    %include t test results? d
    [h,pval, ci,stats]= ttest(paramData(:,dataindex(1)), paramData(:,dataindex(2))); % compare slow and fast speeds
    txtmsg = ['t(' num2str(stats.df) ')=' sprintf('%.2f',stats.tstat) ', p = ' sprintf('%.3f', pval) ];
    d= computeCohen_d(paramData(:,dataindex(1)), paramData(:,dataindex(2)), 'paired');
    disp('>>')
    disp(['GoF of gaussian. ttest'])
    disp(txtmsg)
    disp(['Cohens D = ' num2str(d)]);

    disp(['M(SD) = ' walkingCond{dataindex(1)} '= ' sprintf('%.2f',mean(paramData(:,dataindex(1)))) ...
        '(' sprintf('%.2f', std(paramData(:,dataindex(1)))) '), min-max = ' sprintf('%.2f',min(paramData(:,dataindex(1)))) '- ' sprintf('%.2f',max(paramData(:,dataindex(1))))  ]);
    disp(['M(SD) = ' walkingCond{dataindex(2)} '= ' sprintf('%.2f',mean(paramData(:,dataindex(2)))) ...
        '(' sprintf('%.2f', std(paramData(:,dataindex(2)))) '), min-max = ' sprintf('%.2f',min(paramData(:,dataindex(2)))) '- ' sprintf('%.2f',max(paramData(:,dataindex(1))))  ]);

    % adust height if plotting the mean parameter:
    ysigat = diff(ylimsat(iparam,:))*.85;
    if iparam==1
        ysigat= ysigat-abs(ylimsat(1,1));
    end

    %% add t test resutls:
    % text(1.5, ysigat, txtmsg, 'HorizontalAlignment','center');

    % or add summary:
    if pval <.001
        psum='***'; fntsizep= fntsize+10;
        valign='middle';
    elseif  pval < .01
        psum= '**';fntsizep= fntsize+10;
        valign='middle';
    elseif pval < .05
        psum = '*';fntsizep= fntsize+10;
        valign='middle';
    elseif pval >.05
        psum= 'ns';fntsizep= fntsize;
        valign='bottom';
    end
    %
    text(1.5, ysigat, psum, 'HorizontalAlignment','center', 'VerticalAlignment', valign,'fontsize', fntsizep);
    %add connections.
    plot([1,2], [ysigat, ysigat], 'k-');
    %

    %tidy axes:
    ylim(ylimsat(iparam,:))
    ylabel('GoF R^2' );
    title(['Gaussian GoF']);
    set(gca,'fontsize', fntsize)
    % end
end