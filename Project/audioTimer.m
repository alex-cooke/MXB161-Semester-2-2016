function [image_sound_a, image_sound_b] =  audioTimer(a,axesLive,axesRecord,song, Fs, currentLength, prevLength)
axes(axesLive);
plotspectrogram(song(prevLength:currentLength,1),Fs);
axis off;
ylim([200 2000]);
img = getframe(gca);
image_sound_a = img.cdata;

axes(axesRecord);
plotspectrogram(a(prevLength:currentLength),Fs);
axis off;
ylim([200 2000]);

img = getframe(gca);
image_sound_b = img.cdata;



drawnow;
