%% PLOT MS figure 3
% (comparison of Reaction Times across SOAs, both walk speeds).


% set up figure.
cd(savedatadir);
load('GFX_SOAdata.mat', 'GFX_Data_SOAs');

clf
set(gcf,'color','w','units','normalized','position',[.1 .1 .8 .8]);

ordert = {'first', 'second'};

for iRT=1:2 % from first and second stimulus.
    plotData= {GFX_Data_SOAs.(['rt' num2str(iRT) '_slow']),...
        GFX_Data_SOAs.(['rt' num2str(iRT) '_fast']), ...
        GFX_Data_SOAs.(['rt' num2str(iRT) '_all'])}; %

    for iplot = 1:2 % slow fast
        pltd= plotData{iplot};
        [~,pltd2]= CousineauSEM(pltd);


        subplot(2,3,iRT);

        hold on;

        
        jits= [-.01, .01]; % offset to show separate speeds:

        %plot individual data points first
        for iSOA=1:length(SOAs)

            sc=scatter(repmat(SOAs(iSOA),1,size(pltd2,1)) + jits(iplot), pltd2(:,iSOA)');
            sc.MarkerFaceColor = useCols{iplot};
            sc.MarkerFaceAlpha =.1;
            sc.MarkerEdgeColor= [.8 .8 .8];
        end


        % add mean and errorbars.
        pM= squeeze(mean(pltd,1));
        legh(iplot)=plot(SOAs, pM, 'o:', 'color', useCols{iplot}, ...
            'MarkerFaceColor', useCols{iplot}, 'MarkerSize',2,...
            'LineWidth',2);
        hold on;
        stE= CousineauSEM(pltd);
        errorbar(SOAs, pM, stE, 'Color', useCols{iplot}, 'Linestyle', 'none', 'LineWidth',2);
    end

    % add extra elements:
    plot([0,0], ylim, 'k:');
    if iRT==1
        text(-.4, .475, 'auditory leading', 'HorizontalAlignment','left');
        text(.4, .475, 'visual leading','HorizontalAlignment','right');
    else
        text(-.4, .225, 'auditory leading', 'HorizontalAlignment','left');
        text(.4, .225, 'visual leading','HorizontalAlignment','right');
    end
    %%
    %tidy axes:
    box off
    axis tight;
    xlim([-.45 .45]);
    
    ylabel(['RT from ' ordert{iRT} ' stimulus (sec)'])
    xlabel('visual to auditory asynchrony')
    set(gca,'fontsize',fntsize);

    % in place of legend, just have coloured text:
    if iRT==1
        text(0, .85, 'walking slowly', 'color', 'b', 'FontWeight','bold', 'Fontsize',fntsize, 'HorizontalAlignment','center')
        text(0, .825, 'walking naturally', 'color', 'r', 'FontWeight','bold', 'Fontsize', fntsize, 'HorizontalAlignment','center')
    end
    ysat = get(gca, 'ylim');
    set(gca,'fontsize',12);

    % now plot the average for auditory leading and vis leading.
    testINDEX= {1:3, 5:7}; %excludes central SOA.
    tsare= {'auditory', 'visual'};
    xlocs= [.8,1.2; ...
        1.8 2.2];
    % skip if not irt1
    if iRT==1
        continue
    end

    %% if second RT, produce summary bar chart.
    for iind= 1:2
        %%
        useindx = testINDEX{iind};
        slowD = squeeze(mean(plotData{1}(:,useindx),2));
        fastD=  squeeze(mean(plotData{2}(:,useindx),2));
        barD = [slowD, fastD];
        nsubs = size(slowD,1);
        
        subplot(2,3,3)
        bh=bar(xlocs(iind,:), mean(barD));
        bh.FaceColor='flat';
        bh.CData(1,:) = [0 0 1];
        bh.CData(2,:) = [1 0 0];
        bh.FaceAlpha=.2;

        hold on;
        stE = CousineauSEM(barD);
        errorbar(xlocs(iind,:), mean(barD), std(barD)./sqrt(nsubs), 'color','k','linestyle', 'none','linew',2);
        ylim(ysat)


        % add scatter and connect the dots:
        sc=scatter(repmat(xlocs(iind,1), [1,size(barD,1)]), slowD,12);
        sc.MarkerEdgeColor= 'b';
        sc.SizeData= 40;
        hold on;
        sc=scatter(repmat(xlocs(iind,2), [1,size(barD,1)]), fastD,12);
        sc.MarkerEdgeColor= 'r';
        sc.SizeData= 40;

        % connect the dots:
        plot(xlocs(iind,:), barD, '-', 'color', [.7 .7 .7]);

        % t test results:
        [h,pval,ci,stats] = ttest(barD(:,1), barD(:,2));

        
        txtmsg = ['\itp \rm = ' sprintf('%.3f', pval) ];
        d= computeCohen_d(barD(:,1), barD(:,2), 'paired');
        disp(txtmsg)
        disp(['Cohens D = ' num2str(d)]);

        ylim([.2 .8]);
        ysat=get(gca,'ylim');
        ysigat = ysat(1) + diff(ysat)*.85;
        %%
        % text(mean(xlocs(iind,:)),ysigat, txtmsg, 'HorizontalAlignment','center');
        % or add summary:

        if iind==1
            pval=.05; % ns after bonferonni correction in JASP.
        end


        if pval <.001
            psum='***'; fntsizep= fntsize+10;
            valign='middle';
        elseif  pval < .01
            psum= '**';fntsizep= fntsize+10;
            valign='middle';
        elseif pval < .05
            psum = '*';fntsizep= fntsize+10;
            valign='middle';
        elseif pval >=.05
            psum= 'ns';fntsizep= fntsize;
            valign='bottom';
        end


        text(mean(xlocs(iind,:)), ysigat, psum, 'HorizontalAlignment','center', 'VerticalAlignment', valign, 'fontsize', fntsizep);
        %add connections.
        plot([xlocs(iind,1),xlocs(iind,2)], [ysigat, ysigat], 'k-');

        %%

        set(gca,'fontsize',12);
        set(gca,'Xtick', sort(xlocs(:)),'XTickLabel', {'slow', 'normal'})
        xlabel('walk speed')

    end
    box off;
    ylabel(['RT from ' ordert{iRT} ' stimulus (sec)'])
    text(1, ysat(2), 'auditory leading', 'HorizontalAlignment','center', 'VerticalAlignment','bottom');
    text(2, ysat(2), 'visual leading', 'HorizontalAlignment','center', 'VerticalAlignment','bottom');
    plot([1.5 1.5], ylim, 'k:')
end % both RTs
%%
cd(figdir);
exportgraphics(gcf, 'MS_figure3.pdf')

%% export for rm ANOVA (in Jasp?).
outtab= table();
tsides = {'LHS', 'RHS'};
for iind=1:2
    useindx = testINDEX{iind};
    slowD = squeeze(mean(plotData{1}(:,useindx),2));
    fastD=  squeeze(mean(plotData{2}(:,useindx),2));
    barD = [slowD, fastD];

    outtab.([tsides{iind} '_slow']) = slowD;
    outtab.([tsides{iind} '_fast']) = fastD;
end

%%
writetable(outtab, 'RTfromstim2.csv'); % this is condensed per side.

%% another for all SOAs (interaction ?)
outtab= table();

for iSOA=1:7

    slowD = plotData{1}(:,iSOA);
    fastD=  plotData{2}(:,iSOA);


    outtab.(['SOA_' num2str(iSOA) '_slow']) = slowD;
    outtab.(['SOA_' num2str(iSOA) '_fast']) = fastD;
end

%%

writetable(outtab, 'RTfromstim2_allSOA.csv'); % this is condensed per side.
