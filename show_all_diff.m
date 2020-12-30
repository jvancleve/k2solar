close all
clearvars
topDir =  '/Volumes/My Passport for Mac/solarSystemArch/zody/'
cd(topDir)
plusVV = [9, 16, 17, 19];
figure('Position',[-2000 1 1200 960])
%sgtitle('Full Mission Difference Images','FontSize',16)
campaigns = [0:8 102 111 112 12:19];
for campaignIndex = 1:length(campaigns)
    campaign = campaigns(campaignIndex)
    
    vvFactor = 1;
    vvString = '-';
    if ismember(campaign,plusVV)
        vvFactor = -1;
        vvString = '+';
    end
    
    cstring = sprintf('C%02.0f',campaign);
    cd(cstring)
    load([cstring '_last-first_bkg.mat'])
    subplot(4,5,campaignIndex)
    imagesc(fpp),axis equal, axis xy, colormap('jet')
    title([cstring ' VV' vvString],'FontSize',12)
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
    cd(topDir)
end
saveas(gca,'diff_all.png')
