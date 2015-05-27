pname = 'C:\case_studies\Alive\data\sgpmplC1.a1\arm_netcdf\';
m4 = dir([pname,'sgpmplC1.a1.200509*.cdf']);
for f =1:length(m4)
    mpl4 = read_mpl([pname, m4(f).name]);
    mpl4.pname = pname;
    mpl4.fname = m4(f).name;
    mpl4 = mpl004_alive(mpl4);
    pause(.5); clear mpl4
end
%%
pname = 'C:\case_studies\Alive\data\mpl102\day\';
m4 = dir([pname,'2005*.day']);
for f =1:length(m4)
    mpl4 = read_mpl([pname, m4(f).name]);
    mpl4.pname = pname;
    mpl4.fname = m4(f).name;
    mpl4 = mpl102_alive(mpl4);
    pause(.5); clear mpl4
end
%%