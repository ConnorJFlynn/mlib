function check_aip_dod
%%
aip = ancload;
aipavg = ancload;

aip_field = fieldnames(aip.vars);
aipavg_field = fieldnames(aipavg.vars);

for ii = 5:length(aip_field)
   done = false;
   jj = 5;
   while ~done
      if jj>length(aipavg_field)
         done = true;
      else
         if strcmp(aip_field{ii},aipavg_field{jj})
            if ~strcmp(aip.vars.(aip_field{ii}).atts.long_name.data, aipavg.vars.(aipavg_field{jj}).atts.long_name.data)
               disp(aip_field{ii})
               disp(aip.vars.(aip_field{ii}).atts.long_name.data);
               disp(aipavg.vars.(aipavg_field{jj}).atts.long_name.data);
               aipavg.vars.(aipavg_field{jj}).atts.long_name.data =aip.vars.(aip_field{ii}).atts.long_name.data ;
            end
            done = true;
         end
         jj = jj + 1;
      end
   end
end
aipavg.fname = [aipavg.fname '.new.nc'];
ancsave(aipavg);