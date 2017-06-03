function [new_im, new_positions] = gen_new_im(orig_ima, real_positions, padding)
%generate a new image by placing the characters next to each other
%separated by a padding

%zeros value rows index (zvr_idx)
[zvr_idx, ~] = find(real_positions <= 6); 
zvr_idx = unique(zvr_idx);
real_positions(zvr_idx, [1 2]) = 0;
real_positions(zvr_idx, [3 4]) = 50;

%get the new positions
new_positions = gen_new_positions(real_positions, padding);

%build the image
row = max(new_positions(:,4));
col = max(new_positions(:,3));
new_im = ones(row, col)*255;

%add the chars
for t=1:20
    %index for the input image
    in_x1 = real_positions(t,1);
    in_y1 = real_positions(t,2);
    in_x2 = real_positions(t,3);
    in_y2 = real_positions(t,4);
    
    %index for the ouput image
    out_x1 = new_positions(t,1);
    out_y1 = new_positions(t,2);
    out_x2 = new_positions(t,3);
    out_y2 = new_positions(t,4);
        
    %update the output image
    if ~ismember(t, zvr_idx)
        new_im(out_y1:out_y2, out_x1:out_x2) = orig_ima(in_y1:in_y2, in_x1:in_x2)*255;
    else
       new_im(out_y1:out_y2, out_x1:out_x2) = dummy_pic(51)*255;
    end
end