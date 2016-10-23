%% clear workspace
clear;
clc;

%% read in the audio to be compared TO 
[song, Fs] = audioread('test_piano1.wav'); %load in song
recording = audiorecorder(Fs,8,1); %initialize audio recorder object with Fs sample rate, 8-bit bit depth, 1 channel


durationSong = length(song)/ Fs; % sets the size of the 
h= figure;
h2 = figure;


a = zeros(1,1); %initialize audio recording
recording.record;
currentLengthA = length(a);
%delay to allow time to record something to avoid empty a
pause(0.1);
 
%create timer object 
% timer_finished = false;
timer_finished = false;
t = timer;
t.TimerFcn = 'timer_finished = true;';
t.StartDelay = 1; %set interval at which audio is analyzed 

%start timer and initialize values
start(t);
percentages  = zeros(1,1);


%%  Record audio
while length(a) <= length(song);
    a = getaudiodata(recording);
    if(length(a) > length(song))
        break;
    end
    currentLengthA = length(a);
    [image_sound_a, image_sound_b] = audioTimer(a,h,h2,song, Fs, currentLengthA);
    if(timer_finished == true)
        delete(t);
        t = timer;
        t.TimerFcn = 'timer_finished = true;';
        t.StartDelay = 1;
        % compare b to a 
        [percentage, mask_a, mask_b,overlap]  = compareImages(image_sound_a, image_sound_b);
        percentage = percentage * 100;
        timer_finished = false;
        start(t);
        percentages = horzcat(percentages, percentage);
    end
   

end

average_percentage = (sum(percentages) /  length(percentages));
recording.stop;
hold on;
figure;
imshow(mask_a);
figure;
imshow(mask_b);
figure;
imshow(overlap);