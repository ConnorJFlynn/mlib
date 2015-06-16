function cbar = rip_png_colorbar;

[filename] = getfullname('*.png');
cbar = imread(filename);
%% 
figure; image(cbar);
title('zoom into the image to select only a narrow strip of the color range you want.')
OK = menu({'Select when done zooming';'Hint: use horizontal or vertical zoom'}, 'OK')
v = axis;
cbar = cbar(floor(v(3)):ceil(v(4)), max([floor(v(1)),1]):min([ceil(v(2)),size(cbar,2)]), :);

xy = size(cbar);
if xy(1)>xy(2)
    cbar = squeeze(cbar(:,1,:));
else
    cbar = squeeze(cbar(1,:,:));
end

for r = size(cbar,1):-1:2
   if all(cbar(r,:)==cbar(r-1,:))
      cbar(r,:) = [];
   end
end

cbarx(1,:,:) = cbar;
figure; done = false;
while ~done
image(cbarx)
dun = menu('Select option','Delete from front','Delete from back','Done');
if dun==1 
    cbarx(:,1,:) = [];
elseif dun==2
    cbarx(:,end,:) = [];
else
    done = true;
end
end

border = menu('Zoom in to pick border color to ignore?', 'Yes','No');
if border==1
    zoom('on')
    menu('Select "OK" when done zooming, then pick the color to ignore.','OK');
    [x,~] = ginput(1); x = round(x);
for r = size(cbarx,2):-1:1
   if all(cbarx(:,r,:)==cbarx(1,x,:))
      cbarx(:,r,:) = [];
   end
end
end
cbar = squeeze(cbarx);   
cbar = double(cbarx)./255; % This normalization assume RGB values from 0-255
return
%%



