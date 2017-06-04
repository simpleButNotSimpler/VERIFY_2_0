function varargout = verify(varargin)
% VERIFY MATLAB code for verify.fig
%      VERIFY, by itself, creates a new VERIFY or raises the existing
%      singleton*.
%
%      H = VERIFY returns the handle to a new VERIFY or the handle to
%      the existing singleton*.
%
%      VERIFY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VERIFY.M with the given input arguments.
%
%      VERIFY('Property','Value',...) creates a new VERIFY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before verify_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to verify_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help verify

% Last Modified by GUIDE v2.5 04-Jun-2017 23:12:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @verify_OpeningFcn, ...
                   'gui_OutputFcn',  @verify_OutputFcn, ...
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

% --- Executes just before verify is made visible.
function verify_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to verify (see VARARGIN)

% Choose default command line output for verify
handles.output = hObject;

handles.sect_rects = gobjects(1, 20);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes verify wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = verify_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
   
% --- Executes on button press in input_folder_btn.
function input_folder_btn_Callback(hObject, eventdata, handles)
input_folder_name = uigetdir('C:\Users\E113\Documents\WORK\H_IM');
%stop if the user press cancel or close the dialog box
if input_folder_name == 0
    return;
end

handles.input_folder_name = input_folder_name;

set(handles.input_folder_btn, 'Enable', 'off');

initView(hObject, handles);
handles = guidata(hObject);

% set(handles.output_folder_btn, 'Enable', 'on');
guidata(hObject, handles);


%************************************************%
%======================VIEWS=====================%
%************************************************%
%function to initialize the parameters
function initView(hObject, handles)
%retrieve the files
src_im = dir(strcat(handles.input_folder_name, '\*_bw.bmp'));
src_anchor_pos = dir(strcat(handles.input_folder_name, '\*_info.txt'));

%check whether the folders are valid
imcounter = length(src_im);
poscounter = length(src_anchor_pos);
if imcounter == 0 || poscounter == 0 || imcounter - poscounter ~= 0
    errordlg('Invalid folder or number of files', 'error', 'modal');
    set(handles.input_folder_btn, 'Enable', 'on');
    return;
end

%get initial fileindex
fileid = fopen(fullfile(handles.input_folder_name, 'config.txt'), 'r');
if fileid == -1
   index = 1; 
else
   index = fscanf(fileid, '%d');
   fclose(fileid);
end

if isnan(index)
    index = 1;
end

%load dictionary
fid = fopen('dictionary.txt', 'r', 'n', 'UTF-8');
book = textscan(fid, '%s %d %d');
fclose(fid);

dictio.section = book{1, 3};
dictio.page = book{1, 2};
dictio.words = book{1, 1};
handles.dictio = dictio;

%initialize some gui objects
handles.src_im = src_im;
handles.src_anchor_pos = src_anchor_pos;
handles.file_index_max = length(src_im);
handles.file_index = index;
handles.current_section_index = 1;
handles.section_view = 1;

setView(hObject, handles);
handles = guidata(hObject);
set(handles.goto, 'Enable', 'on');
set(handles.char_search_btn, 'Enable', 'on');
set(gcf,'KeyPressFcn',@keypressed_callback);

guidata(hObject, handles);

%function to display the images on the differents views
function setView(hObject, handles)
%display the image at fileindex_current
index = handles.file_index;
handles.char_index = 1;
handles.section_index = 1;

%anchor and char pos and image path
charfname = handles.src_anchor_pos(index).name;
posfname = fullfile(handles.input_folder_name, charfname);
imfname = fullfile(handles.input_folder_name, handles.src_im(index).name);

%colored image filename (imfname)
handles.imfname_colored = strcat(imfname(1:end-7), '.bmp');

%center points of the anchors
[anchors, all_real_positions, main_rect_pos] = pointsFromFile(posfname);

%update info displayed on the gui
set(handles.imfilename_label, 'String', handles.src_im(index).name);
counter = strcat(num2str(index), '/', num2str(handles.file_index_max));
set(handles.counter_label, 'String', counter);


%add page info to the guidata space
handles.anchors = anchors;
handles.all_real_positions = all_real_positions;
handles.main_rect_pos = main_rect_pos;
handles.imfname = imfname;
handles.posfname = posfname;
handles.char_index = 1;
%=====================================================

%plot to char_axis and main axis
orig_ima = imread(imfname);
handles.h_char = imagesc(orig_ima, 'Parent', handles.char_axes);
handles.h_main = imshow(orig_ima, 'Parent', handles.main_axes);

