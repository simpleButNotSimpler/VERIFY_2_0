% read the positions
[anchors, real_positions, main_rect_pos] = pointsFromFile('fpos.txt');

%set padding, gen new pos
positions = real_positions(:,:,2);
padding = 5;
positions = [positions(:, [1 2]) - padding, positions(:, [3 4]) + padding];

%gen a new image
orig_ima = imread('fim.bmp');
[new_im, new_positions] = gen_new_im(orig_ima, positions, padding);

imagesc(new_im)

%plot rectangle
rect_position = [new_positions(:, [1 2]) + padding, new_positions(:, [3 4]) - padding];
h_rect = gobjects(1, 20);
plot_rect(h_rect, rect_position);

