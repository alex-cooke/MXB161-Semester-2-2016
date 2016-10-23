function varargout = iAgree(varargin)
% IAGREE MATLAB code for iAgree.fig
%      IAGREE, by itself, creates a new IAGREE or raises the existing
%      singleton*.
%
%      H = IAGREE returns the handle to a new IAGREE or the handle to
%      the existing singleton*.
%
%      IAGREE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IAGREE.M with the given input arguments.
%
%      IAGREE('Property','Value',...) creates a new IAGREE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before iAgree_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to iAgree_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help iAgree

% Last Modified by GUIDE v2.5 24-Oct-2016 09:00:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @iAgree_OpeningFcn, ...
                   'gui_OutputFcn',  @iAgree_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before iAgree is made visible.
function iAgree_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to iAgree (see VARARGIN)guide


% Choose default command line output for iAgree
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% Ensure that all axes are the same width
handles.recordingSpectrogramAxes.Position(3) = handles.originalSpectrogramAxes.Position(3);
handles.recordingSpectrogramAxes.Position(4) = handles.originalSpectrogramAxes.Position(4);
handles.comparisonSpectrogramAxes.Position(3) = handles.originalSpectrogramAxes.Position(3);
handles.comparisonSpectrogramAxes.Position(4) = handles.originalSpectrogramAxes.Position(4);

% audio recorder
handles.sampleRate = 44100;
handles.recordingInProgress = 0;
handles.recorder = audiorecorder(handles.sampleRate, 8, 1);

% load the metronome
[handles.metronomeAudio, handles.metronomeFs] = audioread('metronome.wav');

% settings
handles.sensitivity = 85;
handles.sensitivitySlider.Value = handles.sensitivity;
handles.sensitivityTxt.String = sprintf('%.01f %%', handles.sensitivity);

handles.p_offset = 100;
handles.pitchSlider.Value = handles.p_offset;
handles.pitchTxt.String = sprintf('%.0f Hz', handles.p_offset);
    
handles.delay = 1;
handles.delaySlider.Value = handles.delay;
handles.delayTxt.String = sprintf('%.01f s', handles.delay);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes iAgree wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = iAgree_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%% originalLoadBtn_Callback - loads a file as the original audio
function originalLoadBtn_Callback(hObject, eventdata, handles)
    % hObject    handle to originalLoadBtn (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    %   load the file
    [handles.originalFileName, handles.originalPath] = uigetfile('*.*', 'Load an original audio track');
    
    %   read the audio and sample rate
    [handles.originalAudio, handles.originalFs] = audioread(handles.originalFileName);
    
	%   save the handles
    guidata(hObject, handles);   
    
    %   render the original audio
    renderOriginalAudio(hObject, handles);
   
%% renderOriginalAudio
function renderOriginalAudio(hObject, handles)
    
    %   render the spectrogram
    axes(handles.originalSpectrogramAxes);
    plotspectrogram(handles.originalAudio, handles.originalFs);
    ylim([200 2000]);
    xlabel('');
    ylabel('');
    handle.originalSpectrogramAxes.Visible = 'on'
    axis off
    
    %   capture the spectrogram image
    img = getframe(gca);
    handles.originalAudioImage = img.cdata;
    
    % hide the live axis
    handles.axesLive.Visible = 'off'
    
    % save the data
    guidata(hObject, handles)
   
%% renderRecordingAudio
function renderRecordingAudio(hObject, handles)
    
    %   render the spectrogram
    axes(handles.recordingSpectrogramAxes);
    plotspectrogram(handles.recordingAudio, handles.recordingFs);
    ylim([200 2000]);
    xlabel('');
    ylabel('');
    handles.recordingSpectrogramAxes.Visible = 'on';
    axis off
    
    %   capture the spectrogram image
    img = getframe(gca);
    handles.recordingAudioImage = img.cdata;
    
    %   save the handles
    guidata(hObject, handles);
    
    compareOriginalAndRecordingImages(hObject, handles);
    
%%  recordingLoadButton_Callback - loads a file as the recording audio
function recordingLoadButton_Callback(hObject, eventdata, handles)
    % hObject    handle to recordingLoadButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    %   load the file
    [handles.recordingFileName, handles.recordingPath] = uigetfile('*.*', 'Load a recording audio track');
    
    %   read the audio and sample rate
    [handles.recordingAudio, handles.recordingFs] = audioread(handles.recordingFileName);
    
    %   crop/pad the recording so that it matches the original
    [originalAudioLength, ~] = size(handles.originalAudio);
    [recordingAudioLength, ~] = size(handles.recordingAudio);

    if (originalAudioLength > recordingAudioLength);
       handles.recordingAudio = padarray(handles.recordingAudio, originalAudioLength);%, 'replicate', 'post');
    elseif (originalAudioLength < recordingAudioLength);
        handles.recordingAudio = handles.recordingAudio(1:originalAudioLength, :);
    end;
    
    %   save the handles
    guidata(hObject, handles);
    
     
    %   render the audio
    renderRecordingAudio(hObject, handles);
  


