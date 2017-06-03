function h_rect = plot_rect(h_rect, rect_position)
   for t=1:20
       position = points2rect(rect_position(t,:,1));
       h_rect(t) = rectangle('Position', position, 'EdgeColor', 'r');
   end
end