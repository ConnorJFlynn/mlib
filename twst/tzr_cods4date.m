function tzr = tzr_cods4date(dstr)

if ~isavar('dstr')

   infile = getfullname('TASZERS_COD_TWST10_*.txt','tzr_cod','Select TWST10 file for desired date');
    dat = load(infile);
   bad = dat(:,2)==100 |dat(:,2)==200 |dat(:,2)<.1; dat(bad,:) = [];
   twst10.time = epoch2serial(dat(:,1)); twst10.cod = dat(:,2);
   dstr = datestr(mean(twst10.time),'yyyymmdd');

else
   infile = getfullname(['TASZERS_COD_TWST10_*',dstr,'.txt'],'tzr_cod','Select TWST10 file for desired date');
   dat = load(infile);
   bad = dat(:,2)==100 |dat(:,2)==200 |dat(:,2)<.1; dat(bad,:) = [];
   twst10.time = epoch2serial(dat(:,1)); twst10.cod = dat(:,2);
   dstr = datestr(mean(twst10.time),'yyyymmdd');

end

   dat = load(getfullname(['TASZERS_COD_TWST11_*',dstr,'.txt'],'tzr_cod','Select TWST11 file for desired date'));
   bad = dat(:,2)==100 |dat(:,2)==200 |dat(:,2)<.1; dat(bad,:) = [];
   twst11.time = epoch2serial(dat(:,1)); twst11.cod = dat(:,2);
   dat = load(getfullname(['TASZERS_COD_Ze1_*',dstr,'.txt'],'tzr_cod','Select Ze1 file for desired date'));
   bad = dat(:,2)==100 |dat(:,2)==200 |dat(:,2)<.1; dat(bad,:) = [];
   Ze1.time = epoch2serial(dat(:,1)); Ze1.cod = dat(:,2);
   dat = load(getfullname(['TASZERS_COD_Ze2_*',dstr,'.txt'],'tzr_cod','Select Ze2 file for desired date'));
   bad = dat(:,2)==100 |dat(:,2)==200 |dat(:,2)<.1; dat(bad,:) = [];
   Ze2.time = epoch2serial(dat(:,1)); Ze2.cod = dat(:,2);


   tzr.cod10 = twst10;
   tzr.cod11 = twst11;
   tzr.cod1 = Ze1;
   tzr.cod2 = Ze2;



   [pname,fname] = fileparts(infile);
   outfile = [pname,filesep,'tzr_cods.',dstr,'.mat'];



   save(outfile,'-struct','tzr');

end