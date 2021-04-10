function accp_case = rd_accp_case(infile);

if ~isavar('infile')
    infile = getfullname('simprofile*.csv','accp_cases');
end


fstr = ('%*f %f ');  %     MidAltitude,    TopAltitude,
fstr = ([fstr,'%f %f %f ']); %bsc355,         bsc532,        bsc1064,
fstr = [fstr, '%f %f %f %f ']; %ext355,         ext532,         ext555,        ext1064,
fstr = [fstr, '%f %f %f ']; % attnbsc355,     attnbsc532,    attnbsc1064,      
fstr = [fstr, '%f %f %f ']; % abs355,         abs532,        abs1064,  
fstr = [fstr, '%f %f %f '];% ext355fine,   ext355coarse,     ext532fine,
fstr = [fstr, '%f %f %f ']; %ext532coarse,     ext555fine,   ext555coarse,
fstr = [fstr, '%f %f %f %f %f '];% fine radius,     fine width,         fine N,   fine RRI 532,   fine IRI 532, 
fstr = [fstr, '%f %f %f %f %f ']; % coarse radius,   coarse width,       coarse N, coarse RRI 532, coarse IRI 532,  
fstr = [fstr, '%f %f %f '];% Sa355,          Sa532,         Sa1064
%              km,             km,    km^-1 sr^-1,    km^-1 sr^-1,    km^-1 sr^-1,          km^-1,          km^-1,          km^-1,          km^-1,    km^-1 sr^-1,    km^-1 sr^-1,    km^-1 sr^-1,          km^-1,          km^-1,          km^-1,          km^-1,          km^-1,          km^-1,          km^-1,          km^-1,          km^-1,     micrometer,       unitless,          cm^-3,       unitless,       unitless,     micrometer,       unitless,          cm^-3,       unitless,       unitless,             sr,             sr,             sr
%       0.2500000,      0.5000000,    0.005137763,    0.004817011,    0.003319973,      0.1003066,      0.1027520,      0.1028837,      0.1037368,     0.01110754,    0.005031489,    0.002819504,   0.0003649060,   0.0002388936,   0.0001072860,     0.01710329,     0.08320331,     0.01535200,     0.08740005,     0.01493120,     0.08795250,      0.2000000,       1.568312,       29.44934,       1.415000,    0.002000000,      0.6000000,       2.013753,       12.20725,       1.363000,  1.000000e-005,       19.52340,       21.33108,       31.24626
fid = fopen(infile,'r'); accp_case.comment = fgetl(fid);
[blah_, endpos] = textscan(fid,fstr,'delimiter',',', 'headerlines',2);  blah = blah_;
fclose(fid);
tmp = blah{1}; tmp = [0;tmp]; blah(1) = [];
infile(strfind(infile,'_vACCP_case')+length('_vACCP_case'):end)
accp_case.Alt = tmp; 
tmp = blah{1}; tmp = [tmp(1);tmp]; blah(1) = [];
accp_case.bsc355 = tmp;
tmp = blah{1}; tmp = [tmp(1);tmp]; blah(1) = [];
accp_case.bsc532 = tmp;
tmp = blah{1}; tmp = [tmp(1);tmp]; blah(1) = [];
accp_case.bsc1064 = tmp;

tmp = blah{1}; tmp = [tmp(1);tmp]; blah(1) = [];
accp_case.ext355 = tmp;
tmp = blah{1}; tmp = [tmp(1);tmp]; blah(1) = [];
accp_case.ext555 = tmp;
tmp = blah{1}; tmp = [tmp(1);tmp]; blah(1) = [];
accp_case.ext532 = tmp;
tmp = blah{1}; tmp = [tmp(1);tmp]; blah(1) = [];
accp_case.ext1064 = tmp;
accp_case.aod555 = cumtrapz(accp_case.Alt, accp_case.ext555);
accp_case.aod532 = cumtrapz(accp_case.Alt, accp_case.ext532);
figure; plot([accp_case.ext355,accp_case.ext532, accp_case.ext555, accp_case.ext1064],accp_case.Alt, 'o-');
xlabel('ext [1/km]'); ylabel('altitude [km]'); legend('355 nm','532 nm','555 nm','1064 nm');
zoom('on'); yl_max = ylim;
menu('Zoom to view only points in lower boundary layer','OK');
yl = ylim;xl = xlim;
lo = accp_case.Alt<yl(2);lo_i = find(lo);
hi = accp_case.Alt>yl(2); hi_i = [lo_i(end);find(hi)];
 figure; plot(accp_case.ext555,accp_case.Alt,'-x',accp_case.ext555(lo), accp_case.Alt(lo),'bo',accp_case.ext555(hi), accp_case.Alt(hi),'r*', ...
     [0,xl(2)],[yl(2),yl(2)],'k--');
 xlabel('ext [1/km]'); ylabel('altitude [km]');
 legend('aod532','low','high')
 tx = text(mean(xl)./2,yl(2)./2,sprintf('Lower layer OD(532nm)=%1.2f',simps(accp_case.Alt(lo), accp_case.ext532(lo))));
 tx = text(mean(xl)./2,(yl(2)+yl_max(2))./2,sprintf('Upper layer OD(532nm)=%1.2f',simps(accp_case.Alt(hi_i), accp_case.ext532(hi_i))));
 
 case_i = strfind(accp_case.comment, 'SIT-A'); def_i = strfind(accp_case.comment,'defined');
 title({accp_case.comment(case_i+5:def_i-2); accp_case.comment(def_i:end)});
 menu('position text as desired, then click "Done".','Done');
 saveas(gcf, strrep(infile,'.csv','.png'));saveas(gcf, strrep(infile,'.csv','.fig'));