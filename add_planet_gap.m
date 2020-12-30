%NAME:  add_planet_gap.m
%PURPOSE:  wrapper to add planet gaps to argStructs for all campaigns
%USAGE:  run as script
%CALLED BY:  None
%CALLS:  range_to_planet_lookup
%INPUTS: angleThreshold
%OUTPUTS:  argStructs with planet gaps
%NOTES:  Kepler FOV is has optical radius of 8.05 deg (KIH)
%TO-DO list
%REVISION HISTORY:
%Engineer          Org     Date        Description
%J. Van Cleve   Ball Aerospace  09/14/2020    Tidied up for github
dataDir = '/Volumes/My Passport for Mac/solarSystemArch/zody';
cd(dataDir)
load(fullfile(dataDir,'argStruct_C00-C19.mat'))
angleThreshold = 9.0;%degrees
for i = 1:20
    close all
    [range, gapIndicators, startPlanetEvent, endPlanetEvent, planet] = ...
        range_to_planet_lookup(argStruct(i), angleThreshold);
    argStruct(i).planet = planet;
    argStruct(i).planetGapIndicators = gapIndicators;
    if min(range) < angleThreshold
        saveas(gca,[sprintf('C%02.0f',argStruct(i).c) '_zeroOrder_' planet '.png'])
        saveas(gca,[sprintf('C%02.0f',argStruct(i).c) '_zeroOrder_' planet '.fig'])
    end
end
save(fullfile(dataDir,'argStruct_C00-C19_planetGaps.mat'))