function position = points2rect(points)
points(1, [1 2]) = points(1, [1 2]) - 0.5;
points(1, [3 4]) = points(1, [3 4]) + 0.5;

%rectangular coodinates
position = [points(1) points(2) points(3)-points(1)  points(4)-points(2)];