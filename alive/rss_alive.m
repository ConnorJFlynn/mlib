function rss = rss_alive(infile)
if ~exist('infile','var')
   [fname, pname]= uigetfile('*.dat');
   infile = [pname, fname];
end
if ~exist(infile,'file')
   [fname, pname]= uigetfile('*.dat');
   infile = [pname, fname];
end
raw = load(infile);
rss.time = (raw(:,1)-1 + raw(:,2)/24 + datenum('1900-01-01','yyyy-mm-dd'));
rss.sea = raw(:,3);
rss.zen = 90-rss.sea;
rss.pres = raw(:,4);
rss.O3 = raw(:,5);
rss.aod_360 = raw(:,6);
rss.aod_500 = raw(:,7);
rss.aod_780 = raw(:,8);
rss.aod_870 = raw(:,9);
rss.aod_1020 = raw(:,10);
rss.a0 = raw(:,11);
rss.a1 = raw(:,12);
rss.a2 = raw(:,13);
rss.a_rms = raw(:,14);
rss.b0 = raw(:,15);
rss.b1 = raw(:,16);
rss.b2 = raw(:,17);
rss.b_rms = raw(:,18);
