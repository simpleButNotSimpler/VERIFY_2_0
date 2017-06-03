function pic = dummy_pic(k)
d = ones(1, k);
md = diag(d);
pic = md + rot90(md);

%center point
mid = (k+1) / 2;
pic(mid,mid) = 1;
pic(2:end-1, [2 end-1]) = 1;
pic([2 end-1], 2:end-1) = 1;