%NAME: ss_movie
%PURPOSE:read K2 solar system custom apertures and construct moving-target image
%USAGE:
% -create a directory which contains only tile lpd-targ.fits files for a
%  single mod.out
% -run in apOnly mode first to get info for efficient run
% -set max number of samples in campaign in order to speed up processing
%CALLED BY:
%CALLS
%
%INPUTS
% lpd-targ.fits files
% videoScale
%OUTPUTS
%image, processing params, movie
%paramStruct = 
%           xmin: 92
%          xSize: 460
%           ymin: 697
%          ySize: 174
%           cads: [1×242 double] (relative cadence indices)
%         cadInt: 14 (cadence interval, one out of each cadInt cadences)
%     videoScale: 10000
%          nSamp: 242 (nSamp*cadInt < numCads)
%NOTES
% -The number of files is the number of custom aperture targets = tiles
% -The video plays 
%TO-DO list
% -choose 'interval' or 'range' methods for cadences
% -functionalize
%REVISION HISTORY:
%Engineer            Org     Date        Description
%J. Van Cleve  Ball Aero     09/02/2020  Created
%                            12/23/2020  Comments
clearvars
tic
import matlab.io.*
debug = 1;
targetName = 'earth';
% cadSelectMethod = 'thin';
cadSelectMethod = 'range';
cads = 1:30;
apOnly = 0;
maxSamp = 256;
videoScale = 1e4;

if apOnly
    xmin = 1;
    xSize = 1132;
    ymin = 1;
    ySize = 1070;
    maxSamp = 1;
else
    load([targetName '_ap.mat'])
    xmin = paramStruct.xmin;
    xSize = paramStruct.xSize;
    ymin = paramStruct.ymin;
    ySize = paramStruct.ySize;
end

d = dir('*.fits');
nFiles = length(d);
maxTiles = nFiles;
fname = d(1).name;
bintable = fitsread(fname,'binarytable');
calFlux = bintable{5};
[nCad, ~] = size(calFlux);

if (cads == -1); cads = 1:nCad; end

if strcmpi(cadSelectMethod,'thin')
    cadInt = ceil(nCad/maxSamp);%cadence interval
    cads = 1:cadInt:nCad;
    nSamp = length(cads);
    sampString = sprintf('thin_%04.0f',cadInt)
else
    sampString = sprintf('range_%04.0f-%04.0f',cads(1),cads(end))
    cadInt = 1;
    nSamp = length(cads);
end

imFrame = single(zeros(ySize,xSize,nSamp));
for iFile = 1:maxTiles
    if ~mod(iFile,10)
        iFile
    end
    fname = d(iFile).name;
    aperture = fitsread(fname,'image');
    sAp = size(aperture);
    if ~apOnly
        bintable = fitsread(fname,'binarytable');
        calFlux = bintable{5};
    end
    fptr = fits.openFile(fname);
    fits.movAbsHDU(fptr,3);
    [key, ~] = fits.readKey(fptr,'CRVAL1P');
    colOffset = str2double(key) - xmin + 1;
    [key, ~] = fits.readKey(fptr,'CRVAL2P');
    rowOffset = str2double(key) - ymin + 1;
    fits.closeFile(fptr)
    %rows, columns, cadences
    if ~apOnly
        for iSamp = 1:nSamp
            imFrame(rowOffset:rowOffset + sAp(1) - 1,colOffset:colOffset + sAp(2) - 1,iSamp) = ...
                single(reshape(calFlux((iSamp-1)*cadInt + 1,:),sAp(1),sAp(2)));
        end
    else
        imFrame(rowOffset:rowOffset + sAp(1) - 1,colOffset:colOffset + sAp(2) - 1) = ...
                single(ones(sAp(1),sAp(2)));
    end
end
if apOnly
    [aprow, apcol] = ind2sub(size(imFrame),find(imFrame(:)));
    paramStruct.xmin = min(apcol) - 2;
    paramStruct.xSize = max(apcol) - min(apcol) + 5;
    paramStruct.ymin = min(aprow) - 2;
    paramStruct.ySize = max(aprow) - min(aprow) + 5;
    save([targetName '_ap.mat'],'imFrame','paramStruct')
    imagesc(imFrame),axis equal,axis xy,title('Aperture')
else
    paramStruct.cads = cads;
    paramStruct.cadInt = cadInt;
    save([targetName '_' sampString '.mat'],'imFrame','paramStruct')
    for i=1:nSamp,imagesc((imFrame(:,:,i)),[0 videoScale]),axis xy, axis equal,title(num2str(cads(i))),pause(0.1),end
    v = VideoWriter([targetName '_' sampString '.mp4'],'MPEG-4')
    open(v)
    for i = 1:nSamp;writeVideo(v,flipud(uint8(255*min(imFrame(:,:,i),videoScale)/videoScale)));end
    close(v)
end
fprintf('%4.0f cadences processed,')
toc
%%
