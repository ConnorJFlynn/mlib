function aats = read_aats_trans(infile)
if ~exist('infile','var')
    infile = getfullname_('*_trans.*','AATS_trans','Select an AATS trans file');
%     [aatsfilename,pathname]=uigetfile('C:\case_studies\4STAR\ftp.science.arc.nasa.gov\Data\aats14_4star_stability\*_trans.*','Choose data file');
      fid=fopen(infile);
      fgetl(fid);
      fgetl(fid);
      [f]=fscanf(fid,'%g',[1,1]);
      % f = 1/r^2, that AATS transmittance has been corrected by this term.
      % as in I(t) = Io * (1/r.^2) * T
      fgetl(fid);
      fgetl(fid);
      fgetl(fid);
      [AATS14_Trans]=fscanf(fid,'%g',[15,inf]);
      fclose(fid);
      UT_AATS14=AATS14_Trans(1,:);
%       AATS14_Trans=AATS14_Trans(2:12,:);
% Removing 940 channel
      AATS14_Trans=AATS14_Trans([2:10 12],:);
      aats.time = UT_AATS14;
      aats.trans = AATS14_Trans;
end
