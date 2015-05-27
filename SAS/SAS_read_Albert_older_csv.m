function outs = SAS_read_Albert_older_csv(infile)
%outs = SAS_read_Albert_older_csv(infile)
% Read older SAS CSV files by Albert containing only a single spectra. (I
% think...)
if ~exist('infile','var')
   infile= getfullname_('*.csv','ascii');
end
[pname, fname,ext] = fileparts(infile);
fname = [fname,ext];
fid = fopen(infile);
if fid>0
   [pname, fname,ext] = fileparts(infile);
   fname = [fname,ext];
   in_file.fname{1} = fname;
   in_file.pname = [pname,filesep];
   done = false;
   if ~exist('header_rows','var')
      
      tmp = fgetl(fid);
      labels = textscan(tmp,'%s','delimiter',',');
      labels = labels{:};
      labels = strrep(labels,' ','');
      fseek(fid,0,-1);
      txt = textscan(fid,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f','headerlines',1,'delimiter',',','treatAsEmpty','N/A');
      ins.time = datenum([txt{1},txt{2},txt{3},txt{4},txt{5},txt{6}]);
      ins.V_Temp1 = txt{7};
      ins.V_RH1 = txt{8};
      ins.V_Temp2 = txt{9};
      ins.V_RH2 = txt{10};
      ins.V_cc = txt{11};
      ins.Temp1_ = txt{12};
      ins.RH1_ = txt{13};
      ins.Temp2_ = txt{14};
      ins.RH2_ = txt{15};
      
   end
end
[ins.Temp1,ins.RH1] = precon_trh(ins.V_Temp1,ins.V_RH1, ins.V_cc);
[ins.Temp2,ins.RH2] = humirel_trh(ins.V_Temp2, ins.V_RH2, ins.V_cc);
%%
figure; 
subplot(2,1,1); plot(serial2Hh(ins.time), [ins.Temp1, ins.Temp1_, ins.Temp2, ins.Temp2_],'-')
title('Temperature sensor comparisons')
lg = legend('precon_cjf','precon_ME','humirel_cjf','humirel_ME');
set(lg,'interp','none')
ax(1) = gca;
subplot(2,1,2); plot(serial2Hh(ins.time), [ins.RH1, ins.RH1_, ins.RH2, ins.RH2_],'-')
title('RH sensor comparisons')
lg = legend('precon_cjf','precon_ME','humirel_cjf','humirel_ME');
set(lg,'interp','none')
ax(2) = gca;
linkaxes(ax,'x')
%%

return
