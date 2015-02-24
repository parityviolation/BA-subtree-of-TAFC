% export as figures

figure;
h(1) =subplot(2,2,1)
imagesc((amplitudeLeft))
title ('Left SC003')
h(2) = subplot(2,2,2)
imagesc((amplitudeRight))
title ('Right')
h(3) = subplot(2,2,3)
imagesc((amplitudeUp))
title ('Up')
h(4) = subplot(2,2,4)
imagesc((amplitudeDown))
title ('Down')
h = h(1:4)
linkaxes(h);4
%%

figure;
h(1) =subplot(2,2,1)
imagesc(phaseLeft)
title ('Left SC003')
h(2) = subplot(2,2,2)
imagesc(phaseRight)
title ('Right')
h(3) = subplot(2,2,3)
imagesc(phaseUp)
title ('Up')
h(4) = subplot(2,2,4)
imagesc(phaseDown)
title ('Down')
h = h(1:4)
linkaxes(h);
%%
figure;
h(1) =subplot(2,2,1)
imagesc(phaseAzimuth)
title ('Azimuth SC003')
h(2) = subplot(2,2,2)
imagesc(phaseAzimuthDelay)
title ('Delay Azimuth')
h(3) = subplot(2,2,3)
imagesc(phaseElevation)
title ('Elevation')
h(4) = subplot(2,2,4)
imagesc(phaseElevationDelay)
title ('Delay Elevation')
h = h(1:4)
linkaxes(h);

