[fname,pname] = uigetfile('*.png');
jens_png = imread([pname,fname]);

%%
jens_map_png_R = jens_png(:,7,1);
jens_map_png_G = jens_png(:,7,2);
jens_map_png_B = jens_png(:,7,3);
jens_map_png = [jens_map_png_R, jens_map_png_G, jens_map_png_B];

for r = size(jens_map_png,1):-1:2
   if all(jens_map_png(r,:)==jens_map_png(r-1,:))
      jens_map_png(r,:) = [];
   end
end


black = all(jens_map_png==0,2);
jens_no_black_map = jens_map_png(~black,:);
jens_no_black_map(end,:) = [];
jens_no_black_map = flipud(jens_no_black_map);
% 
% for r = size(jens_no_black_map,1):-1:2
%    if all(jens_no_black_map(r,:)==jens_no_black_map(r-1,:))
%       jens_no_black_map(r,:) = [];
%    end
% end
jens_no_black_map = double(jens_no_black_map)./255;
%%



