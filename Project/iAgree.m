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

% Last Modified by GUIDE v2.5 24-Oct-2016 00:01:19

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
% varargin   command line arguments to iAgree (see VARARGIN)

% Choose default command line output for iAgree
handles.output = hObject;

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

    %   play the audio
    soundsc(handles.originalAudio, handles.originalFs);
    
	%   save the handles
    guidata(hObject, handles);
    
%     
%     handles.setBtn.Enable = 'on';
%     loadBtn = hObject;
%     handles.song = uigetfile;
%     handles.songName.String = handles.song;
%     [handles.song, handles.CompareFs] = audioread(handles.song);


%%  recordingLoadButton_Callback - loads a file as the recording audio
function recordingLoadButton_Callback(hObject, eventdata, handles)
    % hObject    handle to recordingLoadButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    %   load the file
    [handles.recordingFileName, handles.recordingPath] = uigetfile('*.*', 'Load a recording audio track');
    
    %   read the audio and sample rate
    [handles.recordingAudio, handles.recordingFs] = audioread(handles.recordingFileName);
    
    %   render the spectogram
    axes(handles.recordingSpectrogramAxes);
    plotspectrogram(handles.recordingAudio, handles.recordingFs);
    ylim([200 2000]);
    xlabel('');
    ylabel('');
    handle.recordingSpectrogramAxes.Visible = 'on'

    %   capture the spectrogram image
    img = getframe(gca);
    handles.recordingAudioImage = img.cdata;
    
    %   play the audio
    soundsc(handles.recordingAudio, handles.recordingFs);
    
    %   Compares the original and recording files
    
    %   save the handles
    guidata(hObject, handles);
    


% --- Executes during object creation, after setting all properties.
function originalSpectrogramAxes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to originalSpectrogramAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate originalSpectrogramAxes
