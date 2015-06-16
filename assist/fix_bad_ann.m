pname = ['D:\case_studies\assist\deployments\ASSIST_at_SGP_20150603\ASSIST_3rd_BB_45C_H0602\2015_06_05_00_55_31_RAW\'];
file = dir([pname, '*_ann_*.csv']);
mkdir(pname, 'fixed');
for f = 1:length(file)
   fann = fopen([pname, file(f).name],'r'); 
   asc = fread(fann);asc = char(asc)'; fclose(fann);
   new_asc = strrep(asc,['"',sprintf('\n'),'9501 836 03503"'],'9501 836 03503');new_asc = new_asc';
   fnew = fopen([pname, 'fixed',filesep,file(f).name],'w');
   fwrite(fnew,new_asc);
   fclose(fnew);
end

   
   
   