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
close all
clearvars
debug = 1;
dataDir =  '/Volumes/My Passport for Mac/solarSystem/zody/';
%standard numerical labels for campaigns
campaigns = [0:8 102 111 112 12:19];
if debug
    campaigns = 7:8;
end
outString = [sprintf('C%02.0f',campaigns(1)) '-' sprintf('C%02.0f',campaigns(end))];
nC = length(campaigns);
argStruct = repmat(struct('c',0,'cadenceNos',0,'midTimes',0,'zeroCoeff',0,'medianCalFlux',0,'isArgHere',0,'allChGoodCad',0),1,nC);
cd(dataDir)
for iC = 1:nC
    tic
    campaign = campaigns(iC)
    argStruct(iC).c = campaign;
    if (campaign <= 9)
        channelList = [1:4 9:16 21:84];
    else
        channelList = [1:4 13:16 21:84];
    end
    nChan = length(channelList);
    if debug
        nChan = 4;
    end
    cd(dataDir)
    cstring = sprintf('C%02.0f',campaign);
    cd(cstring)
    
    for ich = 1:nChan
        channelIndex = channelList(ich);
        [mod, out] = convert_mod_out_to_from_channel(channelIndex);
        fname = ['ktwo' sprintf('%02.0f', mod) sprintf('%1.0f', out) '-' sprintf('c%02.0f',campaign) '_bkg.fits']
        pixelData = fitsread(fname,'binarytable',1);
        calFlux = pixelData{5};
        bkgCoeff = pixelData{7};
        qualityFlags = pixelData{10};
        %force 21 bits and make LSB column 1 in output character array
        qFlagBin = fliplr(dec2bin(qualityFlags,21));
        if (ich == 1)
            [nCad, nCoeff] = size(bkgCoeff);
            argStruct(iC).midTimes = pixelData{1};
            cadenceNos = pixelData{3};
            goodCad = zeros(nCad,nChan);
            argStruct(iC).cadenceNos = cadenceNos;
            zeroCoeff = zeros(nCad,84);
            medianCalFlux = zeros(nCad,84);
            isArgHere = zeros(nCad,84);
        end
        goodCad(:,ich) = isfinite(bkgCoeff(:,1));
        medianCalFlux(:,channelIndex) = median(calFlux,2);
        zeroCoeff(:,channelIndex) = bkgCoeff(:,1);
        isArgHere(:,channelIndex) = str2num(qFlagBin(:,13));
    end
    argStruct(iC).allChGoodCad = all(goodCad,2);
    argStruct(iC).zeroCoeff = zeroCoeff;
    argStruct(iC).medianCalFlux = medianCalFlux;
    argStruct(iC).isArgHere = isArgHere;
    toc
end
cd(dataDir)
if debug
    save(['argStruct_' outString '_debug.mat'],'argStruct')
else
    save(['argStruct_' outString '.mat'],'argStruct')
end
load gong.mat
sound(y)