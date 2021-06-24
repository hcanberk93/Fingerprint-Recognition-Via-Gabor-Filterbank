function varargout = GUI(varargin)
%GUI MATLAB code file for GUI.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('Property','Value',...) creates a new GUI using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to GUI_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      GUI('CALLBACK') and GUI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in GUI.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI

% Last Modified by GUIDE v2.5 11-Jun-2021 05:30:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for GUI
handles.output = hObject;
% Default parameters of the Gabor FilterBank
handles.scale = 5;
handles.orientation = 8;
handles.rowNumber = 39;
handles.columnNumber = 39;
% Default parameters of the Gabor Features
handles.rowDownsampling = 4;
handles.columnDownsampling = 4;


% Update handles structure
guidata(hObject, handles);

set(handles.scaleProp,'String', handles.scale);
set(handles.orientationProp,'String', handles.orientation);
set(handles.rowProp,'String', handles.rowNumber);
set(handles.columnProp,'String', handles.columnNumber);
set(handles.drowProp,'String', handles.rowDownsampling);
set(handles.dcolumnProp,'String', handles.columnDownsampling);
% UIWAIT makes GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in browseButton.
function browseButton_Callback(hObject, eventdata, handles)
% hObject    handle to browseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path] = uigetfile('.jpg');
if file == 0
    return
end

imgNumber = split(file,'.'); %Splitting the file name and extension
imgNumber = char(imgNumber{1}); %  Select the file name
imgNumber = imgNumber(end); % Get the number of the file

if ~strcmp(imgNumber,'5')
    errordlg('Selected file is not a test file, the filename of the test image ends with 5','Error')
else

set(handles.selectedFingerName,'String',file);

img = imread(strcat(path,'/',file));
axes(handles.selectedFinger);
imshow(img);
handles.img = img;
guidata(hObject, handles);
end


% --- Executes on button press in matchButton.
function matchButton_Callback(hObject, eventdata, handles)
% hObject    handle to matchButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~controlInputs([handles.scaleProp.String,handles.orientationProp.String,handles.rowProp.String,...
        handles.columnProp.String,handles.drowProp.String,handles.dcolumnProp.String])
    errordlg('Parameters should be an Integer value','Error')
elseif ~isfolder('BTest') || ~isfolder('BTest')
    errordlg('The dataset is not prepared, please prepare the dataset by clicking Prepare Dataset button first','Error')
else
    
handles.scale = str2num(handles.scaleProp.String);
handles.orientation = str2num(handles.orientationProp.String);
handles.rowNumber = str2num(handles.rowProp.String);
handles.columnNumber = str2num(handles.columnProp.String);
% Default parameters of the Gabor Features
handles.rowDownsampling = str2num(handles.drowProp.String);
handles.columnDownsampling = str2num(handles.dcolumnProp.String);


imgTest = handles.img;
imgTest = imresize(imgTest,[100,100]);
gaborArray = gaborFilterBank(handles.scale,handles.orientation,handles.rowNumber,handles.columnNumber);
g1 = gaborFeatures(imgTest,gaborArray,handles.rowDownsampling,handles.columnDownsampling);

trainFiles = dir('BTrain/*.jpg');
distanceVal = zeros(numel(trainFiles),1);
wBar = waitbar(0,'Please wait...');

for i = 1:numel(trainFiles)
    waitbar(i/numel(trainFiles),wBar,strcat('Current Data',num2str(i),'/',num2str(numel(trainFiles))));
    img = imread(strcat(trainFiles(i).folder,'/',trainFiles(i).name));
    img = imresize(img,[100,100]);
    gaborArray = gaborFilterBank(handles.scale,handles.orientation,handles.rowNumber,handles.columnNumber);
    g2 = gaborFeatures(img,gaborArray,handles.rowDownsampling,handles.columnDownsampling);

    E_distance = mean(mean(sqrt(sum((g2-g1).^2))));

    distanceVal(i) = E_distance;
    
end
index = find(distanceVal == min(distanceVal));
disp(index);
disp(trainFiles(index).name);

matchId = getFingerIdFromFileName(trainFiles(index).name);

IsSuccess = strcmp(getFingerIdFromFileName(handles.selectedFingerName.String),matchId);


img = imread(trainFiles(index).name);
axes(handles.matchedFinger);
imshow(img);

set(handles.matchedFingerName,'String', trainFiles(index).name);

set(handles.textProp1,'String', strcat('Selected Person Id: ',getFingerIdFromFileName(handles.selectedFingerName.String)));
set(handles.textProp2,'String', strcat('Matched Person Id: ',matchId));

if IsSuccess == 1
    set(handles.textProp3,'ForegroundColor','green');
    set(handles.textProp3,'FontWeight','bold');
    set(handles.textProp3,'String','Success');
else
    set(handles.textProp3,'ForegroundColor','red');
    set(handles.textProp3,'FontWeight','bold');
    set(handles.textProp3,'String','Fail');
end
close(wBar)

end



% --- Executes on button press in testButton.
function testButton_Callback(hObject, eventdata, handles)
% hObject    handle to testButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~controlInputs([handles.scaleProp.String,handles.orientationProp.String,handles.rowProp.String,...
        handles.columnProp.String,handles.drowProp.String,handles.dcolumnProp.String])
    errordlg('Parameters should be an Integer value','Error')
elseif ~isfolder('BTest') || ~isfolder('BTest')
    errordlg('The dataset is not prepared, please prepare the dataset by clicking Prepare Dataset button first','Error')
