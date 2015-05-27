
function polavg = catpol(polavg,polavg_new);
if ~isempty(polavg_new)
   in_time = polavg.time;
   [polavg.time, ind] = unique([polavg.time,polavg_new.time]);
   fields = fieldnames(polavg);
   for f = 1:length(fields)
      if size(polavg.(fields{f}),2)==length(in_time)
         tmp = [polavg.(fields{f}), polavg_new.(fields{f})];
         polavg.(fields{f}) = tmp(:,ind);
      end
   end
   hk = fieldnames(polavg.hk);
   for h = 1:length(hk);
%       disp(hk{h})
      if findstr(hk{h},'_flag')
         polavg.hk = rmfield(polavg.hk,hk{h});
      elseif length(polavg_new.hk.(hk{h}))==length(polavg_new.time)
         tmp = [polavg.hk.(hk{h}),polavg_new.hk.(hk{h}) ];
         polavg.hk.(hk{h}) = tmp(ind);
      elseif isstruct(polavg.hk.(hk{h}))
         tmp = [polavg.hk.(hk{h}).ch_1,polavg_new.hk.(hk{h}).ch_1 ];
         polavg.hk.(hk{h}).ch_1 = tmp(ind);
         tmp = [polavg.hk.(hk{h}).ch_2,polavg_new.hk.(hk{h}).ch_2 ];
         polavg.hk.(hk{h}).ch_2 = tmp(ind);
      end
   end
end
return
%Then do the N-d vars

