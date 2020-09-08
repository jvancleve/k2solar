%NAME: foo_ec_wrap
%PURPOSE: subplot of all K2 campaign FOVs in 
%  Differential HelioEcliptic Longitude at Mean Date of Observation
%USAGE:
% -run as script
%CALLED BY: NONE
%CALLS: 
% -foo_ec.m
%INPUTS
% -list of campaigns to be displayed with standard numerical codes for
% split campaigns
%OUTPUTS
% -figure
%NOTES
%TO-DO list
%REVISION HISTORY:
%Engineer          Org            Date        Description
%J. Van Cleve  Ball Aerospace  9/08/2020  Validate, comment, clean up for github
clearvars
close all
dataDir = '/Volumes/My Passport for Mac/solarSystem/zody';
cd(dataDir)
load foo.mat
load sunEcLonMean.mat
c = [0:8 91 92 101 102 111 112 12:19];
nC = length(c);
close all, figure('Position',[-2000 1 1500 1000])
prodIn = ver;
if (str2num(prodIn(1).Version) > 9.3)
    sgtitle('K2 FOV Differential HelioEcliptic Longitude at Mean Date of Observation','FontSize',14)
end
for i = 1:nC,subplot(4,6,i),foo_ec(c(i),footbl,1),end
saveas(gca,fullfile(dataDir, 'k2_apparent_solar_ecl_long.png'))


