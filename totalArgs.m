%show all args not planetgapped
close all
clearvars
debug = 1;
channelArgThreshold = 15;
fovArgThreshold = 10;
missionId = 2; %Kepler = 1, K2 = 2
cadPerQuarter = 90*48.93;
if (missionId == 1)
    dataDir =  '/Volumes/My Passport for Mac/solarSystemArch/zody/kepler/argStats';
    missionString = 'Kepler';
    cd(dataDir)
    load kepler_argStruct_all.mat
    nC = length(argStruct);
    campaignIndices = [1:12 14:18];
else
    dataDir =  '/Volumes/My Passport for Mac/solarSystemArch/zody/argStats';
    campaignIndices = [2 4:7 9 13:20];
    missionString = 'K2';
    cd(dataDir)
    load argStruct_C00-C19_planetGaps_argStat.mat
end

%standard numerical labels for campaigns
for iC = campaignIndices
    as = argStruct(iC);
    if (missionId == 2)      
        isArgFov = (sum(as.argaStats > channelArgThreshold,2).*~as.planetGapIndicators) > fovArgThreshold;
        numGoodCad = sum(~as.planetGapIndicators);
    else
        isArgFov = sum(as.argaStats > channelArgThreshold,2) > fovArgThreshold;
        numGoodCad = length(argStruct(iC).midTimes);
    end
    numArgFovs = sum(isArgFov);
    if numGoodCad >2
        argFovPerQ = numArgFovs*cadPerQuarter/numGoodCad;
        fprintf('%03.0f %3.0f %5.2f\n',as.c, numArgFovs, argFovPerQ)
    end
end
allArg = vertcat(argStruct(campaignIndices).argaStats);
allArgNoZero = allArg(allArg ~= 0);
histogram(allArgNoZero,-20.5:2:98.5),grid,set(gca,'YScale','log')
title(['Setting Arga Stat Threshold for ' missionString ],'FontSize',12)
set(gca,'FontSize',14)
xlabel('ArgStat')
hold on
plot(channelArgThreshold*[1 1],[10 1e5],'m')