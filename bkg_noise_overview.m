%NAME:
%CODE TYPE
%WORK FLOW
%PURPOSE:
%USAGE:
% load argStruct_C00-C19_planetGaps.mat into workspace
%CALLED BY:
%CALLS
%INPUTS
% argStruct element of struct array:
%   struct with fields:
% 
%                       c: 0
%              cadenceNos: [3753×1 double]
%                midTimes: [3753×1 double]
%               zeroCoeff: [3753×84 double]
%           medianCalFlux: [3753×84 double]
%               isArgHere: [3753×84 double]
%            allChGoodCad: [3753×1 logical]
%                  planet: 'jupiter'
%     planetGapIndicators: [3753×1 logical]
% 
% argStruct for campaign from argStruct array
%OUTPUTS
%NOTES
%TO-DO list
%REVISION HISTORY:
%Engineer          Org     Date        Description% INPUT
function [r, availRefCad, noise] = bkg_noise_overview(argStruct,prc,debug)
normNoise = robust_std(randn(1000,1),prc);
numArgs = sum(argStruct.isArgHere,2);
nCad = length(numArgs);
rci = 1:nCad;
argIndicators = (numArgs > 3) & ~argStruct.planetGapIndicators;
availRefCad = find(argStruct.allChGoodCad & ~argIndicators & ~argStruct.planetGapIndicators);
if length(availRefCad)
    scale = median(argStruct.cadenceNos)
    maxChan = 84;
    if debug, maxChan = 4;end
    r = zeros(length(availRefCad),maxChan);
    noise = zeros(maxChan,1);
    for iChan = 1:maxChan
        [p, S, mu] = polyfit(argStruct.cadenceNos(availRefCad),argStruct.medianCalFlux(availRefCad,iChan),4);
        fit = polyval(p,argStruct.cadenceNos(availRefCad),S,mu);
        r(:,iChan) = argStruct.medianCalFlux(availRefCad,iChan) - fit;
        if debug
            plot(argStruct.cadenceNos(availRefCad),argStruct.medianCalFlux(availRefCad,iChan))
            grid
            hold on
            plot(argStruct.cadenceNos(availRefCad),fit,'g')
            plot(argStruct.cadenceNos(availRefCad),r(:,iChan),'r')
            title(sprintf('C%02.f Ch %02.f',argStruct.c,iChan))
            legend('data','fit','residual')
            pause(1)
        end
        noise(iChan) = robust_std(r(:,iChan),prc)/normNoise;
    end
    if debug
        figure('Position',[-2000 100 1200 400])
        rca = rci(availRefCad);
        plot(rca,r)
        title(sprintf('C%02.f bkg residuals to 4th order poly',argStruct.c))
        axis([0 4500 -15 15])
        grid
    end
else
    fprintf('No good cadences for C%02.f\n',argStruct.c)
    r = 0;
    noise = 0;
end