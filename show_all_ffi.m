clearvars
close all
cd('/Volumes/My Passport for Mac/solarSystemArch/zody/ffi')
h = figure('Position',[-2000 1 1400 960]);
%title('4x4 min, sqrt scale, 5-99 prctile')
cs = [0:8 91 102 111 12:19];
% cs = 111
ncs = length(cs);
for ic = 1:ncs
    c = cs(ic);
    cstring = sprintf('c%02.0f',c)
    d = dir(['*' cstring '*_min.mat']);
    %show the first FFI    
%     load(d(1).name)
    %show the 2nd FFI if it exists
    if length(d) > 1
        load(d(2).name)
    else
        load(d(1).name)
    end
    subplot(4,5,ic)  
    %from C11 histogram
    medIm = nanmedian(fpp(:));
    minScale = 0.5*medIm;
    maxScale = 2*medIm;
    imagesc(asinh(fpp), [asinh(minScale), asinh(maxScale)]),axis equal, axis xy,title(cstring,'FontSize',14,'Interpreter','None')
%     imagesc(fpp,[minScale, maxScale]),axis equal, axis xy,title(cstring,'FontSize',14,'Interpreter','None')
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
    colormap('jet')
end
saveas(gca,'k2_all_ffi_min4x4_asinh.png')
gong = load('gong.mat')
soundsc(gong.y)