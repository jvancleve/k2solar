close all
clearvars
load('/Volumes/My Passport for Mac/flight/analysis/compression/EPIC/K2_star_counts_by_channel_C00-C19.mat')
topDir =  '/Volumes/My Passport for Mac/solarSystem/zody/'
cd(topDir)
[mods, outs] = convert_mod_out_to_from_channel(1:84);

plusVV = [9, 16, 17, 19];
h = figure('Position',[-2000 1 1400 960])
%sgtitle('Full Mission Mid Cadence Images','FontSize',16)
for campaignIndex = 1:20
    starsPerDeg2 = zeros(84,1);
    campaign = campaignIndex - 1;
    channelList = [1:4 9:16 21:84];
    cstring = sprintf('C%02.0f',campaign);
    vvFactor = 1;
    vvString = '-';
    if ismember(campaign,plusVV)
        vvFactor = -1;
        vvString = '+';
    end
    StarCounts = starCountStruct(campaignIndex).StarCounts;
    nChan = length(StarCounts);
    
    if nChan == 76
        channelList = [1:4 9:16 21:84];
    else
        channelList = [1:4 13:16 21:84];
    end
    
    area = 0.25*pi()*(starCountStruct(campaignIndex).radiusInArcmin/60)^2;
    starsPerDeg2(channelList) = StarCounts;
    subplot(4,5,campaignIndex)
    ccd = zeros(11,11);
    ccd(:) = nan; % or 0
    for i=1:length(starsPerDeg2)
        [r,c] = fovPlottingClass.modout2rowcolumn(mods(i),outs(i));
        if ((~isnan(r)) && (~isnan(c)))
            ccd(r,c) = starsPerDeg2(i);
        end
    end
    p_ = pcolor(ccd);
    set(gca,'ydir','reverse');
    daspect([1 1 1]);
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
    title([cstring ' VV' vvString],'FontSize',12)
    colorbar
    cd(topDir)
end
saveas(gca,'k2_full_mission_nstars.png')