handles.char_rect = rectangle(handles.char_axes, 'Position',[0 0 0 0], 'EdgeColor','r');
handles.selected_char_rect = rectangle(handles.section_axes, 'Position',[0 0 0 0], 'EdgeColor','b');
handles.main_rect = rectangle(handles.main_axes, 'Position', [0 0 0 0], 'EdgeColor','r');

%set the view on the section axis
setSectionView(hObject, handles);
handles = guidata(hObject);

%set callbacks
set(handles.h_char, 'ButtonDownFcn',@adjustBox);
set(handles.h_main, 'ButtonDownFcn',@main_axis_callback);

%set context menu
cm = uicontextmenu(gcf);

% Create child menu items for the uicontextmenu
m1 = uimenu(cm,'Label','Noise removal','Callback',@erase);
m2 = uimenu(cm,'Label','Set position','Callback',@addPos);
m3 = uimenu(cm,'Label','open image (24 bits)','Callback',{@open_im handles, 1});
m4 = uimenu(cm,'Label','open image (1 bit)','Callback',{@open_im, handles, 0});
set(gcf, 'UIContextMenu', cm);

guidata(hObject, handles);

function setSectionView(hObject, handles)
%required data
section_index = handles.section_index;

%=========genrate the current image================
positions = handles.all_real_positions(:,:,section_index);
padding = 5;
positions = [positions(:, [1 2]) - padding, positions(:, [3 4]) + padding];

%gen a new image
[im, new_positions] = gen_new_im(handles.h_char.CData, positions, padding);
handles.new_positions = new_positions;
% handles.gen_im = im;

%------------------------------------
%====================================

%set a rectangle on the main_axes
handles.main_rect.Position = handles.main_rect_pos(section_index,:);

%plot to section_axes
axes(handles.section_axes);
handles.h_section = imagesc(im);
handles.h_section.HitTest = 'off';
handles.section_axes.HitTest = 'off';

colormap default;

%plot the rectangles
rect_position = [new_positions(:, [1 2]) + padding, new_positions(:, [3 4]) - padding];
handles.sect_rects = plot_rect(handles.sect_rects, rect_position);

%set the view on the char axis
handles.char_index = 1;
setCharView(hObject, handles)
handles = guidata(hObject);

set(gcf, 'ButtonDownFcn',@section_axis_callback);
guidata(hObject, handles)

function setCharView(hObject, handles)
char_index = handles.char_index;
section_index = handles.section_index;

char_pos = handles.all_real_positions(char_index,:, section_index);

%set limit on char view
axes(handles.char_axes);
posc = char_pos;
xlim([posc(1)-5 posc(3)+5]);
ylim([posc(2)-5 posc(4)+5]);

%set the position of the draggables on the char_view
handles.char_rect.Position = points2rect(char_pos);

handles.sect_rects(char_index).EdgeColor = [0 1 1];

guidata(hObject, handles);
%======================VIEWS_(END)=====================%


%****************************************************%
%======================POSITIONS=====================%
%****************************************************%
function [anchor, char_pos, main_rect_pos] = pointsFromFile(filepath)
char_pos = zeros(20, 4, 3); % 3 layers position file

%extract the positions
fileid = fopen(filepath, 'r');

%anchor position
file = textscan(fileid, '%d %f %f', 8, 'HeaderLines', 1, 'Whitespace',' \b\t:(,)');
anchor = [file{1, 2} file{1, 3}];

%char1 position
file = textscan(fileid, '%d %d %d %d %d', 20, 'HeaderLines', 4, 'Whitespace',' \b\t:(,)');
char_pos(:,:,1) = [file{1, 2} file{1, 3} file{1, 4} file{1, 5}];

%char2 position
file = textscan(fileid, '%d %d %d %d %d', 20, 'HeaderLines', 3, 'Whitespace',' \b\t:(,)');
char_pos(:,:,2) = [file{1, 2} file{1, 3} file{1, 4} file{1, 5}];

%char3 position
file = textscan(fileid, '%d %d %d %d %d', 20, 'HeaderLines', 3, 'Whitespace',' \b\t:(,)');
char_pos(:,:,3) = [file{1, 2} file{1, 3} file{1, 4} file{1, 5}];

%add shift
anchor = anchor + 1;
char_pos = char_pos + 1;

