function aats = rd_aats_trans(filename);
if ~exist('filename','var')||~exist(filename,'file');
   filename = getfullname('*_trans.*','aats_trans');
end
%      [aatsfilename,pathname]=uigetfile('C:\case_studies\4STAR\ftp.science.arc.nasa.gov\Data\aats14_4star_stability\*_trans.*','Choose data file');
fid=fopen(filename);
if fid>0
   [pname, fname,ext] = fileparts(filename);
   fname = [fname, ext];
   aats.fname = fname;
   aats.pname = pname;
   tmp = fgetl(fid);
   tmp = fgetl(fid);
   pmt = fliplr(tmp);
   kot = fliplr(strtok(pmt));
   dt = datenum(kot,'dd.mm.yyyy');
   [aats.r_au]=fscanf(fid,'%g',[1,1]);
   % f = 1/r^2, that AATS transmittance has been corrected by this term.
   % as in I(t) = Io * (1/r.^2) * T
   tmp = fgetl(fid);
   tmp = fgetl(fid);
   aats.wl = sscanf(tmp,'%g');
   tmp = fgetl(fid);
   aats.Vo = sscanf(tmp,'%g');
   [AATS14_Trans]=fscanf(fid,'%g',[15,inf]);
   fclose(fid);
   aats.time=dt + AATS14_Trans(1,:)./24;
   %       AATS14_Trans=AATS14_Trans(2:12,:);
   % Removing 940 channel
   aats.trans=AATS14_Trans([2:end],:);
else
   aats = [];
end
return



      
