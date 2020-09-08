%NAME: foo_ec.m.  
%PURPOSE: plot channels for a given campaign in kepler-o-centric ecliptic coords
%USAGE:
%CALLED BY:
% -foo_ec_wrap.m
%CALLS:
% -eq_to_ecl
%INPUTS
% -c = campaign number with numerical convention for split campaigns.
% -foottbl = 1556x12 array imported from k2_footprint.txt with these columns
% -dSun = 1 to subtract k-o-c pos'n of Sun
% -apparent solar ecliptic longitude table with columns campaign vs
%  apparent kepler-o-centric ecliptic longitude of Sun
%  The numeric campaign labels are:
%  Columns 1 through 15
%      0     1     2     3     4     5     6     7     8    91    92   101   102   111   112
%   Columns 16 through 23
%     12    13    14    15    16    17    18    19
%campaign,start,stop,channel,module,output,ra0,dec0,ra1,dec1,ra2,dec2,ra3,dec3
%OUTPUTS
% -if not dSun then ecliptic lon/lat plot
% -if dSun then Differential HelioEcliptic Longitude at Mean Date of Observation'
%NOTES
%foo is from 'footprint' of FOV
%kludge for C9 time
%TO-DO list
%REVISION HISTORY:
%Engineer            Org        Date       Description
%J. Van Cleve   Ball Aerospace  6/24/2020  Created
%                                          Subtract kepler-o-centric pos'n
%                                          of sun option
%                               9/08/2020  Validate, comment, clean up for github
function foo_ec(c,footbl,dSun)

if (c > 90)
    cUnsplit = floor(c/10)
else
    cUnsplit = c
end

plusVV = [9, 16, 17, 19];
vvFactor = 1;
vvString = '-';
if ismember(cUnsplit,plusVV)
    vvString = '+';
end

thisC = find(footbl(:,1) == cUnsplit);
sunEcl = 0;
xstring = 'EcLon';
if dSun
   load('/Volumes/My Passport for Mac/solarSystem/zody/sunEclonMean.mat')
   sunEcl = sunEcLonMean(find(sunEcLonMean(:,1) == c),2);
   xstring = 'EcLon - Sun';
end
nChan = length(thisC);
for iChan = 1:nChan
    [ecLat, ecLon] = eq_to_ecl(footbl(thisC(iChan),[5:2:11 5]),footbl(thisC(iChan),[6:2:12 6]));
    relEcLon = ecLon-sunEcl;
    relEcLon(relEcLon < 0) = 360 + relEcLon(relEcLon < 0);
    plot(relEcLon,ecLat), axis xy, axis equal, grid on, set(gca,'Xdir','reverse')
    if (iChan == 1); hold on; end
end
title(sprintf(['C%02.0f VV' vvString],c),'FontSize',14)
xlabel(xstring)
ylabel('EcLat')

end