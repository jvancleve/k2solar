%NAME: lsflat.m
%PURPOSE: calculate large-scale flat for K2
%USAGE:
% -change data path name and run as script
%CALLED BY: NONE
%CALLS
% -fit_lsflat_by_channel.m
%INPUTS
% -Archive long-cadence light curve (lls) FITS files for stars around 12th mag 
%  from a single campaign.  Field 8 of the binary table is the calibrated
%  flux PDCSAP_FLUX
%OUTPUTS
% -lsflat array with columns kepmag, channel, temporal median flux in e-/s
%NOTES
% Used 11.5 < Kp < 12.5 for 
%TO-DO list
%REVISION HISTORY:
%Engineer          Org           Date        Description
%J. Van Cleve  Ball Aerospace  9/8/2020   Validate, comment, clean up for github
campaignString = 'C08';
dataDir = ['/Volumes/My Passport for Mac/solarSystem/zody/' campaignString '/lsflat']
cd(dataDir)
timeStamp = datestr(now,'YYYYMMDD');
d = dir('*.fits');
import matlab.io.*
nllc = length(d);
%kepmag ch medianFlux
lsflatOut = zeros(nllc,3);
for i = 1:nllc
    if ~mod(i,25)
        fprintf('LSFLAT %5.0f of %5.0f stars\n',i,nllc)
    end
    fname = d(i).name;
    %get parms out of header
    fptr = fits.openFile(fname);
    fits.movAbsHDU(fptr,1);
    [key, ~] = fits.readKey(fptr,'KEPMAG');
    lsflatOut(i,1) = str2double(key);
    [key, ~] = fits.readKey(fptr,'CHANNEL');
    lsflatOut(i,2) = str2double(key);
    pdcSapFlux = fitsread(fname,'BinaryTable');
    lsflatOut(i,3) = nanmedian(pdcSapFlux{8});
    fits.closeFile(fptr);
end
save(fullfile(dataDir,[campaignString '_lsflat.mat']),'lsflatOut','timeStamp')
%%
fit_lsflat_by_channel(dataDir, campaignString, lsflatOut);