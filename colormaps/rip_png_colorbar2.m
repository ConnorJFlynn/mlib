function cbar = rip_png_colorbar2;

[filename] = getfullname('*.png');
cbar = imread(filename);
%%
figure_(2001); image(cbar);grid('off');zoom('on')
title({'Zoom into the image to select a narrow strip of the color range you want.'})
OK = menu({'Select OK when done.';'Hint: use horizontal or vertical zoom'}, 'OK')
v = axis;
cbar = cbar(floor(v(3)):ceil(v(4)), max([floor(v(1)),1]):min([ceil(v(2)),size(cbar,2)]), :);
image(cbar);grid('off'); zoom('on');
title('Want to remove lines or exclude any colors?')
done = false;
igs = menu('Check the image.  Select lines or colors to ignore?','Yes', 'No, done');
if igs ==2
    done = true;
end
y = [];

while ~done

    if isavar('cbar_')
        igs = menu({'First, zoom as desired';'Then, select a button below'},'Select colors to ignore...','UNDO','Done');
        if igs == 2
            cbar = cbar_;
            image(cbar);grid('off'); zoom('on');            
        elseif igs==3
            done = true;
        end
    else
       title({'Zoom in until able to easily select colors to exclude...', '... And then click OK'})        
        igs = menu({'First, zoom as desired';'Then, select a button below'},'OK, select color to ignore','I''m all Done');
        if igs==2
            done = true;
        end
    end 
    selecting = true; v = axis;
    if igs==1
        while selecting
            if isavar('cbar_')
                title('UNDO deletion?');
                un = menu('Is it OK?','Yes','No, UNDO');
                if un == 2
                    cbar = cbar_;
                    image(cbar);grid('off'); zoom('on');axis(v);
                end
                title('Drag, zoom in or out, or reset');
                OK = menu('Reset zoom limits?','Reset limits','Continue...'); 
                if OK==1 
                    image(cbar);grid('off'); zoom('on'); 
                    menu('Now zoom in as desired','OK');
                    v = axis;
                end
            end
           
        title({'Left-click on any color to ignore it.'; 'Right-click when DONE selecting'})
        button = 1;
        while button == 1
            [~,y(end+1),button] = ginput(1);
        end
        y(end) = []; y = unique(round(y));        
        cbar_ = cbar;
        for yi = fliplr(y)
            top = size(cbar,1); ci = top;
            while ci > 0
                if all(cbar(yi,1,:)==cbar(ci,1,:))
                    cbar(ci,:,:) = [];
                end
                ci = ci -1;
            end
        end
        if isempty(y)
            selecting = false;
        end
        y = [];
        v = axis; image(cbar);grid('off'); zoom('on');axis(v); 
        end
    end
end

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
% figure; done = false;
% while ~done
%     image(cbarx); grid('off')
%     dun = menu('Select option','Delete from front','Delete from back','Done');
%     if dun==1
%         cbarx(:,1,:) = [];
%     elseif dun==2
%         cbarx(:,end,:) = [];
%     else
%         done = true;
%     end
% end
% 
% border = menu('Zoom in to pick border color to ignore?', 'Yes','No');
% if border==1
%     zoom('on')
%     menu('Select "OK" when done zooming, then pick the color to ignore.','OK');
%     [x,~] = ginput(1); x = round(x);
%     for r = size(cbarx,2):-1:1
%         if all(cbarx(:,r,:)==cbarx(1,x,:))
%             cbarx(:,r,:) = [];
%         end
%     end
% end
cbarx = squeeze(cbarx);
cbar = double(cbarx)./255; % This normalization assume RGB values from 0-255
return
%%



