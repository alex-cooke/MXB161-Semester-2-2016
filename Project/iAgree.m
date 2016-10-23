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

% Last Modified by GUIDE v2.5 24-Oct-2016 02:59:46

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

    %   capture the spectrogram image
    img = getframe(gca);
    handles.originalAudioImage = img.cdata;
    
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

    %   capture the spectrogram image
    img = getframe(gca);
    handles.recordingAudioImage = img.cdata;
    
    %   save the handles
    guidata(hObject, handles);
    
    compareOriginalAndRecordingImages(hObject, handles)
    
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

    [percent_overlap, mask_a_col, mask_b_col, overlap_mask_col] = compareImages(handles.originalAudioImage, handles.recordingAudioImage, 85,100,1);

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
        handles.originalAudioRecordBtn.String = 'Record';
        
    else;
        
        %   play the lead in
        playLeadIn(handles);
        
        %   start the recorder
        handles.recordingInProgress = 1;
        handles.recorder.record;
        
        %   change the GUI
        handles.originalAudioRecordBtn.String = 'Stop';
        
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
        
    else;
        
        %   play the lead in
        playLeadIn(handles);
        
        %   start the recorder
        handles.recordingInProgress = 1;
        handles.recorder.record;
        
        %   change the GUI
        handles.recordingAudioRecordBtn.String = 'Stop';

        guidata(hObject, handles);
            
    end;
    
%% recordingPlayButton_Callback - records a new recording audio from the microphone
function recordingPlayButton_Callback(hObject, eventdata, handles)
% hObject    handle to recordingPlayButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    soundsc(handles.recordingAudio, handles.recordingFs);
    

%% disableAllInputs - disables all user controls
function disableAllInputs()
        


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
