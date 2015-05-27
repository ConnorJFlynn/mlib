%% and save the new file as a seperate datstream and generate the png file.
warning('off','MATLAB:dispatcher:InexactMatch')
%%gname = 'C:\ARM\mplnor\sgpmplnor1campC1.c1\1999\';

gname = '/data/home/sivaraman/sgp/sgpmplnor1campC1.c1_generic/';
gname = 'C:\case_studies\Zhein\sgpmplnor1campC1.c1_generic\';
%%sondef ='C:\ARM\Lidar_Anal\';
sondef = '/data/archive/sgp/sgpsondewnpnC1.b1/';
sondef = 'C:\case_studies\Zhein\sondes\';
sfname= 'sgpsondewnpnC1.b1.20030101.053200.cdf';

sf = dir([sondef, sfname]);
    sondefname = sf(1).name;
    sonde = ancload([sondef, sfname]);

    
    htsnd = sonde.vars.alt.data/1000.;
    tempk = sonde.vars.tdry.data+273.1;
    lambda = 532.0;
    %extinction, bscat is returned. 
    [a,b] = ray_a_b(tempk, sonde.vars.pres.data*1000, lambda);
    bm = b*25.0;
    
 %%
 
fgname = [gname,filesep,  'sgpmplnor1campC1.c1.*.cdf'];
fname = 'sgpmplnor1campC1.c1.20030101.*.cdf';
mplnorf = dir([gname, fname]);

for i = 1:length(mplnorf)
    mplnorfname = mplnorf(i).name;
    infname = [gname, mplnorfname];
    mpl_in(i) = ancload(infname);
    mpl = mpl_in(i);
    bm2 = interp1(htsnd, bm, mpl.vars.height.data, 'linear', 'extrap');
    bscat2 = mpl.vars.backscatter.data *10000;
 
    ht2 = power(mpl.vars.height.data,2);  
    bscat4 = zeros(size(mpl.vars.backscatter.data));
    tic
    bscat4 = bscat2 .* (ht2*ones(size(mpl.time)));    
    toc
%     tic
%     for k=1: length(mpl.time)
%       bscat3 = squeeze(bscat2(:,k));
%       for l=1: length(mpl.vars.height.data)
%         bscat4(l,k) = bscat3(l)/ht2(l);
%       end       
%     end 
%  toc
   for n=1:length(mpl.time)
      bscat5 = single(squeeze(bscat4(:,n)));
      dectime = single(serial2Hh(mpl.time(n)));
    [base, top] = mlb_cloud(length(mpl.vars.height.data), dectime*ones(size(mpl.vars.height.data)), bscat5, mpl.vars.height.data(:),bm2);
   end
   

end

