function sashe = proc_sashe_1s(sashe);
% sashe = proc_sashe_1s(sashe);
% processes a single sashe 1s measurement cycle
% 
%% 

sashe.good_pix = sashe.nm>=350&sashe.nm<1100;
dark_T = sashe.Shutter_open_TF==0;
hemisp = sashe.Experiment_element_ID==3|sashe.Experiment_element_ID==12;
sides = sashe.Experiment_element_ID==5|sashe.Experiment_element_ID==7|...
   sashe.Experiment_element_ID==14|sashe.Experiment_element_ID==16;;
sides_ii = find(sides);
blocked = sashe.Experiment_element_ID==9|sashe.Experiment_element_ID==18;
one = sashe.Experiment_element_ID<12;
%%
figure(1); 
s(1) = subplot(2,1,1);
plot(sashe.nm(sashe.good_pix), [mean(sashe.spec(hemisp&one,sashe.good_pix),1);mean(sashe.spec(hemisp&~one,sashe.good_pix),1)],'-');
legend('first','second')
title('total hemispheric')
s(2) = subplot(2,1,2);
plot(sashe.nm(sashe.good_pix), [mean(sashe.spec(hemisp&one,sashe.good_pix),1)-mean(sashe.spec(hemisp&~one,sashe.good_pix),1)]./mean(sashe.spec(hemisp,sashe.good_pix),1),'-');
linkaxes(s,'x')
%%
figure(2); 
s(1) = subplot(2,1,1);
plot(sashe.nm(sashe.good_pix), [mean(sashe.spec(sides&one,sashe.good_pix),1);mean(sashe.spec(sides&~one,sashe.good_pix),1)],'-');
legend('first','second')
title('side bands')
s(2) = subplot(2,1,2);
plot(sashe.nm(sashe.good_pix), (sashe.spec(sides_ii(1),sashe.good_pix)-sashe.spec(sides_ii(2),sashe.good_pix))./mean(sashe.spec(sides_ii(1:2),sashe.good_pix),1),'-',...
sashe.nm(sashe.good_pix), (sashe.spec(sides_ii(4),sashe.good_pix)-sashe.spec(sides_ii(3),sashe.good_pix))./mean(sashe.spec(sides_ii(3:4),sashe.good_pix),1),'-');
linkaxes(s,'x')
%%
figure(4)
s(1) = subplot(2,1,1);
plot(sashe.nm(sashe.good_pix), sashe.spec(hemisp,sashe.good_pix),'-k',...
   sashe.nm(sashe.good_pix),sashe.spec(sides,sashe.good_pix),'-r');
title('hemispheric and side bands')
s(2) = subplot(2,1,2);
plot(sashe.nm(sashe.good_pix), (mean(sashe.spec(hemisp&one,sashe.good_pix),1)-mean(sashe.spec(sides&one,sashe.good_pix),1))./...
   mean(sashe.spec((hemisp|sides)&one,sashe.good_pix),1),'-');
title('hemisp-sides')
linkaxes(s,'x')

%%
figure(3); 
s(1) = subplot(2,1,1);
plot(sashe.nm(sashe.good_pix), sashe.spec(blocked,sashe.good_pix),'-');
legend('first','second')
title('blocked')
s(2) = subplot(2,1,2);
plot(sashe.nm(sashe.good_pix), (sashe.spec(blocked&one,sashe.good_pix)-sashe.spec(blocked&~one,sashe.good_pix))./mean(sashe.spec(blocked,sashe.good_pix),1),'-');
linkaxes(s,'x')
%%
figure; lines = plot(sashe.nm(sashe.good_pix), sashe.spec(~dark_T,sashe.good_pix)-ones([sum(~dark_T),1])*mean(sashe.spec(dark_T,sashe.good_pix),1),'-');
legend(num2str(sashe.Experiment_element_ID(~dark_T)))
%
recolor(lines,mod(sashe.Experiment_element_ID(~dark_T)',9));colorbar
%%

% 


%%
raw_fields = fieldnames(sashe);
%%

for rf =length(raw_fields):-1:1
   if all(size(sashe.(raw_fields{rf}))==size(sashe.time))
      mean_tmp = mean(sashe.(raw_fields{rf}));
      std_tmp = std(sashe.(raw_fields{rf}));
      if abs(std_tmp./mean_tmp)<=0.01
         disp([raw_fields{rf},' = ',num2str(mean_tmp)])
         sashe.statics.(raw_fields{rf}) = mean_tmp;
      end         
   end
      
end
%%





return
