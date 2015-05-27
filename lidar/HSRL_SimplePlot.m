function varargout = HSRL_SimplePlot(varargin)
% HSRL_SIMPLEPLOT M-file for HSRL_SimplePlot.fig
%      HSRL_SIMPLEPLOT, by itself, creates a new HSRL_SIMPLEPLOT or raises the existing
%      singleton*.
%
%      H = HSRL_SIMPLEPLOT returns the handle to a new HSRL_SIMPLEPLOT or the handle to
%      the existing singleton*.
%
%      HSRL_SIMPLEPLOT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HSRL_SIMPLEPLOT.M with the given input
%      arguments.
%
%      HSRL_SIMPLEPLOT('Property','Value',...) creates a new HSRL_SIMPLEPLOT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HSRL_SimplePlot_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HSRL_SimplePlot_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help HSRL_SimplePlot

% Last Modified by GUIDE v2.5 30-Aug-2007 16:12:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HSRL_SimplePlot_OpeningFcn, ...
                   'gui_OutputFcn',  @HSRL_SimplePlot_OutputFcn, ...
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

% --- Executes just before HSRL_SimplePlot is made visible.
function HSRL_SimplePlot_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to HSRL_SimplePlot (see VARARGIN)

% Choose default command line output for HSRL_SimplePlot
handles.output = hObject;
handles.dataflag = 0;
% Update handles structure
guidata(hObject, handles);
plot3d_Callback(hObject, eventdata, handles);
set(handles.read_data_button, 'visible', 'off')
set(handles.log_text, 'visible', 'off')
set(handles.log_text2, 'visible', 'off')

% --- Outputs from this function are returned to the command line.
function varargout = HSRL_SimplePlot_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in plotpushbutton.
function plotpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to plotpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, handles);
axes(handles.axes1);
cla; 
set(handles.log_text, 'visible', 'off');    % These display the log notes
set(handles.log_text2, 'visible', 'off');

xdata = handles.xdata; % Get the data
ydata = handles.ydata;
zdata = handles.zdata;
znames = get(handles.z_axis_popupmenu, 'String'); zindex = get(handles.z_axis_popupmenu, 'Value');
zname = znames{zindex}; % Will be used to name

c_min_edit = str2num(get(handles.c_min_edit, 'string'));    % Get the ranges
c_max_edit = str2num(get(handles.c_max_edit, 'string'));
x_min_edit = str2num(get(handles.x_min_edit, 'string'));
x_max_edit = str2num(get(handles.x_max_edit, 'string'));
y_min_edit = str2num(get(handles.y_min_edit, 'string'));
y_max_edit = str2num(get(handles.y_max_edit, 'string'));

DataTitle = prettyName(zname);    % Changes zname to a human readable name or removes
                                  % underscores if it fails to recognize it.
                                  
