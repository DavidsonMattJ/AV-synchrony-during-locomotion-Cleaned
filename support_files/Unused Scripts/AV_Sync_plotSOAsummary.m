%

%for loop. per particpant. load data
% plot their data


figdir= '/MATLAB Drive/AV Synchrony Exp/Figures';
cd('/MATLAB Drive/AV Synchrony Exp/Processed_Data')
datadir=pwd;
allsummaryfiles = dir([pwd filesep '*SOA_summary.mat']);

for ippant = 1:length(allsummaryfiles)
% for ippant = 1:5

    cd(datadir);
    pfile = allsummaryfiles(ippant).name;
    load(pfile);

    %%
figure(ippant); clf

subplot(1,2,1)
plot(SOAs, propSame_all, 'ko-')
title(['Overall - ', subjID]);
set(gca,'fontsize',10, 'xtick', SOAs);
xlabel('Visual to Auditory SOA')
ylabel('P(Same)')
subplot(1,2,2);
plot(SOAs,propSame_slow, 'bo-')
titletext = sprintf('Prop. "Same" Responses\nby Walk Speed - %s', subjID);
title(titletext);
hold on;
plot(SOAs,propSame_fast', 'ro-');
xlabel('Visual to Auditory SOA')
ylabel('P(Same)')
set(gca,'fontsize',10, 'xtick', SOAs);
legend('slow', 'fast')
%%

cd(figdir);
print([subjID '_SOA_summary'], '-dpng');

end