%% compareOriginalAndRecordingImages - compares two images
function compareOriginalAndRecordingImages(hObject, handles)

    % ensure that the images match
     [aX, aY, aZ] = size(handles.originalAudioImage);
     [bX, bY, ~] = size(handles.recordingAudioImage);
     padding = [(aX - bX) (aY - bY)];
     padding(padding<0) = 0;
     handles.recordingAudioImage = padarray(handles.recordingAudioImage, padding, 'replicate', 'post');
     handles.recordingAudioImage = handles.recordingAudioImage(1: aX, 1:aY, 1:aZ);
   % handles.originalAudioImage = handles.originalAudioImage(1: 248, 1:781, 1:3);
     
%    
%     
    x = guidata(hObject);

    x.sensitivity = 85;
    x.p_offset = 100;
    x.delay = 1;

    [percent_overlap, mask_a_col, mask_b_col, overlap_mask_col] = compareImages(handles.originalAudioImage, handles.recordingAudioImage, handles.sensitivity,handles.p_offset,handles.delay);

    %   render the comparison spectogram
    axes(handles.comparisonSpectrogramAxes);
    imshow(overlap_mask_col);
    
    %   show the comparison accuracy
    handles.comparisonAccuracyTxt.String = sprintf('%.1f %%', percent_overlap * 100);

% --- Executes during object creation, after setting all properties.
function originalSpectrogramAxes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to originalSpectrogramAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate originalSpectrogramAxes


