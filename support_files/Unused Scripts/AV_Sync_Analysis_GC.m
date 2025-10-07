
%change directory
%%
cd('C:\Users\mobil\Gabriel\Auditory Visual Syncrony - active-perception-Detection_v2-2wSpeedQuest\Analysis Code\Detecting ver 0\Raw_data')

% read table.
mytab = readtable('Edited GCfulltest_2022-11-24_trialsummary');

nAV320 = 2

Data = table2array( mytab(:, [9,14,15,16]));
AudLeadIdx = find(Data(:,3)==2);
Data(AudLeadIdx,2) = Data(AudLeadIdx,2) * -1;

statIdx = find( (Data(:,1)==0 ));
statDat = Data(statIdx,:);
slowIdx = find( (Data(:,1)==1 ));
slowDat = Data(slowIdx,:);
fastIdx = find( (Data(:,1)==2 ));
fastDat = Data(fastIdx,:);

SOAs = unique(Data(:,2));
nSOAs = length(SOAs);

for i = 1:nSOAs
    %per SOA find the relevant row index, and take average of those
    % data points
    %stationary data
   thisIdx = find(statDat(:,2)==SOAs(i));
   %take mean.
   statMeans(i) = abs(mean(statDat(thisIdx,4))-2);
 %slow data
   thisIdx = find(slowDat(:,2)==SOAs(i));
   slowMeans(i) = abs(mean(slowDat(thisIdx,4))-2);
   %fast data
   thisIdx = find(fastDat(:,2)==SOAs(i));
   fastMeans(i) = abs(mean(fastDat(thisIdx,4))-2);
end


figure
hold on
plot(SOAs,slowMeans,'b',SOAs,slowMeans,'bo')
plot(SOAs,fastMeans,'r',SOAs,fastMeans,'ro')