function varargout = iAlert(varargin)
% IALERT MATLAB code for iAlert.fig
%      IALERT, by itself, creates a new IALERT or raises the existing
%      singleton*.
%
%      H = IALERT returns the handle to a new IALERT or the handle to
%      the existing singleton*.
%
%      IALERT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IALERT.M with the given input arguments.
%
%      IALERT('Property','Value',...) creates a new IALERT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before iAlert_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to iAlert_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help iAlert

% Last Modified by GUIDE v2.5 23-Oct-2016 23:00:13



% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @iAlert_OpeningFcn, ...
                   'gui_OutputFcn',  @iAlert_OutputFcn, ...
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


% --- Executes just before iAlert is made visible.
function iAlert_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to iAlert (see VARARGIN)

% Choose default command line output for iAlert
handles.output = hObject;

% Resize the output plots to be the same size
handles.axesRecord.Position(3) = handles.axesLive.Position(3);
handles.axesRecord.Position(4) = handles.axesLive.Position(4);


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes iAlert wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = iAlert_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in loadBtn.
function loadBtn_Callback(hObject, eventdata, handles)
% hObject    handle to loadBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.setBtn.Enable = 'on';
loadBtn = hObject;
handles.song = uigetfile('*.*', 'Load an audio file');
handles.songName.String = handles.song;
[handles.song, handles.CompareFs] = audioread(handles.song);



handles.axesLive.YLim = [200 2000];
handles.axesRecord.YLim = [200 2000];
axes(handles.axesLive);
set(gca,'Color',[0 0 0]);
axes(handles.axesRecord);
set(gca,'Color',[0 0 0]);
handles.axesRecord.Visible = 'on';
handles.axesLive.Visible = 'on';
handles.playSong.Enable = 'on';
handles.stopSong.Enable ='on';

%save all variables
guidata(loadBtn,handles);


% --- Executes on button press in recordBtn.
function recordBtn_Callback(hObject, eventdata, handles)
    % hObject    handle to recordBtn (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    recordBtn = hObject;
    handles.recording = audiorecorder(handles.CompareFs,8,1); %initialize audio recorder object with Fs sample rate, 8-bit bit depth, 1 channel
    handles.durationSong = length(handles.song)/ handles.CompareFs; % sets the size of the 
    handles.percentages = zeros(1,0);
    handles.Stop = 0;
    handles.sensitivity = 85;
    handles.p_offset = 100;
    handles.delay = 1;
    %save all variables
    guidata(recordBtn,handles);

    %initialize recording
    initRecord(recordBtn);
    initTimer(recordBtn);
    x = guidata(recordBtn);
    startTimer(x.t);
    handles.Stop = 0;
    Record(recordBtn, x.t);

%% initRecord
function initRecord(recordHandle)
    x = guidata(recordHandle);
    x.a = zeros(1,1); %initialize audio recording
    x.recording.record;
    x.currentLengthA = length(x.a);
    %delay to allow time to record something to avoid empty a
    guidata(recordHandle, x);
    pause(0.1);

%% initTimer
function initTimer(recordHandle)
    %create timer object 
    x = guidata(recordHandle);
    x.timer_finished = false;
    x.t = timer;
    x.t.TimerFcn = 'x.timer_finished = true;';
    x.t.StartDelay = 1; %set interval at which audio is analyzed 
    guidata(recordHandle,x);


%% startTimer
function startTimer(timer)
    start(timer)

%% Record
function Record(recordBtn,recordTimer)
    x = guidata(recordBtn);
    x.average_percentage = 0;
    guidata(recordBtn, x);
    x.prevLength = 1;
    x.count = 0;
    s = struct();
    s.images = {};

    s.Stop = 0;
    

    
    % Process while the length of the recording is shorter then the
    % original and the stop button has not been pressed
    while length(x.a) <= length(x.song) & x.Stop == 0;

        if(strcmp(recordTimer.Running,'off') == 1)
            x.a = getaudiodata(x.recording);
            if(length(x.a) > length(x.song))
                break;
            end
            x.currentLengthA = length(x.a);
            [x.image_sound_a, x.image_sound_b] = audioTimer(x.a,x.axesLive,x.axesRecord,x.song, x.CompareFs, x.currentLengthA,x.prevLength);
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
            string  = sprintf(' Accuracy %.2f %%', x.average_percentage);
            x.accuracyTxt.String = string;
            string

        end
        x.prevLength = x.currentLengthA;


    end
    
    x.percentages;
    x.recording.stop;
    x.resetBtn.Enable = 'on';

    axes(x.axesLive);
    plotspectrogram(x.song(1:x.currentLengthA,1),x.CompareFs);
    ylim([200 2000]);


    axes(x.axesRecord);
    plotspectrogram(x.a(1:x.currentLengthA),x.CompareFs);

    ylim([200 2000]);

    % save images to compare them 
    for i = 1:length(s.images)
        str = sprintf('%d',i);
        str(end+1:end+4) = '.png';
        imwrite(s.images{i},str)
    end


%%  btnStop_Callback
function btnStop_Callback(hObject, eventdata, handles)
    % hObject    handle to btnStop (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    if (handles.debug)
        'btnStop_Callback'
    end
        
    handles.Stop = 1;
    guidata(hObject, handles);
   


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton5 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    soundsc(handles.song, handles.CompareFs);
    
