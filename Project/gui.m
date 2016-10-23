function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 22-Oct-2016 23:30:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
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

% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using gui.

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
cla;

popup_sel_index = get(handles.popupmenu1, 'Value');
switch popup_sel_index
    case 1
        plot(rand(5));
    case 2
        plot(sin(1:0.01:25.99));
    case 3
        bar(1:.5:10);
    case 4
        plot(membrane);
    case 5
        surf(peaks);
end


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'plot(rand(5))', 'plot(sin(1:0.01:25))', 'bar(1:.5:10)', 'plot(membrane)', 'surf(peaks)'});


% --- Executes on button press in loadBtn.
function loadBtn_Callback(hObject, eventdata, handles)
% hObject    handle to loadBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.setBtn.Enable = 'on';
loadBtn = hObject;
handles.song = uigetfile;
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

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function field1_Callback(hObject, eventdata, handles)
% hObject    handle to field1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of field1 as text
%        str2double(get(hObject,'String')) returns contents of field1 as a double


% --- Executes during object creation, after setting all properties.
function field1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to field1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sensitivity_Callback(hObject, eventdata, handles)
% hObject    handle to sensitivity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sensitivity as text
%        str2double(get(hObject,'String')) returns contents of sensitivity as a double


% --- Executes during object creation, after setting all properties.
function sensitivity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sensitivity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function field3_Callback(hObject, eventdata, handles)
% hObject    handle to field3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of field3 as text
%        str2double(get(hObject,'String')) returns contents of field3 as a double


% --- Executes during object creation, after setting all properties.
function field3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to field3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in stopBtn.
function stopBtn_Callback(hObject, eventdata, handles)
% hObject    handle to stopBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    handles.Stop == 1;

% --- Executes on key press with focus on loadBtn and none of its controls.
function loadBtn_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to loadBtn (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


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
%save all variables
guidata(recordBtn,handles);

%initialize recording
initRecord(recordBtn);
initTimer(recordBtn);
x = guidata(recordBtn);
startTimer(x.t);
handles.Stop = 0;
Record(recordBtn, x.t);

function Record(recordBtn,recordTimer)
x = guidata(recordBtn);
x.average_percentage = 0;
guidata(recordBtn, x);
x.prevLength = 1;
x.count = 0;
s = struct();
s.images = {};

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
        
    end
    x.prevLength = x.currentLengthA;
   

end
x.percentages
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


    


function [image_sound_a, image_sound_b] =  drawNow(a,axesLive,axesRecord,song, Fs, currentLength, prevLength)
 
axes(axesLive);
plotspectrogram(song(prevLength:currentLength,1),Fs);
ylim([200 2000]);
img = getframe(gca);
image_sound_a = img.cdata;


axes(axesRecord);
plotspectrogram(a(prevLength:currentLength),Fs);
ylim([200 2000]);

img = getframe(gca);
image_sound_b = img.cdata;


drawnow;

    
    
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




% --- Executes on mouse press over axes background.
function axesCompare_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axesCompare (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in setBtn.
function setBtn_Callback(hObject, eventdata, handles)
% hObject    handle to setBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setBtn = hObject;
handles.sensitivity = str2num(handles.sensitivity.String(1:2));
handles.delay = str2num(handles.delay.String(1:end));
handles.p_offset = str2num(handles.p_offset.String(1:3));
guidata(setBtn,handles);
handles.recordBtn.Enable = 'on';
handles.stopBtn.Enable = 'on';


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function accuracyTxt_Callback(hObject, eventdata, handles)
% hObject    handle to accuracyTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of accuracyTxt as text
%        str2double(get(hObject,'String')) returns contents of accuracyTxt as a double


% --- Executes during object creation, after setting all properties.
function accuracyTxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to accuracyTxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in resetBtn.
function resetBtn_Callback(hObject, eventdata, handles)
% hObject    handle to resetBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
loadBtn_Callback(hObject, eventdata,handles);



% --- Executes on slider movement.
function sensitivitySlider_Callback(hObject, eventdata, handles)
% hObject    handle to sensitivitySlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
txt = sprintf('%d %%', handles.sensitivitySlider.Value);
handles.sensitivity.String = txt;


% --- Executes during object creation, after setting all properties.
function sensitivitySlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sensitivitySlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in playSong.
function playSong_Callback(hObject, eventdata, handles)
% hObject    handle to playSong (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
soundsc(handles.song, handles.CompareFs);

% --- Executes on button press in stopSong.
function stopSong_Callback(hObject, eventdata, handles)
% hObject    handle to stopSong (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clear sound;


% --- Executes on slider movement.
function delaySlider_Callback(hObject, eventdata, handles)
% hObject    handle to delaySlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
txt = sprintf('%.2f', handles.delaySlider.Value);
handles.delay.String = txt;

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
function pitchSlider_Callback(hObject, eventdata, handles)
% hObject    handle to pitchSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
txt = sprintf('%d', handles.pitchSlider.Value);
handles.p_offset.String = txt;

% --- Executes during object creation, after setting all properties.
function pitchSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pitchSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
