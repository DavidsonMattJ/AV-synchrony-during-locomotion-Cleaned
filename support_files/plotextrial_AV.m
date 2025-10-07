
function plotextrial_AV(cfg)
%%
homedir = '\Users\mdav0285\Documents\GitHub\AV-Synchrony-during-locomotion';
addpath(genpath([homedir filesep 'Analysis']));

rawdatadir=  [homedir filesep 'Raw_Data'];
savedatadir= [homedir filesep 'Processed_Data'];
figdir = [homedir filesep 'Figures'];
jobs=[];

cd(savedatadir);
%%
cd(savedatadir);
subjID= 'p_01';
itrial= 64;
clf
lfile  = dir([pwd filesep subjID '*']);
load(lfile.name)
fntsize= 12;

%
plot(HeadPos(itrial).times, HeadPos(itrial).Y, 'k', 'LineWidth',2);
% axis tight;
xlabel('Trial time (sec)');
ylabel('Head height (m)');
set(gca,'fontsize', fntsize);
% ylim([1.69 1.78])
%
% tOnsets = HeadPos(124).tr   
relT= find(summary_table.trial == itrial);
tOnsets = summary_table.stimSeqStartTime(relT);
tOrder= summary_table.stimOrderDesired(relT);
tSOAs= summary_table.SOA(relT);
hold on;
trialTimes = HeadPos(itrial).times;
 HeadData= HeadPos(itrial).Y;
txtHeight = min(HeadData)-.1;
stimLine = 1.48;
plot(xlim, [stimLine stimLine], 'k:')
msize = 10;
 for itarg = 1:length(tOnsets)
   
     pAt = dsearchn(trialTimes, tOnsets(itarg)');

if tOrder(itarg)==1% Aud-Vis.
    colOrder = {'r', 'b'};
else
    colOrder = {'b','r'};
end

    plot(tOnsets(itarg), HeadData(pAt), [colOrder{1} 'o'], 'linew',2,'MarkerFaceColor', 'none', 'MarkerSize', msize );
    
      time2 = tOnsets(itarg) + tSOAs(itarg);
      indx = dsearchn(trialTimes, time2);
    plot(time2, HeadData(indx), [colOrder{2} 'o'],'linew',2,'MarkerFaceColor', 'none','MarkerSize', msize );

 
% Plot on stim lineL
% plot the second one first:
plot(time2, stimLine, [colOrder{2} 'o'], 'linew',2, 'MarkerFaceColor','none', 'MarkerSize', msize );
plot(tOnsets(itarg),stimLine, [colOrder{1} 'o'], 'linew',2,'MarkerFaceColor','w', 'MarkerSize', msize );%colOrder{1});
plot([tOnsets(itarg) time2], [stimLine, stimLine], 'k-', 'linew',2)
 end
 

 %
%  legend([Vl,Al], {'Audio', 'Visual'})

ylim([1.47 1.54])
 text(0.1, 1.48, 'SOAs', 'HorizontalAlignment', 'left', 'fontsize', fntsize, 'BackgroundColor','w');
 
 text(0.1, 1.53, 'Visual', 'HorizontalAlignment', 'left', 'Color', 'b','fontsize', fntsize);
  text(1.5 , 1.53, 'Audio', 'HorizontalAlignment', 'left', 'Color', 'r','fontsize', fntsize);
 

end

