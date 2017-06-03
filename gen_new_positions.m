function char_pos = gen_new_positions(real_positions, padding)
char_pos = zeros(20,4);

%compute height and width from the given pos
width = abs(real_positions(:, 1) - real_positions(:, 3));
height = abs(real_positions(:, 2) - real_positions(:, 4));
original_positions = [real_positions width height];

%starting point
point_start = [padding padding];

for t=1:20
    pos = original_positions(t,:);
    point_end = point_start + [pos(5) pos(6)];
    char_pos(t, :) = [point_start point_end];
    
    %update the current points
    if mod(t, 5)
        point_start(1) = point_start(1) + pos(5) + padding;
    else
        h = max(char_pos(1:t, 4)); %get the max height
        %reset the starting points
        point_start(1) = padding;
        point_start(2) = h + padding;
    end
end