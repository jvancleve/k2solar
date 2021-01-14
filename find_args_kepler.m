%NAME: find_args
%PURPOSE: browse background pixels and polys
%USAGE:
% -edit debug flag and dataDir then run
%CALLED BY:
%CALLS
% -blkavg
%INPUTS
% -full Campaign set of ktwo background poly FITS files
%OUTPUTS
% argStruct =
%   1×20 struct array with fields:
%     c
%     cadenceNos
%     midTimes
%     zeroCoeff
%     medianCalFlux
%     isArgHere
%     allChGoodCad
%     planet
%NOTES
% -This takes about 20 min per campaign to run
% -Add planet gaps with add_planet_gap.m
%TO-DO list
%REVISION HISTORY:
%Engineer      Org            Date      Description
%J. Van Cleve  Ball Aerospace 06/11/20  Validated on C08
%                             09/10/20  Tidy up for github
%                             12/29/20  Kepler version, read campaign from
%                                        header
close all
clearvars
year = '2013'
outString = ['kepler_dev_' year];
startRun = now;
nQuartersThisRun = 2.5;
import matlab.io.*
debug = 0;
nChan = 84;
quarterDurationLc = 90*48.939;
dataDir =  ['/Volumes/My Passport for Mac/solarSystemArch/zody/kepler/bkg/' year];
%at most 5 quarters in a year
argStruct = repmat(struct('c',0,'cadenceNos',[],'midTimes',[],'zeroCoeff',[],'medianCalFlux',[],'isArgHere',[]),1,20);
cd(dataDir)
d = dir('kplr*.fits');
nFiles = length(d)
for iFiles = 1:nFiles
    startThisFile = now;
    fname = d(iFiles).name;
    fptr = fits.openFile(fname);
    fits.movAbsHDU(fptr,1);
    [key, ~] = fits.readKey(fptr,'QUARTER');
    quarter = int16(str2num(key));
    [key, ~] = fits.readKey(fptr,'CHANNEL');
    channel = int16(str2num(key));
    fits.closeFile(fptr);
    pixelData = fitsread(fname,'binarytable',1);
    calFlux = pixelData{5};
    bkgCoeff = pixelData{7};
    qualityFlags = pixelData{10};
    %force 21 bits and make LSB column 1 in output character array
    qFlagBin = fliplr(dec2bin(qualityFlags,21));
    [nCad, nCoeff] = size(bkgCoeff);
    if (channel == 1)
        argStruct(quarter + 1).midTimes = pixelData{1};
        argStruct(quarter + 1).cadenceNos = pixelData{3};
        argStruct(quarter + 1).c = quarter;
    end
    qualityFlags = pixelData{10};
    %force 21 bits and make LSB column 1 in output character array
    qFlagBin = fliplr(dec2bin(qualityFlags,21));
    argStruct(quarter+1).isArgHere(:,channel) = str2num(qFlagBin(:,13));
    argStruct(quarter+1).medianCalFlux(:,channel) = median(calFlux,2);
    argStruct(quarter+1).zeroCoeff(:,channel) = bkgCoeff(:,1);
    timeThisFile = (now - startThisFile);
    fprintf([fname ' processing time hh:MM:ss ' datestr(timeThisFile,'hh:MM:ss') '\n'])
    timeToNow = now - startRun;
    timeToFinish = (nFiles/iFiles)*timeToNow;
    timeAtFinish = startRun + timeToFinish;
    fprintf(['Estimated time at completion ',datestr(timeAtFinish,'mm/dd hh:MM') '\n'])
 end
if debug
    save(['argStruct_' outString '_debug.mat'],'argStruct')
else
    save(['argStruct_' outString '.mat'],'argStruct')
end
load gong.mat
sound(y)