if get(handles.Log_Plot_checkbox, 'value')==0   % If log box is not checked
    if get(handles.plot3d, 'value')==1          % If 3d-colorplot is checked
        imagesc(xdata, ydata, zdata');
        set(gca, 'ydir', 'normal');
        caxis([c_min_edit c_max_edit]); cbar = colorbar;
        xlabel('UTC Hour');
        title(DataTitle);
    else                                        % If no color plot, do line plot
        index = floor(get(handles.slider2, 'value'))+1; % Slider starts at zero.
        plot(zdata(index,:), ydata, 'linewidth', 2);
        xlabel(DataTitle);
        title(['Profile time = ', num2str(xdata(index)), ' UTC']);
        grid;
    end
else                                            % If log plot is checked
    if get(handles.plot3d, 'value')==1
        set(handles.log_text, 'visible', 'on'); % Display notes
        set(handles.log_text2, 'visible', 'on');
        imagesc(xdata, ydata, real(log10(zdata')));   % Only the real part
        set(gca, 'ydir', 'normal');
        caxis([c_min_edit c_max_edit]); cbar = colorbar;
        xlabel('UTC Hour');
        title(DataTitle);
        
        format short e                  % Stolen from John's code
        out = get(cbar,'YTickLabel');   % makes the color bar readable
        out=str2num(out);               % on log scales
        out =10.^out;
        set(cbar,'YTickLabel',out);
        format
    else                                % log line plot
        index = floor(get(handles.slider2, 'value'))+1; % Slider starts at zero.
        semilogx(zdata(index,:), ydata, 'linewidth', 2);
        xlabel(DataTitle);
        title(['Profile time = ', num2str(xdata(index)), ' UTC']);
        grid;
    end
end
ylim([y_min_edit y_max_edit]);  % These never change so are out of the loop
xlim([x_min_edit x_max_edit]);  % For less clutter
ylabel('Altitude [m]');

guidata(hObject, handles);

% --- Executes on button press in plot2d.
function plot2d_Callback(hObject, eventdata, handles)
% hObject    handle to plot2d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plot2d
set(handles.plot3d, 'value', 0.0); % default
set(handles.plot2d, 'value', 1.0); % default
set(handles.c_min_edit, 'visible', 'off')
set(handles.c_max_edit, 'visible', 'off')
set(handles.color_min, 'visible', 'off')
set(handles.color_max, 'visible', 'off')
set(handles.slider2, 'visible', 'on')
if handles.dataflag==1
    SetLimits(hObject, eventdata, handles);
    plotpushbutton_Callback(hObject, eventdata, handles)
else
end
guidata(hObject, handles);

% --- Executes on button press in plot3d.
function plot3d_Callback(hObject, eventdata, handles)
% hObject    handle to plot3d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plot3d
set(handles.plot3d, 'value', 1.0); % default
set(handles.plot2d, 'value', 0.0); % default
set(handles.c_min_edit, 'visible', 'on')
set(handles.c_max_edit, 'visible', 'on')
set(handles.color_min, 'visible', 'on')
set(handles.color_max, 'visible', 'on')
set(handles.slider2, 'visible', 'off')
if handles.dataflag==1
    SetLimits(hObject, eventdata, handles);
    plotpushbutton_Callback(hObject, eventdata, handles)
else
end


% --- Executes on selection change in x_axis_popupmenu.
function x_axis_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to x_axis_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns x_axis_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from x_axis_popupmenu

% --- Executes during object creation, after setting all properties.
function x_axis_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x_axis_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in y_axis_popupmenu.
function y_axis_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to y_axis_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns y_axis_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from y_axis_popupmenu


% --- Executes during object creation, after setting all properties.
function y_axis_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y_axis_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in getFile.
function getFile_Callback(hObject, eventdata, handles)
% hObject    handle to getFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename pathname] = uigetfile('*.hdf','Select HDF File');
handles.pathname = pathname;            % Get the file name and path
handles.filename = filename;

%Update filename edit field
set(handles.filename_text,'String',filename);

%Get HDF info
S = hdfinfo([pathname,filename]);

%Read in variable names
names = {S.SDS.Name};

for i=1:length(S.SDS);  % This will only plot 2d data (no engineering data)
    ranks(i)=S.SDS(i).Rank;
end

zindex = find(strcmp(names(ranks==2), '532_bsc'));      % Sets 532 bsc as default
set(handles.z_axis_popupmenu,'String',names(ranks==2))  % in the listbox

if(~isempty(zindex))                                    % if it is there
    set(handles.z_axis_popupmenu,'value',zindex)
    handles = read_data_button_Callback(hObject, eventdata, handles); % reads in data too.
end
guidata(hObject, handles);

function filename_text_Callback(hObject, eventdata, handles)
% hObject    handle to filename_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filename_text as text
%        str2double(get(hObject,'String')) returns contents of filename_text as a double

% --- Executes during object creation, after setting all properties.
function filename_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filename_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in z_axis_popupmenu.
function z_axis_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to z_axis_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns z_axis_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from z_axis_popupmenu
guidata(hObject, handles);
handles = read_data_button_Callback(hObject, eventdata, handles); % This was a dirty trick but seemed to work.
guidata(hObject, handles);
plotpushbutton_Callback(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function z_axis_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z_axis_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function x_min_edit_Callback(hObject, eventdata, handles)
% hObject    handle to x_min_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of x_min_edit as text
%        str2double(get(hObject,'String')) returns contents of x_min_edit as a double

guidata(hObject, handles);
plotpushbutton_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function x_min_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x_min_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function x_max_edit_Callback(hObject, eventdata, handles)
% hObject    handle to x_max_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of x_max_edit as text
%        str2double(get(hObject,'String')) returns contents of x_max_edit as a double
guidata(hObject, handles);
plotpushbutton_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function x_max_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x_max_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function y_min_edit_Callback(hObject, eventdata, handles)
% hObject    handle to y_min_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of y_min_edit as text
%        str2double(get(hObject,'String')) returns contents of y_min_edit as a double
guidata(hObject, handles);
plotpushbutton_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function y_min_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y_min_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function y_max_edit_Callback(hObject, eventdata, handles)
% hObject    handle to y_max_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of y_max_edit as text
%        str2double(get(hObject,'String')) returns contents of y_max_edit as a double
guidata(hObject, handles);
plotpushbutton_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function y_max_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y_max_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function c_min_edit_Callback(hObject, eventdata, handles)
% hObject    handle to c_min_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of c_min_edit as text
%        str2double(get(hObject,'String')) returns contents of c_min_edit as a double
guidata(hObject, handles);
plotpushbutton_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function c_min_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to c_min_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function c_max_edit_Callback(hObject, eventdata, handles)
% hObject    handle to c_max_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of c_max_edit as text
%        str2double(get(hObject,'String')) returns contents of c_max_edit as a double
guidata(hObject, handles);
plotpushbutton_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function c_max_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to c_max_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in read_data_button.
function handles = read_data_button_Callback(hObject, eventdata, handles)
% hObject    handle to read_data_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Read in the parameter name/index from the selector menu
znames = get(handles.z_axis_popupmenu, 'String'); zindex = get(handles.z_axis_popupmenu, 'Value');
zname = znames{zindex};

pathname = handles.pathname;
filename = handles.filename;
%read in the data of interest
xdata = hdfread([pathname filename],'gps_time');
ydata = hdfread([pathname filename],'Altitude');
zdata = hdfread([pathname filename],zname);
handles.xdata = xdata;
handles.ydata = ydata;
handles.zdata = zdata;
% Choose the limits based on the max/min of the data
SetLimits(hObject, eventdata, handles) %*This is a function near the end of the code as I call it several times
set(handles.slider2, 'min', 0);  % set slider min

startindex = find(sum(isnan(zdata),2)<length(ydata),1);  % Start the slider off at first real data because
if ~isempty(startindex)                                  % The first 100 profiles are not good data 
    set(handles.slider2, 'value', startindex);
else
    set(handles.slider2, 'value', 0);
end

set(handles.slider2, 'max', length(xdata)-1);
set(handles.slider2, 'max', length(xdata)-1);
set(handles.slider2, 'sliderstep', [1/length(xdata), 0.1]);
% set the slider step to 1 file (1 / length(xdata)) or 10%).  

handles.dataflag = 1;   % This was a flag to tell if the data had been read in or not.
                        % It's not very useful anymore because I read in
                        % the data upon file selection and took away the
                        % "read data" button.

set(handles.DateText, 'string', ['HSRL - ',filename(1:8)]);     % Date/Title
set(handles.DateText, 'fontsize', 12, 'fontweight', 'bold');    % near top of GUI

guidata(hObject, handles);

% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
guidata(hObject, handles);
plotpushbutton_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function []=SetLimits(hObject, eventdata, handles)
% This function sets the limits for plotting.  It is called whenever a new
% data set is selected, the 2d/3d radiobuttons are pushed, or the log
% checkbox.

xdata = handles.xdata;
ydata = handles.ydata;
zdata = handles.zdata;

set(handles.y_min_edit, 'string', '0');
set(handles.y_max_edit, 'string', num2str(max(ydata)));

if get(handles.Log_Plot_checkbox, 'value')==0  % If no log
    if get(handles.plot3d, 'value')==1         % If 3d
        set(handles.x_min_edit, 'string', num2str(min(xdata)));
        set(handles.x_max_edit, 'string', num2str(max(xdata)));
        set(handles.c_min_edit, 'string', '0');
        set(handles.c_max_edit, 'string', num2str(max(max(zdata))));
    else                                        % If 2d
        set(handles.x_min_edit, 'string', '0');
        set(handles.x_max_edit, 'string', num2str(max(max(zdata))));
    end
else
    if get(handles.plot3d, 'value')==1
        set(handles.x_min_edit, 'string', num2str(min(xdata)));
        set(handles.x_max_edit, 'string', num2str(max(xdata)));
        set(handles.c_min_edit, 'string', num2str(real(log10(min(min(zdata(zdata>0)))))));
        set(handles.c_max_edit, 'string', num2str(real(log10(max(max(zdata))))));
    else
        set(handles.x_min_edit, 'string', num2str(min(min(zdata(zdata>0)))));
        set(handles.x_max_edit, 'string', num2str(max(max(zdata))));
    end
end





% --- Executes on button press in Log_Plot_checkbox.
function Log_Plot_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to Log_Plot_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Log_Plot_checkbox
SetLimits(hObject, eventdata, handles);
guidata(hObject, handles);
plotpushbutton_Callback(hObject, eventdata, handles)


function dataname = prettyName(zname);

  
    %Data name conversion
    bsr532 = {'532_bsr', '532_bsr_cloud_screened'};
    bsc532 = {'532_bsc','532_bsc_Sa','532_bsc_cloud_screened'};
    attnbsc532 = {'532_total_attn_bsc','532_total_attn_bsc_cloud_screened'};
    bsr1064 = {'1064_bsr','1064_bsr_cloud_screened'};
    bsc1064 = {'1064_bsc','1064_bsc_cloud_screened'};
    attnbsc1064 = {'1064_total_attn_bsc','1064_total_attn_bsc_cloud_screened'};
    dep532 = {'532_dep'};
    dep1064 = {'1064_dep'};
    aer_dep532 = {'532_aer_dep'};
    aer_dep1064 = {'1064_aer_dep'};
    Sa_532 = {'Sa_532'};
    WVD_1064_532 = {'WVD_1064_532'};
    ext532 = {'532_ext'};
    ext1064 = {'1064_ext'};

    
    dataname = zname;
    if ismember(dataname,bsr532)
        dataname = 'Aerosol Scattering Ratio (532nm)';
    elseif ismember(dataname,bsr1064)
        dataname = 'Aerosol Scattering Ratio (1064nm)';
    elseif ismember(dataname,bsc532)
        dataname = 'Aerosol Backscatter (km^{-1}sr^{-1})(532nm)';
    elseif ismember(dataname,attnbsc532)
        dataname = 'Aerosol Attenuated Backscatter (km^{-1}sr^{-1})(532nm)';
    elseif ismember(dataname,bsc1064)
        dataname = 'Aerosol Backscatter (km^{-1}sr^{-1})(1064nm)';
    elseif ismember(dataname,attnbsc1064)
        dataname = 'Aerosol Attenuated Backscatter (km^{-1}sr^{-1})(1064nm)';
    elseif ismember(dataname,dep532)
        dataname = 'Total Depolarization Ratio (532nm)';
    elseif ismember(dataname,dep1064)
        dataname = 'Total Depolarization Ratio (1064nm)';
    elseif ismember(dataname,aer_dep532)
        dataname = 'Aerosol Depolarization Ratio (532nm)';
    elseif ismember(dataname,aer_dep1064)
        dataname = 'Aerosol Depolarization Ratio (1064nm)';
    elseif ismember(dataname,Sa_532)
        dataname = 'Extinction/Backscatter Ratio (sr^{-1})';
    elseif ismember(dataname,WVD_1064_532)
        dataname = 'Aerosol Wavelength Dependence (1064nm/532nm)';
    elseif ismember(dataname,ext532)
        dataname = 'Aerosol Extinction (km^{-1}) (532nm)';
    elseif ismember(dataname,ext1064)
        dataname = 'Aerosol Extinction (km^{-1}) (1064nm)';
    end;

    dataname(find(dataname=='_'))=' ';



