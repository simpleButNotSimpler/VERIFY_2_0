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