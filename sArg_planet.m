%Scaling found by concatenating all argStats and setting 1-99th percentile
%of nonzero values
%median of all MADs ~0.09 for K2 so 'apples-to-apples' is to set threshold
%on residuals to 18
clearvars
close all
minScale = -20;
maxScale = 80;
load argStruct_C00-C19_planetGaps.mat
fitOrder = 2;
medianFilterLength = 25;
nQs = length(argStruct);
figure('Position',[-1800 100 1800 800])
for qIn = 1:nQs;
    c = argStruct(qIn).c;
    channelList = [1:4 13:84];
    nCad = length(argStruct(qIn).cadenceNos);
    RCI = (1:nCad)';
    argStruct(qIn).residuals = zeros(nCad,84)
    argStruct(qIn).medianAbsoluteDeviation = zeros(84,1)
    argStruct(qIn).argaStats = zeros(nCad,84);
    for iChan = 1:84
        isBigArg =  argStruct(qIn).isArgHere(:,iChan);
        isZeroData = argStruct(qIn).medianCalFlux(:,iChan) < 1;
        planetGap = argStruct(qIn).planetGapIndicators;
        goodIndices = ~isBigArg & ~isZeroData & ~planetGap;
        badIndices =  isBigArg | isZeroData | planetGap;
        RCIgood = RCI(goodIndices);
        if length(RCIgood) > 4
            flux = argStruct(qIn).medianCalFlux(:,iChan);
            fluxGood = argStruct(qIn).medianCalFlux(goodIndices,iChan);
            p = polyfit(RCIgood, fluxGood, fitOrder);
            depoly = flux - polyval(p,RCI);
            depoly(badIndices) = 0;
            residuals = depoly - medfilt1(depoly, medianFilterLength);
            residuals(badIndices) = 0;
            medianAbsoluteDeviation = mad(residuals(goodIndices), 1);
            argStruct(qIn).residuals(:,iChan) = residuals;
            argStruct(qIn).medianAbsoluteDeviation(iChan) = medianAbsoluteDeviation;
            argStruct(qIn).argaStats(:,iChan) = (residuals - median(residuals)) / medianAbsoluteDeviation;
        end
    end
    %     histogram(argStruct(qIn).argaStats,1.2.^(0:30))
    %     set(gca,'XScale','log')
    %     set(gca,'YScale','log')
    %     set(gca,'FontSize',14)
    %     grid
    %     xlabel('ArgStat')
    %     title(['K2 C' sprintf('%02.0f',c) ' Single-Channel ArgStat Histogram'],'FontSize',14)
    %     hold on
    %     plot([100 100],[1 1e4],'m')
    %     saveas(gca,['K2_C' sprintf('%02.0f',c) '_ArgStatHistogram.png'])
    %     pause(1)
    subplot(4,5,qIn)
    baseCad = floor(argStruct(qIn).cadenceNos(1)/1000)*1000;
    %     medianResidual = median(argStruct(qIn).residuals(:,channelList),2);
    %     maxResidual = max(argStruct(qIn).residuals(:,channelList),[],2);
    %     plot(argStruct(qIn).cadenceNos-baseCad,medianResidual,'b'),grid
    %     hold on
    %     plot(argStruct(qIn).cadenceNos-baseCad,maxResidual,'r')
    %     plot(argStruct(qIn).cadenceNos-baseCad,argStruct(qIn).residuals)
    plot(argStruct(qIn).cadenceNos-baseCad,argStruct(qIn).argaStats)
    grid
    s = axis;
    axis([0 5000 minScale maxScale])
    title(['K2 C' sprintf('%02.0f',c)],'FontSize',14)
    xlabel(['CadNo-' sprintf('%5.0f',baseCad)])
    ylabel('ArgStat')
end
saveas(gca,'K2_all_ArgStatsTimeSeries.png')
save('argStruct_C00-C19_planetGaps_argStat.mat','argStruct')