else
    
    handles.scale = str2num(handles.scaleProp.String);
    handles.orientation = str2num(handles.orientationProp.String);
    handles.rowNumber = str2num(handles.rowProp.String);
    handles.columnNumber = str2num(handles.columnProp.String);
    % Default parameters of the Gabor Features
    handles.rowDownsampling = str2num(handles.drowProp.String);
    handles.columnDownsampling = str2num(handles.dcolumnProp.String);
    
    testFiles = dir('BTest/*.jpg');
    resultGabor = zeros(numel(testFiles),1);
    resultGaborNorm = zeros(numel(testFiles),1);
    wBar = waitbar(0,'Please wait...');
    for k=1:numel(testFiles)
        fingerId = getFingerIdFromFileName(testFiles(k).name);
        waitbar(k/numel(testFiles),wBar,strcat('Current Data',num2str(k),'/',num2str(numel(testFiles))));

        path = strcat(testFiles(k).folder,'/',testFiles(k).name);
        imgTest = imread(path);
        imgTest = imresize(imgTest,[100,100]);
        gaborArray = gaborFilterBank(handles.scale,handles.orientation,handles.rowNumber,handles.columnNumber);
        g1 = gaborFeatures(imgTest,gaborArray,handles.rowDownsampling,handles.columnDownsampling);

        trainFiles = dir('BTrain/*.jpg');
        distanceVal = zeros(numel(trainFiles),1);
        distanceValNorm = zeros(numel(trainFiles),1);

        for i = 1:numel(trainFiles)
            img = imread(strcat(trainFiles(i).folder,'/',trainFiles(i).name));
            img = imresize(img,[100,100]);
            gaborArray = gaborFilterBank(handles.scale,handles.orientation,handles.rowNumber,handles.columnNumber);
            g2 = gaborFeatures(img,gaborArray,handles.rowDownsampling,handles.columnDownsampling);

            E_distance = mean(mean(sqrt(sum((g2-g1).^2))));
            ENorm_distance = immse(imgTest,img); 

            distanceVal(i) = E_distance;
            distanceValNorm(i) = ENorm_distance;
        end
        index = find(distanceVal == min(distanceVal));
        matchId = getFingerIdFromFileName(trainFiles(index).name);
        resultGabor(k) = strcmp(fingerId,matchId);

        index = find(distanceValNorm == min(distanceValNorm));
        matchId = getFingerIdFromFileName(trainFiles(index).name);
        resultGaborNorm(k) = strcmp(fingerId,matchId);
    end
    successGabor = mean(resultGabor)*100;
    successGaborNorm = mean(resultGaborNorm)*100;
    set(handles.textProp1,'String', strcat('Gabor Pred Rat: ',num2str(successGabor)));
    set(handles.textProp2,'String', strcat('Immse Pred Rat: ',num2str(successGaborNorm)));
    set(handles.textProp3,'String', '');
    close(wBar)
    
end



% --- Executes on button press in prepareButton.
function prepareButton_Callback(hObject, eventdata, handles)
% hObject    handle to prepareButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 if ~isfolder('FingerprintDB') %Original Train
        errordlg(strcat('FingerprintDB Folder is not found in your current directory,please change your current', ...
       ' location or put the original Fingerprint folder in your current directory.,'),'Error');
 elseif isfolder('BTest')&&isfolder('BTrain')
     errordlg(strcat('The dataset had already been prepared, if it is desired to be prepared again', ...
       ' remove the BTest and BTrain folders.'),'Error');
 else
     classify();
     convertGreyscale();
     msgbox('The dataset preparation phase has been completed successfully', 'Dataset Preparation is completed','help');
 end
    



% --- Executes during object creation, after setting all properties.
function prepareButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to prepareButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function scaleProp_Callback(hObject, eventdata, handles)
% hObject    handle to scaleProp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scaleProp as text
%        str2double(get(hObject,'String')) returns contents of scaleProp as a double


% --- Executes during object creation, after setting all properties.
function scaleProp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scaleProp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function orientationProp_Callback(hObject, eventdata, handles)
% hObject    handle to orientationProp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orientationProp as text
%        str2double(get(hObject,'String')) returns contents of orientationProp as a double


% --- Executes during object creation, after setting all properties.
function orientationProp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orientationProp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rowProp_Callback(hObject, eventdata, handles)
% hObject    handle to rowProp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rowProp as text
%        str2double(get(hObject,'String')) returns contents of rowProp as a double


% --- Executes during object creation, after setting all properties.
function rowProp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rowProp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function columnProp_Callback(hObject, eventdata, handles)
% hObject    handle to columnProp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of columnProp as text
%        str2double(get(hObject,'String')) returns contents of columnProp as a double


% --- Executes during object creation, after setting all properties.
function columnProp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to columnProp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function drowProp_Callback(hObject, eventdata, handles)
% hObject    handle to drowProp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of drowProp as text
%        str2double(get(hObject,'String')) returns contents of drowProp as a double


% --- Executes during object creation, after setting all properties.
function drowProp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to drowProp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dcolumnProp_Callback(hObject, eventdata, handles)
% hObject    handle to dcolumnProp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dcolumnProp as text
%        str2double(get(hObject,'String')) returns contents of dcolumnProp as a double


% --- Executes during object creation, after setting all properties.
function dcolumnProp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dcolumnProp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