%main_rect_pos
main_rect_pos(1, :) = [anchor(1, 1) anchor(1, 2) anchor(5, 1)-anchor(1, 1) anchor(2, 2)-anchor(1, 2)];
main_rect_pos(2, :) = [anchor(2, 1) anchor(2, 2) anchor(6, 1)-anchor(2, 1) anchor(3, 2)-anchor(2, 2)];
main_rect_pos(3, :) = [anchor(3, 1) anchor(3, 2) anchor(7, 1)-anchor(3, 1) anchor(4, 2)-anchor(3, 2)];

fclose(fileid);

function position = points2rect(points)
points(1, [1 2]) = points(1, [1 2]) - 0.5;
points(1, [3 4]) = points(1, [3 4]) + 0.5;

%rectangular coodinates
position = [points(1) points(2) points(3)-points(1)  points(4)-points(2)];

function position = rect2points(points)
point_start = points(1, [1 2]);
point_end = point_start + points(1, [3 4]);

%rectangular coodinates
position = [point_start + 0.5, point_end - 0.5];

function [x, y]  = swap(x1, y1)
x = y1;
y = x1;

function idx = closestPoint(char_pos, point)
point = round(point);
temp = char_pos(:,:,1);
temp = [temp(:,1) temp(:,2)];
row = size(temp, 1);
point = repmat(point, row, 1);

point = temp - point;
point = sqrt(sum(point.^2, 2));

[~, idx] = min(point);

%get the closest rectangle
function idx = closestRect(char_pos, point)
point = round(point);
row = size(char_pos, 1);
point = repmat(point, row, 1);

point = [point - char_pos(:,1:2), char_pos(:,3:4) - point];
point = point>=0;
point = sum(point, 2);
idx = find(point == 4);

%save the position of the character in a file
function savePosition(filepath, anchor, pos)
pos = pos-1;
anchor = anchor-1;
%get char unicode
c = strsplit(filepath, {'_', '.'});
deg = c{end-2};
uni3 = c{end-3};
uni2 = c{end-4};
uni1 = c{end-5};

