function varargout = GUI_Detect(varargin)
% GUI_DETECT MATLAB code for GUI_Detect.fig
%      GUI_DETECT, by itself, creates a new GUI_DETECT or raises the existing
%      singleton*.
%
%      H = GUI_DETECT returns the handle to a new GUI_DETECT or the handle to
%      the existing singleton*.
%
%      GUI_DETECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_DETECT.M with the given input arguments.
%
%      GUI_DETECT('Property','Value',...) creates a new GUI_DETECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_Detect_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_Detect_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_Detect

% Last Modified by GUIDE v2.5 18-Jan-2018 15:24:27


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_Detect_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_Detect_OutputFcn, ...
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


% --- Executes just before GUI_Detect is made visible.
function GUI_Detect_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_Detect (see VARARGIN)

% Choose default command line output for GUI_Detect
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_Detect wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_Detect_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function Thresh_In_Callback(hObject, eventdata, handles)
% hObject    handle to Thresh_In (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Thresh_In as text
%        str2double(get(hObject,'String')) returns contents of Thresh_In as a double


% --- Executes during object creation, after setting all properties.
function Thresh_In_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Thresh_In (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Size_In_Callback(hObject, eventdata, handles)
% hObject    handle to Size_In (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Size_In as text
%        str2double(get(hObject,'String')) returns contents of Size_In as a double


% --- Executes during object creation, after setting all properties.
function Size_In_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Size_In (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Channel_In_Callback(hObject, eventdata, handles)
% hObject    handle to Channel_In (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Channel_In as text
%        str2double(get(hObject,'String')) returns contents of Channel_In as a double


% --- Executes during object creation, after setting all properties.
function Channel_In_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Channel_In (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Detect_Cells.
function Detect_Cells_Callback(hObject, eventdata, handles)
% hObject    handle to Detect_Cells (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
th = str2double(get(handles.Thresh_In,'String'));
sz = str2double(get(handles.Size_In,'String'));
im = get(handles.Get_Img,'UserData');
im = im{1};
%centers = pkfnd(bpass(im,2,sz),th,sz);
centersg = pkfnd_GPU4(bpass(im,1,7),th,sz);

%centersg = pkfnd_GPU3(im,th,sz);
%imshow(imadjust(im))
%subplot(1,2,1)
imshow(im)
hold on
%scatter(centers(:,1),centers(:,2),'r')
scatter(centersg(:,1),centersg(:,2),'g','x')
%{
subplot(1,2,2)
imagesc(bpass(im,2,sz))
hold on
%scatter(centers(:,1),centers(:,2),'r')
scatter(centersg(:,1),centersg(:,2),'g','x')
set(hObject,'UserData',[th sz])
%}


% --- Executes on button press in Get_Img.
function Get_Img_Callback(hObject, eventdata, handles)
% hObject    handle to Get_Img (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[img,im_path] = uigetfile({'*.tif'},'File Selector');
im = imread([im_path img]);
set(hObject,'UserData',{im,img})
%imshow(imadjust(im))
imshow(im);


% --- Executes on button press in Save.
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Img_Data = get(handles.Get_Img,'UserData');
set_vals = get(handles.Save,'UserData');
Img_Name = Img_Data{2};
[na,me] = strtok(Img_Name,'_');
channel = str2double(me(5));
Vals = get(handles.Detect_Cells,'UserData');
set_vals(channel,1:2) = Vals;
set(hObject,'UserData',set_vals)
%{
show_del = get(handles.Save,'UserData');
clc
disp(show_del)
%}

% --- Executes on button press in Plates_Get.
function Plates_Get_Callback(hObject, eventdata, handles)
% hObject    handle to Plates_Get (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
plates = get(handles.Plates_Get,'UserData');
im_dir = uigetdir('./','Select Plate Folder');
plates = [plates,{im_dir}];
set(hObject,'UserData',plates)


% --- Executes on button press in Analyze_Img.
function Analyze_Img_Callback(hObject, eventdata, handles)
% hObject    handle to Analyze_Img (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
plates = get(handles.Plates_Get,'UserData');
vals = get(handles.Save,'UserData');
th = vals(:,1)';
sz = vals(:,2)';
if gpuDeviceCount==0
    disp("No GPU Detected.")
end    
Analyze_v1(th,sz,unique(plates))
msgbox('Plate Analysis Completed!','Success');
