%NAME: range_to_planet_lookup
%PURPOSE: find cadences possibly polluted by planets
%USAGE:
%CALLED BY:  add_planet_gap.m
%CALLS:  None
%INPUTS:
% -Horizons K2-o-centric ephemeris files [planet name]_k20c_eph.txt with no
%  header and these fields:
%  JD RA DEC apparentMag surfaceBright(mag/arcsec^2)
% -argStruct output from 
%OUTPUTS
% -argStruct with planet gaps appended
%NOTES
%TO-DO list
%REVISION HISTORY:
%Engineer          Org            Date        Description
%J. Van Cleve   Ball Aerospace  09/14/2020    Tidied up for github
function [range, gapIndicators, startPlanetEvent, endPlanetEvent, planet] = range_to_planet_lookup(argStruct, angleThreshold)
%range_to_planet(ra0, dec0, ephTimes, ephRa, ephDec, cadTimes)
dataDir =   '/Volumes/My Passport for Mac/solarSystem/zody';
ephDir =  [dataDir '/ephemeris'];
c = argStruct.c;
campaigns = [0 2 3 8 112 12 16 19];
planets = {'jupiter','mars','neptune','uranus','saturn','mars','earth','neptune'};
planet = char(planets(campaigns == c));
if ~length(planet)
    %search for jupiter if nothing else obvious
    planet = 'jupiter';
end
load(fullfile(dataDir,'timeConcordance.mat'));
ra0 = timeConcordance.RA(timeConcordance.Campaign == c);
dec0 = timeConcordance.DEC(timeConcordance.Campaign == c);
cadTimes = argStruct.midTimes;
ephName = fullfile(ephDir,[planet '_k2oc_eph.txt']);
eph = dlmread(ephName);
%convert to MJD
ephTimes = eph(:,1) - 2400000.5;
ephRa = eph(:,2);
ephDec = eph(:,3);
%trim eph times
inC = (ephTimes > (cadTimes(1) - 0.5)) & (ephTimes < (cadTimes(end) + 0.5));
ephTimesTrim = ephTimes(inC);
raTrim = ephRa(inC);
decTrim = ephDec(inC);
planetRaAtCad = interp1(ephTimesTrim, raTrim, cadTimes);
planetDecAtCad = interp1(ephTimesTrim, decTrim, cadTimes);
l1 = deg2rad(ra0);
l2 = deg2rad(planetRaAtCad);
phi1 = deg2rad(dec0);
phi2 = deg2rad(planetDecAtCad);
range = rad2deg(acos(sin(phi1).*sin(phi2) + cos(phi1).*cos(phi2).*cos(l2 - l1)));
gapIndicators = (range < angleThreshold) | (cadTimes < 1);
nCad = length(gapIndicators); %total number of cadences
%cluster args
firstDifference = diff(gapIndicators);
startPlanetEvent = find( firstDifference > 0 ) + 1;
if gapIndicators(1)
    planetAtStart = 1;
    startPlanetEvent = [1; startPlanetEvent];
end
endPlanetEvent = find( firstDifference < 0 );
if gapIndicators(end)
    planetAtEnd = 1;
    endPlanetEvent = [endPlanetEvent; nCad];
end
figure('Position',[-2000 100 1200 800])
subplot(2,1,1)
plot(argStruct.zeroCoeff)
grid
hold on
plot(gapIndicators*angleThreshold*100,'m')
plot(range*100,'g')
s = axis;
axis([s(1) s(2) 0 2000])
title(['Planet ' planet ' exclusion for ' sprintf('%02.f',c)],'FontSize',16)
ylabel('Zero Coeff')
xlabel('Relative Cadence Index')
subplot(2,1,2)
plot(argStruct.medianCalFlux)
grid
axis([s(1) s(2) 0 2000])
xlabel('Relative Cadence Index')
ylabel('Median Cal Flux')
end