idx = 1:8;
anchor = [idx' anchor]';

idx = 1:20;
pos1 = [idx' pos(:,:,1)]';
pos2 = [idx' pos(:,:,2)]';
pos3 = [idx' pos(:,:,3)]';

%output the positions to a file in the output folder
fileid = fopen(filepath, 'w');
fprintf(fileid, '%s\r\n', '[ Anchor Points ]');
fprintf(fileid, ' %d : (  %6.1f , %6.1f )\r\n', anchor);

fprintf(fileid, '\r\n[ Word Contours ] \r\n unicode_brightness: %s_%s \r\n', uni1, deg);
fprintf(fileid, ' %2d : ( %4d , %4d ) , ( %4d , %4d )\r\n', pos1);

fprintf(fileid, '\r\nunicode_brightness: %s_%s \r\n', uni2, deg);
fprintf(fileid, ' %2d : ( %4d , %4d ) , ( %4d , %4d )\r\n', pos2);

fprintf(fileid, '\r\nunicode_brightness: %s_%s \r\n', uni3, deg);
fprintf(fileid, ' %2d : ( %4d , %4d ) , ( %4d , %4d )\r\n', pos3);

fclose(fileid);
%======================POSITIONS_(END)=====================%


%************************************************%
%====================CALLBACKS===================%
%************************************************%

%callback to open image file
function open_im(hObject, evd, handles, colored)
if colored
    winopen(handles.imfname_colored);
    return
end

winopen(handles.imfname);


%callback for keypress
function keypressed_callback(hObject, eventdata)
handles = guidata(gcbo);

switch eventdata.Key
    case 'return'
        if handles.section_index == 3
            if handles.file_index <= handles.file_index_max-1
                handles.file_index = handles.file_index+1;
                setView(hObject, handles);
            end
            return
        end
        handles.section_index = handles.section_index + 1;
        setSectionView(hObject, handles);
        
    case 'rightarrow'
        char_index = handles.char_index;
        if char_index == 20
            if handles.section_index ~= 3
                handles.section_index = handles.section_index+1;
                setSectionView(hObject, handles);
            else
                if handles.file_index <= handles.file_index_max-1
                    handles.file_index = handles.file_index+1;
                    setView(hObject, handles);
                end
            end
            return
        end
        handles.sect_rects(char_index).EdgeColor = 'r';
        handles.char_index = char_index + 1;
        setCharView(hObject, handles);
        
    case 'leftarrow'
        char_index = handles.char_index;
        if char_index == 1
            if handles.section_index ~= 1
                handles.section_index = handles.section_index - 1;
                setSectionView(hObject, handles);
            else
                if handles.file_index ~= 1
                    handles.file_index = handles.file_index-1;
                    setView(hObject, handles);
                end
            end
            return
        end
        handles.sect_rects(char_index).EdgeColor = 'r';
        handles.char_index = char_index - 1;
        setCharView(hObject, handles);
    case 'e'
        erase(hObject, eventdata);
    case 'o'
        imfname = fullfile(handles.input_folder_name, handles.src_im(handles.file_index).name);
        imfname = strcat(imfname(1:end-7), '.bmp');
        winopen(imfname);
    case 'p'
        char_index = handles.char_index;
        addPos(hObject, eventdata);
        handles = guidata(hObject);
        handles.char_index = char_index;
        setCharView(hObject, handles);
end

%click event on the section axis
function main_axis_callback(hObject, eventdata)
handles = guidata(gcbo);
point = get(handles.main_axes, 'CurrentPoint');
point = [point(1, 1) point(1, 2)];

points_db = rect2points(handles.main_rect_pos(1,:));
points_db = [points_db; rect2points(handles.main_rect_pos(2,:))];
points_db = [points_db; rect2points(handles.main_rect_pos(3,:))];

idx = closestRect(points_db, point);

if isempty(idx)
   return
end

handles.section_index = idx;
setSectionView(hObject, handles);

%click event on the section axis
function section_axis_callback(hObject, eventdata)
handles = guidata(gcbo);
point = get(handles.section_axes, 'CurrentPoint');
point = [point(1, 1) point(1, 2)];
idx = closestRect(handles.new_positions, point);

if isempty(idx)
   return
end

handles.sect_rects(handles.char_index).EdgeColor = 'r';
handles.char_index = idx;

setCharView(hObject, handles);

% --- Executes on button press in goto.
function goto_Callback(hObject, eventdata)
% hObject    handle to goto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles structure with handles and user data (see GUIDATA)
% set(gcf, 'units','normalized','outerposition',[0 0 1 1]);

handles = guidata(hObject);

idx = get(handles.pagenum, 'String');
idx = str2double(idx);
if isnan(idx)
   idx=1; 
end

idx = round(idx);
if idx < 1
    idx = 1;
elseif idx > handles.file_index_max-1
    idx = handles.file_index_max-1;
end

% savePosition(hObject, handles);
handles.file_index = idx;
%save fileindex
fileid = fopen(fullfile(handles.input_folder_name, 'config.txt'), 'w');
fprintf(fileid, '%d', idx);
fclose(fileid);
setView(hObject, handles);

%**************ADJUSTBOX****************%
%function to move the box
function adjustBox(hObject, eventdata)
handles = guidata(gcbo);
idx = handles.char_index;
layer = handles.section_index;

char_pos = handles.all_real_positions(idx,:,layer);
cp = get(handles.char_axes, 'CurrentPoint');
cp = [cp(1, 1) cp(1, 2)];
cp = round(cp);

temp1 = char_pos(1, [1 2]);
temp2 = char_pos(1, [3 4]);

d1 = sqrt(sum((temp1-cp).^2, 2));
d2 = sqrt(sum((temp2-cp).^2, 2));

if d1 > d2
    x = temp1(1);
    y = temp1(2);
else
    x = temp2(1);
    y = temp2(2);
end

set(gcf,'WindowButtonMotionFcn',{@wbm, x, y, handles.char_rect})
set(gcf,'WindowButtonUpFcn',{@wbu, idx, layer})
handles = guidata(hObject);
guidata(hObject, handles);

%on mouse moved
function wbm(hObject,evd, x, y, rect)
% executes while the mouse moves
points = get(gca, 'CurrentPoint');
points = [points(1, 1), points(1, 2)];
points = round(points);

if points(1) > x && points(2) > y
    [points(1), x] = swap(points(1), x);
    [points(2), y] = swap(points(2), y);
elseif points(2) > y
    [points(2), y] = swap(points(2), y);
elseif points(1) > x
    [points(1), x] = swap(points(1), x);
end

%ajust the point to the edge of the image pixels
    points = points-0.5;
    x = x+0.5;
    y= y+0.5;

rect.Position = [points abs(x-points(1)) abs(y-points(2))];

%on mouse released
function wbu(hObject,evd, idx, layer)
handles = guidata(hObject);
% executes when the mouse button is released
new_rect_pos = handles.char_rect.Position;
old_rect_pos = points2rect(handles.all_real_positions(idx,:,layer));

new_points = rect2points(new_rect_pos);
old_points = rect2points(old_rect_pos);

displacement = new_points - old_points;

old_mod_rect_pos = handles.sect_rects(idx).Position;
new_mod_points = rect2points(old_mod_rect_pos) + displacement;

%update the positions arrays
handles.all_real_positions(idx,:,layer) = new_points;

handles.sect_rects(idx).Position = points2rect(new_mod_points);
handles.new_positions(idx,:) = new_mod_points;

%save the position
savePosition(handles.posfname, handles.anchors, handles.all_real_positions);

set(gcf,'WindowButtonMotionFcn','')
set(gcf,'WindowButtonUpFcn','') 
guidata(hObject, handles);
%**************ADJUSTBOX_(END)****************%


%**************ERASE****************%
function erase(hObject, evd)
handles = guidata(hObject);
imfname_bw = handles.imfname;

%colored image filename (imfname)
imfname = handles.imfname_colored;

figure;
handles.h_im = imshow(imfname);

%get and apply the xylimit from handles.char_axis to the ca
ax = ancestor(handles.h_im, 'axes');
ax.XLim = handles.char_axes.XLim;
ax.YLim = handles.char_axes.YLim;

rect = rectangle('Position', [0 0 0 0], 'EdgeColor', 'r');
setappdata(gcf, 'handles', handles);

%set callback on the figure
set(gcf,'WindowButtonDownFcn',{@erase_wbd, rect, imfname, imfname_bw});
set(gcf,'CloseRequestFcn',{@erase_close});

%erase_wbd function
function erase_wbd(hObject, eventdata, rect, imfname, imfname_bw)
points = get(gca, 'CurrentPoint');
points = [points(1, 1), points(1, 2)];

x=round(points(1));
y=round(points(2));

set(gcf,'WindowButtonMotionFcn',{@erase_wbm, x, y, rect})
set(gcf,'WindowButtonUpFcn',{@erase_wbu, rect, imfname, imfname_bw})

%erase_wbm function
function erase_wbm(h,evd, x, y, rect)
% executes while the mouse moves
points = get(gca, 'CurrentPoint');
points = [points(1, 1), points(1, 2)];
points = round(points);

if points(1) > x && points(2) > y
    [points(1), x] = swap(points(1), x);
    [points(2), y] = swap(points(2), y);
elseif points(2) > y
    [points(2), y] = swap(points(2), y);
elseif points(1) > x
    [points(1), x] = swap(points(1), x);
end

points = points-0.5;
x = x + 0.5;
y= y + 0.5;

rect.Position = [points abs(x-points(1)) abs(y-points(2))];

%erase_wbu function
function erase_wbu(hObject,evd, rect, imfname, imfname_bw)
% executes when the mouse button is released
handles = getappdata(gcf, 'handles');

pos = rect.Position;
x1 = pos(1)+0.5;
y1 = pos(2)+0.5;
x2 = x1 + pos(3)-1;
y2 = y1 + pos(4)-1;

%updte the images
handles.h_char.CData(y1:y2, x1:x2) = 1; %binary image

%colored image
handles.h_im.CData(y1:y2, x1:x2, 1) = 255;
handles.h_im.CData(y1:y2, x1:x2, 2) = 255;
handles.h_im.CData(y1:y2, x1:x2, 3) = 255;

imwrite(handles.h_im.CData, imfname);
imwrite(handles.h_char.CData, imfname_bw);

set(gcf,'WindowButtonMotionFcn','')
set(gcf,'WindowButtonUpFcn','')
setappdata(gcf, 'handles', handles);

function erase_close(hObject,evd)
handles = getappdata(gcf, 'handles');
delete(gcf);
guidata(verify, handles);
%**************ERASE(END)****************%


%**************ADDPOS****************%
function addPos(hObject, evt)
handles = guidata(hObject);

%required data
char_index = handles.char_index;
section_index = handles.section_index;

%display the image
figure, handles.edited_im = imshow(handles.h_char.CData);

%AXIS LIMITS
%section limit
section_pos = handles.main_rect_pos(section_index, :);
xlim([section_pos(1) section_pos(3)+section_pos(1)-450]);
ylim([section_pos(2) section_pos(2)+section_pos(4)-100]);

%get a reference point from the user
try
    [x, y] = ginput;
catch me
    return;
end
x = x(end);
y = y(end);
limit = [round([x y])-50 round([x y])+50];
handles.all_real_positions(char_index,:,section_index) = limit;

x_limit = [limit(1)-2 limit(3)+2];
y_limit = [limit(2)-2 limit(4)+2];
xlim(x_limit);
ylim(y_limit);

%draw rectangle
pos1 = [limit(1) limit(2)]-0.5;
pos2 = [abs(limit(1)-limit(3)) abs(limit(2)-limit(4))] + 1;
handles.adjusted_rect = rectangle('Position', [pos1 pos2],'EdgeColor', 'r');

colormap gray;

title(gca, 'Box Adjustment');

setappdata(gcf, 'handles', handles);

%set callback on the figure
set(gcf,'WindowButtonDownFcn',{@addpos_wbd, handles.adjusted_rect});
set(gcf,'CloseRequestFcn',{@addpos_app_close});

%addpos_app_wbd function
function addpos_wbd(hObject, eventdata, rect)

%==========char_pos===========
pos = rect.Position;
x1 = pos(1)+0.5;
y1 = pos(2)+0.5;
x2 = x1 + pos(3)-1;
y2 = y1 + pos(4)-1;
char_pos = [x1 y1 x2 y2];

cp = get(gca, 'CurrentPoint');
cp = [cp(1, 1) cp(1, 2)];
cp = round(cp);

temp1 = char_pos(1, [1 2]);
temp2 = char_pos(1, [3 4]);

d1 = sqrt(sum((temp1-cp).^2, 2));
d2 = sqrt(sum((temp2-cp).^2, 2));

if d1 > d2
    x = temp1(1);
    y = temp1(2);
else
    x = temp2(1);
    y = temp2(2);
end

set(gcf,'WindowButtonMotionFcn',{@addpos_wbm, x, y, rect})
set(gcf,'WindowButtonUpFcn',{@addpos_wbu})

%addpos_app_wbm function
function addpos_wbm(h,evd, x, y, rect)
% executes while the mouse moves
points = get(gca, 'CurrentPoint');
points = [points(1, 1), points(1, 2)];
points = round(points);

if points(1) > x && points(2) > y
    [points(1), x] = swap(points(1), x);
    [points(2), y] = swap(points(2), y);
elseif points(2) > y
    [points(2), y] = swap(points(2), y);
elseif points(1) > x
    [points(1), x] = swap(points(1), x);
end

points = points-0.5;
x = x + 0.5;
y= y + 0.5;

rect.Position = [points abs(x-points(1)) abs(y-points(2))];

%addpos_app_wbu function
function addpos_wbu(hObject,evd)
% executes when the mouse button is released
handles = getappdata(gcf, 'handles');

pos = handles.adjusted_rect.Position;
pos = rect2points(pos);
x1 = pos(1);
y1 = pos(2);
x2 = pos(3);
y2 = pos(4);

%update the position in char_pos
section_index = handles.section_index;
char_index = handles.char_index;
handles.all_real_positions(char_index,:,section_index) = [x1 y1 x2 y2];

%save positions
savePosition(handles.posfname, handles.anchors, handles.all_real_positions);

set(gcf,'WindowButtonMotionFcn','')
set(gcf,'WindowButtonUpFcn','')
setappdata(gcf, 'handles', handles);

function addpos_app_close(hObject,evd)
handles = getappdata(gcf, 'handles');
delete(gcf);
guidata(verify, handles);
setSectionView(verify, handles)
%**************ADDPOS_(END)****************%

%====================CALLBACKS_(END)===================%


%*******************************************************%
%====================OBJECT_CREATIONS===================%
%*******************************************************%
% --- Executes on key press with focus on pagenum and none of its controls.
function pagenum_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to pagenum (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
switch eventdata.Key
    case 'return'
        goto_Callback(verify, eventdata);
end

% --- Executes during object creation, after setting all properties.
function pagenum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pagenum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%====================OBJECT_CREATIONS_(END)===================%

function char_name_box_Callback(hObject, eventdata, handles)
% hObject    handle to char_name_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of char_name_box as text
%        str2double(get(hObject,'String')) returns contents of char_name_box as a double


% --- Executes during object creation, after setting all properties.
function char_name_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to char_name_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in char_search_btn.
function char_search_btn_Callback(hObject, eventdata, handles)
searched_char = handles.char_name_box.String;
[page, section] = getCharId(handles.dictio, searched_char);

if isempty(page)
    return;
end

%display the page and section
handles.file_index = page;
setView(hObject, handles);
handles = guidata(hObject);

handles.section_index = section;
setSectionView(hObject, handles);
