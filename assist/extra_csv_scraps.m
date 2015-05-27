% ch1 = ancload;
% ch2 = ancload;
sumry = ancload;

figure; 

%%
t = 1;
% %%
% s1(1) = subplot(2,1,1);
% semilogy([ch1.vars.wnum.data;ch2.vars.wnum.data],...
%    [ch1.vars.mean_rad.data(:,t);ch2.vars.mean_rad.data(:,t)], 'r-',...
%    [sumry.vars.wnum1.data;sumry.vars.wnum2.data], ...
%    [sumry.vars.ch1_mean_radiance.data(:,t) ;sumry.vars.ch2_mean_radiance.data(:,t)], 'k-',...
%    [677;702;987;2297;2284;2512], [sumry.vars.ch1_surface_layer_radiance.data(t);...
%    sumry.vars.ch1_elevated_layer_radiance.data(t);sumry.vars.ch1_window_radiance.data(t);...
%    sumry.vars.ch2_surface_layer_radiance.data(t);sumry.vars.ch2_elevated_layer_radiance.data(t);...
%    sumry.vars.ch2_window_radiance.data(t)], 'o');
% title(['Radiance t=',num2str(t), '  ',datestr(ch1.time(t), 'HH:MM:SS')]);
% 
% s1(2) = subplot(2,1,2);
% plot([sumry.vars.wnum1.data;sumry.vars.wnum2.data], ...
%    [sumry.vars.ch1_sky_temp.data(:,t) ;sumry.vars.ch2_sky_temp.data(:,t)], 'b.',...
%    [677;702;987;2297;2284;2512], [sumry.vars.ch1_surface_layer_BT.data(t);...
%    sumry.vars.ch1_elevated_layer_BT.data(t);sumry.vars.ch1_window_BT.data(t);...
%    sumry.vars.ch2_surface_layer_BT.data(t);sumry.vars.ch2_elevated_layer_BT.data(t);...
%    sumry.vars.ch2_window_BT.data(t)], 'o');;
% title(['Brightness temp']);
% linkaxes(s1,'x');
% t = t+1;
% if t > length(ch1.time)
%    t = 1;
% end
%%
ndims = fieldnames(sumry.vars);
for n = length(ndims):-1:1
   if length(sumry.vars.(ndims{n}).dims)<2
      ndims(n)=[];
   end
end
%%
figure;
for n = length(ndims):-1:1
   if strcmp(ndims{n}(1:3),'ch1')&&isempty(strfind(ndims{n},'offset'))
      ok = false; t= 0;
      ch1 = ndims{n};
      ch2 = strrep(ch1,'ch1','ch2');
      while ~ok
         for t = 1:50:length(sumry.time)
            plot(sumry.vars.wnum1.data, sumry.vars.(ch1).data(:,[t:t+50]), '.b-',...
               sumry.vars.wnum2.data, sumry.vars.(ch2).data(:,[t:t+50]), '.r-');
            title(ch2,'interp','none');
            pause(.5);
         end
         k = menu('Repeat or next?','Repeat','Next');
         if k == 2
            ok = true;
         end
      end
   end
end