%% originalAudioRecordBtn_Callback - records a new audio to use as the original
function originalAudioRecordBtn_Callback(hObject, eventdata, handles)
    % hObject    handle to originalAudioRecordBtn (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    if(handles.recordingInProgress == 1);
        
        %   stop the recorder
        handles.recorder.stop;
        handles.recordingInProgress = 0;
        
        %   save the audio
        handles.originalAudio = getaudiodata(handles.recorder);
        handles.originalFs = handles.sampleRate;

        % save the handles
        guidata(hObject, handles);
        
        %   render the audio
        renderOriginalAudio(hObject, handles);
        
        %   change the GUI
        enableAllInputs(handles);
        handles.originalAudioRecordBtn.String = 'Record';
        
    else;
        
        %   disable the gui
        disableAllInputs(handles);
        
        %   play the lead in
        playLeadIn(handles);
        
        %   start the recorder
        handles.recordingInProgress = 1;
        handles.recorder.record;
        
        %   change the GUI
        handles.originalAudioRecordBtn.String = 'Stop';
        handles.originalAudioRecordBtn.Enable = 'on';
        
        % save the handles
        guidata(hObject, handles);
        
    end;

% --- Executes on button press in originalAudioPlayBtn.
function originalAudioPlayBtn_Callback(hObject, eventdata, handles)
    % hObject    handle to originalAudioPlayBtn (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    soundsc(handles.originalAudio, handles.originalFs);


% --- recordingAudioRecordBtn_Callback - records new audio from the
% microphone to compare with the original
function recordingAudioRecordBtn_Callback(hObject, eventdata, handles)
% hObject    handle to recordingRecordBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    if(handles.recordingInProgress == 1);
        
        %   stop the recorder
        handles.recorder.stop;
        handles.recordingInProgress = 0;
        
        %   save the audio
        handles.recordingAudio = getaudiodata(handles.recorder);
        handles.recordingFs = handles.sampleRate;
        
        %   save the handles
        guidata(hObject, handles);
        
        %   render the audio
        renderRecordingAudio(hObject, handles);
        
        %   change the GUI
        handles.recordingAudioRecordBtn.String = 'Record';
        enableAllInputs(handles);
        
    else;
        
        %   disable the gui
        disableAllInputs(handles);
        
        %   play the lead in
        playLeadIn(handles);
        
        %   start the recorder
        handles.recordingInProgress = 1;
        handles.recorder.record;
        
        %   change the GUI
        handles.recordingAudioRecordBtn.String = 'Stop';
        handles.recordingAudioRecordBtn.Enable = 'on';

        guidata(hObject, handles);
            
    end;
    
%% recordingPlayButton_Callback - records a new recording audio from the microphone
function recordingPlayButton_Callback(hObject, eventdata, handles)
% hObject    handle to recordingPlayButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    soundsc(handles.recordingAudio, handles.recordingFs);
    

%% disableAllInputs - disables all user controls
function disableAllInputs(handles)
        
    handles.originalLoadBtn.Enable = 'off';
    handles.originalAudioRecordBtn.Enable = 'off';
    handles.originalAudioPlayBtn.Enable = 'off';
    
    handles.recordingLoadButton.Enable = 'off';
    handles.recordingAudioRecordBtn.Enable = 'off';
    handles.recordingPlayButton.Enable = 'off';
    handles.recordingLiveButton.Enable = 'off';
    
function enableAllInputs(handles)

    handles.originalLoadBtn.Enable = 'on';
    handles.originalAudioRecordBtn.Enable = 'on';
    handles.originalAudioPlayBtn.Enable = 'on';
    
    handles.recordingLoadButton.Enable = 'on';
    handles.recordingAudioRecordBtn.Enable = 'on';
    handles.recordingPlayButton.Enable = 'on';
    handles.recordingLiveButton.Enable = 'on';

function playLeadIn(handles)

    soundsc(handles.metronomeAudio, handles.metronomeFs);
    pause(0.5)

    soundsc(handles.metronomeAudio, handles.metronomeFs);
    pause(0.5)

    soundsc(handles.metronomeAudio, handles.metronomeFs);
    pause(0.5)

    soundsc(handles.metronomeAudio, handles.metronomeFs);
    pause(0.5)
    
% --- Executes on button press in comparisonBtn.
function comparisonBtn_Callback(hObject, eventdata, handles)
% hObject    handle to comparisonBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    compareOriginalAndRecordingImages(hObject, handles)


% --- Executes on slider movement.
function delaySlider_Callback(hObject, eventdata, handles)
% hObject    handle to delaySlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    handles.delay = handles.delaySlider.Value;
    handles.delayTxt.String = sprintf('%.01f s', handles.delay);
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function delaySlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to delaySlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sensitivitySlider_Callback(hObject, eventdata, handles)
% hObject    handle to sensitivitySlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    handles.sensitivity = handles.sensitivitySlider.Value;
    handles.sensitivityTxt.String = sprintf('%.01f %%', handles.sensitivity);
    guidata(hObject, handles);
    
    
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sensitivitySlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sensitivitySlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function pitchSlider_Callback(hObject, eventdata, handles)
% hObject    handle to pitchSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    handles.p_offset = handles.pitchSlider.Value;
    handles.pitchTxt.String = sprintf('%.0f Hz', handles.p_offset);
    guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function pitchSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pitchSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in recordingLiveButton.
function recordingLiveButton_Callback(hObject, eventdata, handles)
% hObject    handle to recordingLiveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % hide the other axes
%     handles.originalSpectrogramAxes.Visible = 'Off';
%     handles.recordingSpectrogramAxes.Visible = 'Off';
     handles.comparisonSpectrogramAxes.Visible = 'off';
    guidata(hObject, handles);
    disableAllInputs(handles);
    
    recordBtn = hObject;
    handles.recording = audiorecorder(handles.originalFs,8,1); %initialize audio recorder object with Fs sample rate, 8-bit bit depth, 1 channel
    handles.durationSong = length(handles.originalAudio)/ handles.originalFs; % sets the size of the 
    handles.percentages = zeros(1,0);
    handles.Stop = 0;
    %save all variables
    guidata(hObject,handles);

    playLeadIn(handles);
    
    %initialize recording
    initRecord(recordBtn);
    initTimer(recordBtn);
    x = guidata(recordBtn);
    startTimer(x.t);
    handles.Stop = 0;
    Record(recordBtn, x.t, handles);

function Record(recordBtn,recordTimer, handles)
    x = guidata(recordBtn);
    x.average_percentage = 0;
    guidata(recordBtn, x);
    x.prevLength = 1;
    x.count = 0;
    s = struct();
    s.images = {};

    while length(x.a) <= length(x.originalAudio) & x.Stop == 0;

        if(strcmp(recordTimer.Running,'off') == 1)
            x.a = getaudiodata(x.recording);
            if(length(x.a) > length(x.originalAudio))
                break;
            end
            x.currentLengthA = length(x.a);
            [x.image_sound_a, x.image_sound_b] = audioTimer(x.a,x.originalSpectrogramAxes,x.recordingSpectrogramAxes,x.originalAudio, x.originalFs, x.currentLengthA,x.prevLength);
            [x.percentage, x.mask_a, x.mask_b,x.overlap]  = compareImages(x.image_sound_a, x.image_sound_b,x.sensitivity,x.delay,x.p_offset);

            s.images = vertcat(s.images, [x.image_sound_a], [x.image_sound_b]); 
            delete(recordTimer);
            recordTimer = timer;
            recordTimer.TimerFcn = 'x.timer_finished = true;';
            recordTimer.StartDelay = 1;
            % compare b to a 
    %         figure;
    %         imshow(x.overlap);
            x.percentage = x.percentage * 100;
            if isnan(x.percentage)
                x.percentage = 0;
            end
            start(recordTimer);
            x.percentages = horzcat(x.percentages, x.percentage);
            x.average_percentage = (sum(x.percentages) /  length(x.percentages));
            string  = sprintf('%.0f %%', x.average_percentage);
            x.comparisonAccuracyTxt.String = string;
           

        end
        x.prevLength = x.currentLengthA;


    end
    x.percentages
    x.recording.stop;
    x.resetBtn.Enable = 'on';

    axes(x.originalSpectrogramAxes);
    plotspectrogram(x.originalAudio(1:x.currentLengthA,1),x.originalFs);
    ylim([200 2000]);

    axis off

    axes(x.recordingSpectrogramAxes);
    plotspectrogram(x.a(1:x.currentLengthA),x.originalFs);

    ylim([200 2000]);
    
    axis off

    % save images to compare them 
    for i = 1:length(s.images)
        str = sprintf('%d',i);
        str(end+1:end+4) = '.png';
        imwrite(s.images{i},str)
    end
    
    enableAllInputs(handles);
    
function initRecord(recordHandle)
    x = guidata(recordHandle);
    x.a = zeros(1,1); %initialize audio recording
    x.recording.record;
    x.currentLengthA = length(x.a);
    %delay to allow time to record something to avoid empty a
    guidata(recordHandle, x);
    pause(0.1);

function initTimer(recordHandle)
    %create timer object 
    x = guidata(recordHandle);
    x.timer_finished = false;
    x.t = timer;
    x.t.TimerFcn = 'x.timer_finished = true;';
    x.t.StartDelay = 1; %set interval at which audio is analyzed 
    guidata(recordHandle,x);

function startTimer(timer)
    start(timer)


