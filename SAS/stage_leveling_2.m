% Stage level tests, 500 Hz, continuous motion:
%%
[filename] = getfullname_;
[pname, fname, ext] = fileparts(filename);
first = loadit([filename]);
%
%%
figure; plot(first.Rotation, [first.Col2_2D_x_deg, first.Col3_2D_y_deg],'.-');legend('X','Y')
title(fname)
%%
