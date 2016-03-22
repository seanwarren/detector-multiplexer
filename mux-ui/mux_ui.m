function varargout = mux_ui(varargin)
% MUX_UI MATLAB code for mux_ui.fig
%      MUX_UI, by itself, creates a new MUX_UI or raises the existing
%      singleton*.
%
%      H = MUX_UI returns the handle to a new MUX_UI or the handle to
%      the existing singleton*.
%
%      MUX_UI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MUX_UI.M with the given input arguments.
%
%      MUX_UI('Property','Value',...) creates a new MUX_UI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mux_ui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mux_ui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mux_ui

% Last Modified by GUIDE v2.5 21-Mar-2016 08:29:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mux_ui_OpeningFcn, ...
                   'gui_OutputFcn',  @mux_ui_OutputFcn, ...
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


% --- Executes just before mux_ui is made visible.
function mux_ui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mux_ui (see VARARGIN)

% Choose default command line output for mux_ui
handles.output = hObject;

delete(instrfindall)
handles.connected = false;
handles.t = timer('TimerFcn', @(obj,evt) AttemptConnection(obj,evt,hObject), 'Period', 1, 'ExecutionMode', 'fixedSpacing');
% Update handles structure
guidata(hObject, handles);
start(handles.t);
uiwait(handles.figure1);
    
function AttemptConnection(obj,evt,hObject)
    [ports,names] = GetSerialDevices();
    handles = guidata(hObject);
    idx = find(strcmp(names,'Arduino Due'),1);
    if ~isempty(idx)
        try
            port = serial(ports{idx},'BaudRate',9600);
            fopen(port);
            fwrite(port,'I');
            pause(0.2);
            ret = fgetl(port);
            disp(ret);
            if strcmp(ret,'Detector Multiplexer v1.2')
                handles.connected = true;
                port.BytesAvailableFcnMode = 'terminator';
                port.BytesAvailableFcn = @(obj,evt) PortCallback(obj,evt,hObject);
                handles.port = port;
                stop(handles.t);
                set(handles.status_string,'String','Connected');
                TryWriting(handles,'S');
                guidata(hObject, handles);
            else
                fclose(port);
            end
            
        catch e
            disp(e)
        end
    end
        
        
function PortCallback(obj,evt,hObject)
    handles = guidata(hObject);
    while obj.BytesAvailable > 0
        tline = fgetl(obj);
        set(handles.status_string,'String',tline);
    end    
    
% UIWAIT makes mux_ui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = mux_ui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
delete(instrfindall);
varargout{1} = 'Done';


% --- Executes on button press in det1_button.
function det1_button_Callback(hObject, eventdata, handles)
% hObject    handle to det1_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    TryWriting(handles,'0');

% --- Executes on button press in det2_button.
function det2_button_Callback(hObject, eventdata, handles)
% hObject    handle to det2_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    TryWriting(handles,'1');


% --- Executes on button press in interleaved_button.
function interleaved_button_Callback(hObject, eventdata, handles)
% hObject    handle to interleaved_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    TryWriting(handles,'2');

    
function TryWriting(handles, str)
    try 
        if handles.connected
            fwrite(handles.port,str);
        end
    catch e
        delete(instrfindall)
        handles.connected = false;
        start(handles.t);
        disp(e)
        set(handles.status_string,'String','Error');
    end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

    % try to put back to channel 1
    TryWriting(handles,'0');

    delete(hObject);
