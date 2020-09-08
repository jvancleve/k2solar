%NAME:  fit_lsflat_by_channel
%PURPOSE: fit brightness metric
%USAGE:
%CALLED BY:
% -lsflat.m
%CALLS:
% -fovPlottingClass.plot_on_modout
%INPUTS
% -lsflat array:  kepmag, channel, flux in e-/s
%OUTPUTS
% -84 element array of fit evaluated at 12th mag = brightness metric
% -plots of brighntess metric and star counts
%NOTES
% -robust (2 step)linear fit of mag vs log(signal) in e-/s
%TO-DO list
%REVISION HISTORY:
%Engineer          Org           Date        Description
%J. Van Cleve  Ball Aerospace  9/8/2020   Validate, comment, clean up for github
function fit_lsflat_by_channel(dataDir, campaignString, lsflatOut)
close all
%Pre-flight radiometric model brightness meatric
Srmm = 2e5;%e-/s for 12th mag
S = zeros(84,1);
nStars =  zeros(84,1);
for ic = 1:84
    thisChan = find(lsflatOut(:,2) == ic);
    nStars(ic) = length(thisChan);
    if (length(thisChan) > 10)
        y = log10(lsflatOut(thisChan,3));
        x = lsflatOut(thisChan,1);
        p = polyfit(x,y,1);
        fit = polyval(p,x);
        r = y - fit;
        thresh = 2*mad(r,1);
        cleanPoints = find(abs(r) < thresh);
        y = y(cleanPoints);
        x = x(cleanPoints);
        p = polyfit(x,y,1);
        fit = polyval(p,x);
        S(ic) = 10^polyval(p,12);
    else
        S(ic) = NaN;
    end
    %debug plot for surviving outlier channels
    if (S(ic)/Srmm > 2)
        figure
        plot(x,y,'+')
        grid
        title(num2str(ic))
        hold on
        plot(x,fit,'m')
        pause
    end
end
[mods, outs] = convert_mod_out_to_from_channel(1:84);
fovPlottingClass.plot_on_modout(mods, outs, S);
title([campaignString ' S12 e-/s'])
saveas(gca,fullfile(dataDir,[campaignString '_brightnessMetric.png']));
fovPlottingClass.plot_on_modout(mods, outs, nStars);
title([campaignString ' nstars'])
saveas(gca,fullfile(dataDir,[campaignString '_numStars4brightnessMetric.png']));
save(fullfile(dataDir,[campaignString '_chflat.mat']),'S')
end