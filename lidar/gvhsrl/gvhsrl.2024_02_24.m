

height = hsrl.vdata.range;
height2 = [0:7.5:max(height)];

by_ht.time = hsrl.time;
by_ht.height = height2';
fields = fieldnames(hsrl.vatts);

for f = 1:length(fields)
   fld = fields{f};
   if any(strcmp(hsrl.ncdef.vars.(fld).dims,'time'))&&any(strcmp(hsrl.ncdef.vars.(fld).dims,'range')) &&~foundstr(fld,'_variance')
      by_ht.(fld) = NaN([length(by_ht.height),length(by_ht.time)]);
   end
   if any(strcmp(hsrl.ncdef.vars.(fld).dims,'time'))&&any(strcmp(hsrl.ncdef.vars.(fld).dims,'range')) &&~foundstr(fld,'_variance')
      by_ht.(fld) = NaN([length(by_ht.height),length(by_ht.time)]);
   end
end

fields2 = fieldnames(by_ht);
for f = 1:length(fields2)
   fld = fields2{f};
   if ~(strcmp(fld,'time')||strcmp(fld,'height'))
      up = find(hsrl.vdata.TelescopeDirection==1);
      for t = up'
         by_ht.(fld)(:,t) = interp1(hsrl.vdata.GGALT(t)+height, hsrl.vdata.(fld)(:,t), height2,'nearest');
      end

      down = find(hsrl.vdata.TelescopeDirection==0);
      for t = down'
         by_ht.(fld)(:,t) = interp1(hsrl.vdata.GGALT(t)-height, hsrl.vdata.(fld)(:,t), height2,'nearest');
      end
   end
end

raw_r_  = hsrl.vdata.rangeFull>200 & hsrl.vdata.rangeFull<5000;
r_  = hsrl.vdata.range>200 & hsrl.vdata.range<5000;


figure; plot(hsrl.vdata.rangeFull, hsrl.vdata.Raw_Molecular_Backscatter_Channel(:,1500) - mean(hsrl.vdata.Raw_Molecular_Backscatter_Channel(2000:end,1500)), 'r-',...
   hsrl.vdata.range, hsrl.vdata.Molecular_Backscatter_Channel(:,1500),'-k'); logy
legend('Raw Mol Ch - bg','Mol Ch')
[Warning: Negative data ignored] 
[> In matlab.graphics.shape.internal.AxesLayoutManager>calculateLooseInset
In matlab.graphics.shape.internal/AxesLayoutManager/updateStartingLayoutPosition
In matlab.graphics.shape.internal/AxesLayoutManager/doUpdate] 
figure; plot(...
   hsrl.vdata.range, 6.5e7.*hsrl.vdata.Molecular_Backscatter_Coefficient(:,1700),'--r',...
   hsrl.vdata.range, 1e-6.*mean(hsrl.vdata.Molecular_Backscatter_Channel(:,1700:1750),2).*hsrl.vdata.range.^2,'-k'...
   ); logy;
legend('1e8*Rayleigh','Mol Ch * R^2');
[Warning: Negative data ignored] 
[> In matlab.graphics.shape.internal.AxesLayoutManager>calculateLooseInset
In matlab.graphics.shape.internal/AxesLayoutManager/updateStartingLayoutPosition
In matlab.graphics.shape.internal/AxesLayoutManager/doUpdate] 
figure; plot(...
   hsrl.vdata.range, 6.5e7.*hsrl.vdata.Molecular_Backscatter_Coefficient(:,1700)./(1e-6.*mean(hsrl.vdata.Molecular_Backscatter_Channel(:,1700:1750),2).*hsrl.vdata.range.^2),'-k'...
   ); logy;
legend('RayCorr')
[Warning: Negative data ignored] 
[> In matlab.graphics.shape.internal.AxesLayoutManager>calculateLooseInset
In matlab.graphics.shape.internal/AxesLayoutManager/updateStartingLayoutPosition
In matlab.graphics.shape.internal/AxesLayoutManager/doUpdate] 
Corr = [real((hsrl.vdata.range)),...
   real((6.5e7.*hsrl.vdata.Molecular_Backscatter_Coefficient(:,1700)./(1e-6.*mean(hsrl.vdata.Molecular_Backscatter_Channel(:,1700:1750),2).*hsrl.vdata.range.^2)))];
sprintf('%f %f \n',Corr(1:1000,:)')

ans =

    '154.243225 21.802383 
     161.738037 20.331347 
     169.232849 18.928440 
     176.727661 17.703201 
     184.222458 16.643377 
...
     7611.580566 1.225962 
     7619.075195 1.222085 
     7626.570312 1.214685 
     7634.064941 1.213764 
     7641.560059 1.246065 
     '


figure; imagesc(by_ht.time, by_ht.height, pos_ext); axis('xy'); colorbar; dynamicDateTicks
figure; imagesc(by_ht.time, by_ht.height, real(log10(pos_ext))); axis('xy'); colorbar; dynamicDateTicks
dt = 12;% delta time increments (120 sec)
dd = 20;% delta range bins (150 m)
for t  = (length(by_ht.time)-dt):-dt:1
   tt = [t:t+dt];
   mln = mean(ln_rho_by_S(:,tt),2);
   % figure; plot(by_ht.height, mln,'-'); legend('ln rho by S')
   ext = 1e6.*(mln(1:(end-dd))-mln((1+dd):end))./(height(dd+1)-height(1));
   ext = posify_prof(ext); ext(ext<.01) = 0;
   pos_ext(:,t) = ext;
   Bbs = 1e6.*mean(by_ht.Aerosol_Backscatter_Coefficient(:,tt),2);

   figure_(12); plot(by_ht.height((1):end-dd), pos_ext(:,t),'-',by_ht.height,Bbs ,'g-');logy
   ylabel('Ext [1/Mm]'); xlabel('height [m]');

   h_ = pos_ext(:,t)>0 & Bbs>0
   Sa(t) = trapz(by_ht.height(h_),pos_ext(h_,t))./trapz(by_ht.height(h_),Bbs(h_));
   title({datestr(by_ht.time(t),'yyyy-mm-dd HH:MM');sprintf('Sa = %2.1f', Sa(t))})
   legend('Ext','Bscat')
   pause(1)
   clf
   datestr(by_ht.time(t),'HH:MM:SS')
end
{Arrays have incompatible sizes for this operation.

<a href="matlab:helpview('matlab','error_sizeDimensionsMustMatch')" style="font-weight:bold">Related documentation</a>
} 
trapz(by_ht.height(h_),pos_ext(h_,t))

ans =

  <a href="matlab:helpPopup single" style="font-weight:bold">single</a>

   NaN

trapz(by_ht.height(h_),Bbs(h_))

ans =

  <a href="matlab:helpPopup single" style="font-weight:bold">single</a>

   NaN

   tt = [t:t+dt];
   mln = mean(ln_rho_by_S(:,tt),2);
   % figure; plot(by_ht.height, mln,'-'); legend('ln rho by S')
   ext = 1e6.*(mln(1:(end-dd))-mln((1+dd):end))./(height(dd+1)-height(1));
   ext = posify_prof(ext); ext(ext<.01) = 0;
   pos_ext(:,t) = ext;
   Bbs = 1e6.*mean(by_ht.Aerosol_Backscatter_Coefficient(:,tt),2);
   figure_(12); plot(by_ht.height((1):end-dd), pos_ext(:,t),'-',by_ht.height,Bbs ,'g-');logy
   ylabel('Ext [1/Mm]'); xlabel('height [m]');

   h_ = pos_ext(:,t)>0 & Bbs>0
{Arrays have incompatible sizes for this operation.

<a href="matlab:helpview('matlab','error_sizeDimensionsMustMatch')" style="font-weight:bold">Related documentation</a>
} 
 figure_(12); plot(by_ht.height((1):end-dd), pos_ext(:,t),'-',by_ht.height,Bbs ,'g-');logy
   ylabel('Ext [1/Mm]'); xlabel('height [m]');
pos_ext(:,t)>0 & Bbs>0
{Arrays have incompatible sizes for this operation.

<a href="matlab:helpview('matlab','error_sizeDimensionsMustMatch')" style="font-weight:bold">Related documentation</a>
} 
h_ = pos_ext(:,t)>0 & Bbs(1:end-dd)>0;


Ht(Ht==0|Ht>7000) = NaN;
Sa(Sa==0|Sa>35) = NaN;
Ht(Ht==0) = NaN;
figure; plot(by_ht.time(1:end-dt),Ht,'o'); legend('layer height')
figure; plot(by_ht.time(1:end-dt),Sa,'o'); legend('layer Sa')
figure; plot(Ht, Sa,'*'); xlabel('Height'); ylabel('Sa');
figure; imagesc(by_ht.time, by_ht.height, real(log10(pos_ext))); axis('xy'); colorbar; dynamicDateTicks
caxis([.25,3])
cm = colormap; cm(1,:) = 0;cm(end,:) = 1; 
colormap(cm)
figure; 
sa(1) = subplot(3,1,1); 
imagesc(hsrl.time, hsrl.vdata.range, real(log10( hsrl.vdata.Backscatter_Ratio-1))); axis('ij'); caxis([-2,1]); 
dynamicDateTicks; ylabel('range from lidar (m)');
title('GVHSRL SOCRATES Jan 29, 2018')
sa(2) = subplot(3,1,2); 
imagesc(by_ht.time, by_ht.height, real(log10( by_ht.Backscatter_Ratio-1))); axis('xy'); caxis([-2,1]); 
xlabel('time'); dynamicDateTicks; ylabel('height MSL (m)');
title(['Log(Backscatter_Ratio-1)'])
sa(3) = subplot(3,1,3); 
imagesc(by_ht.time, by_ht.height, real(log10( by_ht.Aerosol_Backscatter_Coefficient))); axis('xy'); caxis([-2,1]); 
xlabel('time'); dynamicDateTicks; ylabel('height MSL (m)');
title(['Log(Aerosol_Backscatter_Coefficient)'])

sa(1) = subplot(3,1,1); 
imagesc(hsrl.time, hsrl.vdata.range, real(log10( hsrl.vdata.Backscatter_Ratio-1))); axis('ij'); caxis([-2,1]); 
xticks([]); ylabel('range from lidar (m)');
title('GVHSRL SOCRATES Jan 29, 2018')
sa(2) = subplot(3,1,2); 
imagesc(by_ht.time, by_ht.height, real(log10( by_ht.Backscatter_Ratio-1))); axis('xy'); caxis([-2,1]); 
xticks([]); ylabel('height MSL (m)');
title(['Log(Backscatter_Ratio-1)'])
sa(3) = subplot(3,1,3); 
imagesc(by_ht.time, by_ht.height, real(log10( by_ht.Aerosol_Backscatter_Coefficient))); axis('xy'); caxis([-2,1]); 
xlabel('time'); dynamicDateTicks; ylabel('height MSL (m)');
title(['Log(Aerosol_Backscatter_Coefficient)'])
sa(1) = subplot(3,1,1); 
imagesc(hsrl.time, hsrl.vdata.range, real(log10( hsrl.vdata.Backscatter_Ratio-1))); axis('ij'); caxis([-2,1]); 
xticks([]); ylabel('range from lidar (m)');
title('GVHSRL SOCRATES Jan 29, 2018')
sa(2) = subplot(3,1,2); 
imagesc(by_ht.time, by_ht.height, real(log10( by_ht.Backscatter_Ratio-1))); axis('xy'); caxis([-2,1]); 
xticks([]); ylabel('height MSL (m)');
title(['Log(Backscatter_Ratio-1)'])
sa(3) = subplot(3,1,3); 
imagesc(by_ht.time, by_ht.height, real(log10( by_ht.Aerosol_Backscatter_Coefficient))); axis('xy'); ; 
xlabel('time'); dynamicDateTicks; ylabel('height MSL (m)');
title(['Log(Aerosol_Backscatter_Coefficient)'])
caxis([-8,-1])
caxis([-8,-2])
caxis([-7,-2])
caxis([-7.5,-2])
clear pos_ext Ht Sa
dt = 18;% delta time increments (120 sec)
dd = 30;% delta range bins (150 m)
for t  = (length(by_ht.time)-dt):-1:1
   tt = [t:t+dt];
   mln = mean(ln_rho_by_S(:,tt),2);
   % figure; plot(by_ht.height, mln,'-'); legend('ln rho by S')
   Bbs = 1e6.*mean(by_ht.Aerosol_Backscatter_Coefficient((1:end-dd),tt),2);
   ext = 1e6.*(mln(1:(end-dd))-mln((1+dd):end))./(height(dd+1)-height(1));
   ext = posify_prof(ext); ext(ext<Bbs) = 0;
   pos_ext(:,t) = ext;
   ht = by_ht.height((1):end-dd);
   h_ = pos_ext(:,t)>0 & Bbs>1e-7;
   if sum(h_)>5
   Sa(t) = trapz(by_ht.height(h_),pos_ext(h_,t))./trapz(by_ht.height(h_),Bbs(h_));
   Ht(t) = trapz(by_ht.height(h_),by_ht.height(h_).*Bbs(h_))./trapz(by_ht.height(h_),Bbs(h_));
   end
   % figure_(12); plot(ht, pos_ext(:,t),'-',ht,Bbs ,'g-');logy
   % ylabel('Ext [1/Mm]'); xlabel('height [m]');
   % title({datestr(by_ht.time(t),'yyyy-mm-dd HH:MM');sprintf('Sa = %2.1f', Sa(t))})
   % legend('Ext','Bscat')
   % pause(1)
   % clf
   sprintf('%s', datestr(by_ht.time(t),'HH:MM:SS'))
end

ans =

    '06:04:54'


...


ans =

    '00:00:14'


ans =

    '00:00:04'

Ht(Ht==0|Ht>7000) = NaN;
Sa(Sa==0|Sa>35) = NaN;
Ht(Ht==0) = NaN;
figure; plot(by_ht.time(1:end-dt),Ht,'o'); legend('layer height');dynamicDateTicks 
figure; plot(Ht, Sa,'*'); xlabel('Height'); ylabel('Sa');dynamicDateTicks
figure; imagesc(by_ht.time, by_ht.height, real(log10(pos_ext))); axis('xy');  dynamicDateTicks
ylabel('Ext [1/Mm]');
colorbar;caxis([.25,3])
cm = colormap; cm(1,:) = 0;cm(end,:) = 1; 
colormap(cm)
cm = colormap; cm(1,:) = 0;cm(end,:) = 1; 
colormap(cm)
clear pos_ext Ht Sa
dt = 18;% delta time increments (120 sec)
dd = 30;% delta range bins (150 m)
for t  = (length(by_ht.time)-dt):-1:1
   tt = [t:t+dt];
   mln = mean(ln_rho_by_S(:,tt),2);
   % figure; plot(by_ht.height, mln,'-'); legend('ln rho by S')
   Bbs = 1e6.*mean(by_ht.Aerosol_Backscatter_Coefficient((1:end-dd),tt),2);
   ext = 1e6.*(mln(1:(end-dd))-mln((1+dd):end))./(height(dd+1)-height(1));
   ext = posify_prof(ext); ext(ext<Bbs) = 0;
   pos_ext(:,t) = ext;
   ht = by_ht.height((1):end-dd);
   h_ = pos_ext(:,t)>0 & Bbs>1e-6;
   if sum(h_)>5
   Sa(t) = trapz(by_ht.height(h_),pos_ext(h_,t))./trapz(by_ht.height(h_),Bbs(h_));
   Ht(t) = trapz(by_ht.height(h_),by_ht.height(h_).*Bbs(h_))./trapz(by_ht.height(h_),Bbs(h_));
   end
   % figure_(12); plot(ht, pos_ext(:,t),'-',ht,Bbs ,'g-');logy
   % ylabel('Ext [1/Mm]'); xlabel('height [m]');
   % title({datestr(by_ht.time(t),'yyyy-mm-dd HH:MM');sprintf('Sa = %2.1f', Sa(t))})
   % legend('Ext','Bscat')
   % pause(1)
   % clf
   sprintf('%s', datestr(by_ht.time(t),'HH:MM:SS'))
end

Ht(Ht==0|Ht>7000) = NaN;
Sa(Sa==0|Sa>35) = NaN;
Ht(Ht==0) = NaN;
figure; plot(by_ht.time(1:end-dt),Ht,'o'); legend('layer height');dynamicDateTicks 
figure; plot(Ht, Sa,'*'); xlabel('Height'); ylabel('Sa');dynamicDateTicks
figure; imagesc(by_ht.time, by_ht.height, real(log10(pos_ext))); axis('xy');  dynamicDateTicks
ylabel('Ext [1/Mm]');
colorbar;caxis([.25,3])
cm = colormap; cm(1,:) = 0;cm(end,:) = 1; 
colormap(cm)
clear pos_ext Ht Sa
dt = 12;% delta time increments (120 sec)
dd = 20;% delta range bins (150 m)
for t  = (length(by_ht.time)-dt):-1:1
   tt = [t:t+dt];
   mln = mean(ln_rho_by_S(:,tt),2);
   % figure; plot(by_ht.height, mln,'-'); legend('ln rho by S')
   Bbs = 1e6.*mean(by_ht.Aerosol_Backscatter_Coefficient((1:end-dd),tt),2);
   ext = 1e6.*(mln(1:(end-dd))-mln((1+dd):end))./(height(dd+1)-height(1));
   ext = posify_prof(ext); ext(ext<Bbs) = 0;
   pos_ext(:,t) = ext;
   ht = by_ht.height((1):end-dd);
   h_ = pos_ext(:,t)>0 & Bbs>1e-5;
   if sum(h_)>5
   Sa(t) = trapz(by_ht.height(h_),pos_ext(h_,t))./trapz(by_ht.height(h_),Bbs(h_));
   Ht(t) = trapz(by_ht.height(h_),by_ht.height(h_).*Bbs(h_))./trapz(by_ht.height(h_),Bbs(h_));
   end
   % figure_(12); plot(ht, pos_ext(:,t),'-',ht,Bbs ,'g-');logy
   % ylabel('Ext [1/Mm]'); xlabel('height [m]');
   % title({datestr(by_ht.time(t),'yyyy-mm-dd HH:MM');sprintf('Sa = %2.1f', Sa(t))})
   % legend('Ext','Bscat')
   % pause(1)
   % clf
   sprintf('%s', datestr(by_ht.time(t),'HH:MM:SS'))
end


Ht(Ht==0|Ht>7000) = NaN;
Sa(Sa==0|Sa>35) = NaN;
Ht(Ht==0) = NaN;
figure; plot(by_ht.time(1:end-dt),Ht,'o'); legend('layer height');dynamicDateTicks 
figure; plot(Ht, Sa,'*'); xlabel('Height'); ylabel('Sa');dynamicDateTicks
figure; imagesc(by_ht.time, by_ht.height, real(log10(pos_ext))); axis('xy');  dynamicDateTicks
ylabel('Ext [1/Mm]');
colorbar;caxis([.25,3])
cm = colormap; cm(1,:) = 0;cm(end,:) = 1; 
colormap(cm)
figure; scatter(by_ht.time(1:end-dt),Ht,12,Sa,'filled'); ylabel('Height [m]'); legend('Bsc-weighted Height');dynamicDateTicks 
scope = interp1(hsrl.time, hsrl.vdata.TelescopeDirection==1, by_ht.time,'nearest','extrap');
{Error using <a href="matlab:matlab.internal.language.introspective.errorDocCallback('interp1>reshapeValuesV')" style="font-weight:bold">interp1>reshapeValuesV</a>
Values V must be of type double or single.

Error in <a href="matlab:matlab.internal.language.introspective.errorDocCallback('interp1>reshapeAndSortXandV', 'C:\Program Files\MATLAB\R2023a\toolbox\matlab\polyfun\interp1.m', 443)" style="font-weight:bold">interp1>reshapeAndSortXandV</a> (<a href="matlab: opentoline('C:\Program Files\MATLAB\R2023a\toolbox\matlab\polyfun\interp1.m',443,0)">line 443</a>)
[V,orig_size_v] = reshapeValuesV(V);

Error in <a href="matlab:matlab.internal.language.introspective.errorDocCallback('interp1', 'C:\Program Files\MATLAB\R2023a\toolbox\matlab\polyfun\interp1.m', 128)" style="font-weight:bold">interp1</a> (<a href="matlab: opentoline('C:\Program Files\MATLAB\R2023a\toolbox\matlab\polyfun\interp1.m',128,0)">line 128</a>)
    [X,V,orig_size_v] = reshapeAndSortXandV(X,V);
} 
scope = interp1(hsrl.time, hsrl.vdata.TelescopeDirection, by_ht.time,'nearest','extrap');
Ht(scope==1) = NaN;
Sa(scope==1) = NaN;
Ht(scope==1) = NaN;
pos_ext(:,scope==1) = NaN;
figure; plot(by_ht.time(1:end-dt),Ht,'o'); legend('layer height');dynamicDateTicks 
figure; plot(Ht, Sa,'*'); xlabel('Height'); ylabel('Sa');dynamicDateTicks
figure; imagesc(by_ht.time, by_ht.height, real(log10(pos_ext))); axis('xy');  dynamicDateTicks
ylabel('Ext [1/Mm]');
colorbar;caxis([.25,3])
cm = colormap; cm(1,:) = 0;cm(end,:) = 1; 
colormap(cm)
figure; scatter(by_ht.time(1:end-dt),Ht,12,Sa,'filled'); ylabel('Height [m]'); dynamicDateTicks 
figure; plot(by_ht.time(1:end-dt),Ht,'o'); legend('layer height');dynamicDateTicks 
figure; plot(Ht, Sa,'*'); xlabel('Height'); ylabel('Sa');dynamicDateTicks
figure; plot(Ht, Sa,'*'); xlabel('Height'); ylabel('Sa');
figure; plot(Ht./1000, Sa,'*'); xlabel('Height [km]'); ylabel('Sa');
Bb(t) = trapz(by_ht.height(h_),Bbs(h_));
clear pos_ext Ht Sa Bb
dt = 12;% delta time increments (120 sec)
dd = 20;% delta range bins (150 m)
for t  = (length(by_ht.time)-dt):-1:1
   tt = [t:t+dt];
   mln = mean(ln_rho_by_S(:,tt),2);
   % figure; plot(by_ht.height, mln,'-'); legend('ln rho by S')
   Bbs = 1e6.*mean(by_ht.Aerosol_Backscatter_Coefficient((1:end-dd),tt),2);
   ext = 1e6.*(mln(1:(end-dd))-mln((1+dd):end))./(height(dd+1)-height(1));
   ext = posify_prof(ext); ext(ext<Bbs) = 0;
   pos_ext(:,t) = ext;
   ht = by_ht.height((1):end-dd);
   h_ = pos_ext(:,t)>0 & Bbs>1e-5;
   if sum(h_)>5
   Bb(t) = trapz(by_ht.height(h_),Bbs(h_));
      Sa(t) = trapz(by_ht.height(h_),pos_ext(h_,t))./trapz(by_ht.height(h_),Bbs(h_));
   Ht(t) = trapz(by_ht.height(h_),by_ht.height(h_).*Bbs(h_))./trapz(by_ht.height(h_),Bbs(h_));
   end
   % figure_(12); plot(ht, pos_ext(:,t),'-',ht,Bbs ,'g-');logy
   % ylabel('Ext [1/Mm]'); xlabel('height [m]');
   % title({datestr(by_ht.time(t),'yyyy-mm-dd HH:MM');sprintf('Sa = %2.1f', Sa(t))})
   % legend('Ext','Bscat')
   % pause(1)
   % clf
   sprintf('%s', datestr(by_ht.time(t),'HH:MM:SS'))
end


ans =

    '00:00:04'

Ht(Ht==0|Ht>7500) = NaN;
Sa(Sa==0|Sa>35) = NaN;
Ht(Ht==0) = NaN;
scope = interp1(hsrl.time, hsrl.vdata.TelescopeDirection, by_ht.time,'nearest','extrap');
Ht(scope==1) = NaN;
Sa(scope==1) = NaN;
Ht(scope==1) = NaN;
pos_ext(:,scope==1) = NaN;
Bb(isnan(Ht)|isnan(Sa)|scope==1) = NaN;
{Arrays have incompatible sizes for this operation.

<a href="matlab:helpview('matlab','error_sizeDimensionsMustMatch')" style="font-weight:bold">Related documentation</a>
} 
Bb(isnan(Ht)|isnan(Sa)) = NaN;
figure; scatter(by_ht.time(1:end-dt),Ht,Bb,Sa,'filled'); ylabel('Height [m]'); dynamicDateTicks
figure; scatter(by_ht.time(1:end-dt),Ht,Bb./1e3,Sa,'filled'); ylabel('Height [m]'); dynamicDateTicks 
figure; plot(Bb, Sa,'*'); xlabel('Bb'); ylabel('Sa');
figure; scatter(Sa,Bb, 12, Ht,'filled');
histogram(Sa(bb<1e-4))
{Unrecognized function or variable 'bb'.
} 
histogram(Sa(Bb<1e-4))
histogram(Sa(Bb<1e4))
histogram(Sa(Bb>1e4))
histogram(Sa)
figure; subplot(1,2,1); histogram(Sa(Bb>1e4)); subplot(1,2,2); histogram(Sa(BB<1e4));
{Unrecognized function or variable 'BB'.
} 
figure; subplot(1,2,1); histogram(Sa(Bb>1e4)); subplot(1,2,2); histogram(Sa(Bb<1e4));
subplot(1,2,1); histogram(Sa(Bb>1e4));title('Cloud Sa') subplot(1,2,2); histogram(Sa(Bb<1e4)); title('Aerosol Sa')
 subplot(1,2,1); histogram(Sa(Bb>1e4));title('Cloud Sa') subplot(1,2,2); histogram(Sa(Bb<1e4)); title('Aerosol Sa')
                                                         ↑
{Invalid expression. Check for missing multiplication operator, missing or unbalanced delimiters, or other syntax error. To construct matrices,
use brackets instead of parentheses.
} 
subplot(1,2,1); histogram(Sa(Bb>1e4));title('Cloud Sa'); subplot(1,2,2); histogram(Sa(Bb<1e4)); title('Aerosol Sa')
subplot(1,2,1); histogram(Sa(Bb>1e4));title('PDF for Bscat>1e4 sr/m'); legend('Cloud'); xlabel('Sa')
subplot(1,2,2); histogram(Sa(Bb<1e4)); title('Aerosol Sa')
subplot(1,2,1); histogram(Sa(Bb>1e4));title({'PDF for Bs>1e4 sr/m';'"Cloud"'});; xlabel('Sa')
subplot(1,2,2); histogram(Sa(Bb<1e4));title({'PDF for Bs<1e4 sr/m';'"Aerosol"'});; xlabel('Sa')
Ext_Coef = by_ht.Aerosol_Backscatter_Coefficient;
cld = Ext_Coef >1e4; cld_mask = zeros(size(Ext_Coef)); cld_mask(cld) = NaN;
aero = Ext_Coef<1e4;
Ext_Coef(cld) = Ext_Coef(cld).*11;
Ext_Coef(aero) = Ext_Coef(aero).*21;

figure; imagesc(by_ht.time, by_ht.height./1000, real(log10(Ext_Coef)));axis('xy'); dynamicDateTicks; ylabel('Height [km AMSL]');colorbar 
caxis([-5.5,0])
cm = colormap; cm(1,:) = 0;cm(end,:) = 1; 
colormap(cm)
figure; imagesc(by_ht.time, by_ht.height./1000, real(log10(Ext_Coef))+cld_mask);axis('xy'); dynamicDateTicks; ylabel('Height [km AMSL]');colorbar 
caxis([-5.5,0])
cm = colormap; cm(1,:) = 0;cm(end,:) = 1; 
colormap(cm)
cld = Ext_Coef >1e3; cld_mask = zeros(size(Ext_Coef)); cld_mask(cld) = NaN;
imagesc(by_ht.time, by_ht.height./1000, real(log10(Ext_Coef))+cld_mask);axis('xy'); dynamicDateTicks; ylabel('Height [km AMSL]');colorbar 
caxis([-5.5,0])
cm = colormap; cm(1,:) = 0;cm(end,:) = 1; 
colormap(cm)
title({'GVHSRL SOCRATES Jan 29, 2018';'True (not-scaled) Extinction Profiles'})
sum(sum(cld))

ans =

     0

cld = Ext_Coef >1e-4; cld_mask = zeros(size(Ext_Coef)); cld_mask(cld) = NaN;
aero = Ext_Coef<1e-4;
Ext_Coef(cld) = Ext_Coef(cld).*11;
Ext_Coef(aero) = Ext_Coef(aero).*21;

figure; imagesc(by_ht.time, by_ht.height./1000, real(log10(Ext_Coef))+cld_mask);axis('xy'); dynamicDateTicks; ylabel('Height [km AMSL]');colorbar 
caxis([-5.5,0])
cm = colormap; cm(1,:) = 0;cm(end,:) = 1; 
colormap(cm)
caxis([-5.5,-2])
cm = colormap; cm(1,:) = 0;cm(end,:) = 1; 
colormap(cm)
figure; imagesc(by_ht.time, by_ht.height./1000, real(log10(Ext_Coef*1e6))+cld_mask);axis('xy'); dynamicDateTicks; ylabel('Height [km AMSL]');colorbar 
caxis([.5,3])
cm = colormap; cm(1,:) = 0;cm(end,:) = 1; 
colormap(cm)
figure; imagesc(by_ht.time, by_ht.height./1000, real(log10(Ext_Coef*1e6))+cld_mask);axis('xy'); dynamicDateTicks; ylabel('Height [km AMSL]');colorbar 
caxis([.5,4])
cm = colormap; cm(1,:) = 0;cm(end,:) = 1; 
colormap(cm)
figure; imagesc(by_ht.time, by_ht.height./1000, real(log10(Ext_Coef*1e6))+cld_mask);axis('xy'); dynamicDateTicks; ylabel('Height [km AMSL]');colorbar 
caxis([0,4])
cm = colormap; cm(1,:) = 0;cm(end,:) = 1; 
colormap(cm)
Ext_coef(:,scope==1) = NaN;

figure; imagesc(by_ht.time, by_ht.height./1000, real(log10(Ext_Coef*1e6))+cld_mask);axis('xy'); dynamicDateTicks; ylabel('Height [km AMSL]');colorbar 
caxis([0,4])
cm = colormap; cm(1,:) = 0;cm(end,:) = 1; 
colormap(cm)
Ext_Coef(:,scope==1) = NaN;

figure; imagesc(by_ht.time, by_ht.height./1000, real(log10(Ext_Coef*1e6))+cld_mask);axis('xy'); dynamicDateTicks; ylabel('Height [km AMSL]');colorbar 
caxis([0,4])
cm = colormap; cm(1,:) = 0;cm(end,:) = 1; 
colormap(cm)
caxis([-3,3])
caxis([0,3])
pos_ext= NaN(size(ln_rho_by_S));
Ht = NaN(size(by_ht.time)); Sa = Ht; Bb = Ht;
dt = 12;% delta time increments (120 sec)
dd = 20;% delta range bins (150 m)
for t  = (length(by_ht.time)-dt):-1:1
   tt = [t:t+dt];
   mln = mean(ln_rho_by_S(:,tt),2);
   % figure; plot(by_ht.height, mln,'-'); legend('ln rho by S')
   Bbs = 1e6.*mean(by_ht.Aerosol_Backscatter_Coefficient((1:end-dd),tt),2);
   ext = 1e6.*(mln(1:(end-dd))-mln((1+dd):end))./(height(dd+1)-height(1));
   ext = posify_prof(ext); ext(ext<Bbs) = 0;
   pos_ext(:,t) = ext;
   ht = by_ht.height((1):end-dd);
   h_ = pos_ext(:,t)>0 & Bbs>1e-5;
   if sum(h_)>5
   Bb(t) = trapz(by_ht.height(h_),Bbs(h_));
      Sa(t) = trapz(by_ht.height(h_),pos_ext(h_,t))./trapz(by_ht.height(h_),Bbs(h_));
   Ht(t) = trapz(by_ht.height(h_),by_ht.height(h_).*Bbs(h_))./trapz(by_ht.height(h_),Bbs(h_));
   end
   % figure_(12); plot(ht, pos_ext(:,t),'-',ht,Bbs ,'g-');logy
   % ylabel('Ext [1/Mm]'); xlabel('height [m]');
   % title({datestr(by_ht.time(t),'yyyy-mm-dd HH:MM');sprintf('Sa = %2.1f', Sa(t))})
   % legend('Ext','Bscat')
   % pause(1)
   % clf
   sprintf('%s', datestr(by_ht.time(t),'HH:MM:SS'))
end
{Unable to perform assignment because the size of the left side is 1867-by-1 and the size of the right side is 1847-by-1.
} 
pos_ext= NaN(size(ln_rho_by_S));
Ht = NaN(size(by_ht.time)); Sa = Ht; Bb = Ht;
dt = 12;% delta time increments (120 sec)
dd = 20;% delta range bins (150 m)
t  = (length(by_ht.time)-dt)

t =

        2196

tt = [t:t+dt];
   mln = mean(ln_rho_by_S(:,tt),2);
   % figure; plot(by_ht.height, mln,'-'); legend('ln rho by S')
   Bbs = 1e6.*mean(by_ht.Aerosol_Backscatter_Coefficient((1:end-dd),tt),2);
ext = 1e6.*(mln(1:(end-dd))-mln((1+dd):end))./(height(dd+1)-height(1));
   ext = posify_prof(ext); ext(ext<Bbs) = 0;
pos_ext(:,t) = ext;
{Unable to perform assignment because the size of the left side is 1867-by-1 and the size of the right side is 1847-by-1.
} 
  pos_ext((1:(end-dd)),t) = ext;
   ht = by_ht.height((1):end-dd);
   h_ = pos_ext(:,t)>0 & Bbs>1e-5;
{Arrays have incompatible sizes for this operation.

<a href="matlab:helpview('matlab','error_sizeDimensionsMustMatch')" style="font-weight:bold">Related documentation</a>
} 
 h_ = pos_ext((1:(end-dd)),t)>0 & Bbs>1e-5;
 if sum(h_)>5
   Bb(t) = trapz(by_ht.height(h_),Bbs(h_));
      Sa(t) = trapz(by_ht.height(h_),pos_ext(h_,t))./trapz(by_ht.height(h_),Bbs(h_));
   Ht(t) = trapz(by_ht.height(h_),by_ht.height(h_).*Bbs(h_))./trapz(by_ht.height(h_),Bbs(h_));
   end
pos_ext= NaN(size(ln_rho_by_S));
Ht = NaN(size(by_ht.time)); Sa = Ht; Bb = Ht;
dt = 12;% delta time increments (120 sec)
dd = 20;% delta range bins (150 m)
for t  = (length(by_ht.time)-dt):-1:1
   tt = [t:t+dt];
   mln = mean(ln_rho_by_S(:,tt),2);
   % figure; plot(by_ht.height, mln,'-'); legend('ln rho by S')
   Bbs = 1e6.*mean(by_ht.Aerosol_Backscatter_Coefficient((1:end-dd),tt),2);
   ext = 1e6.*(mln(1:(end-dd))-mln((1+dd):end))./(height(dd+1)-height(1));
   ext = posify_prof(ext); ext(ext<Bbs) = 0;
   pos_ext((1:(end-dd)),t) = ext;
   ht = by_ht.height((1):end-dd);
   h_ = pos_ext((1:(end-dd)),t)>0 & Bbs>1e-5;
   if sum(h_)>5
   Bb(t) = trapz(by_ht.height(h_),Bbs(h_));
      Sa(t) = trapz(by_ht.height(h_),pos_ext(h_,t))./trapz(by_ht.height(h_),Bbs(h_));
   Ht(t) = trapz(by_ht.height(h_),by_ht.height(h_).*Bbs(h_))./trapz(by_ht.height(h_),Bbs(h_));
   end
   % figure_(12); plot(ht, pos_ext(:,t),'-',ht,Bbs ,'g-');logy
   % ylabel('Ext [1/Mm]'); xlabel('height [m]');
   % title({datestr(by_ht.time(t),'yyyy-mm-dd HH:MM');sprintf('Sa = %2.1f', Sa(t))})
   % legend('Ext','Bscat')
   % pause(1)
   % clf
   sprintf('%s', datestr(by_ht.time(t),'HH:MM:SS'))
end



Ht(Ht==0|Ht>7500) = NaN;
Sa(Sa==0|Sa>35) = NaN;
Ht(Ht==0) = NaN;
scope = interp1(hsrl.time, hsrl.vdata.TelescopeDirection, by_ht.time,'nearest','extrap');
Ht(scope==1) = NaN;
Sa(scope==1) = NaN;
Ht(scope==1) = NaN;
Bb(isnan(Ht)|isnan(Sa)) = NaN;
pos_ext(:,scope==1) = NaN;
figure; plot(by_ht.time(1:end-dt),Ht,'o'); legend('layer height');dynamicDateTicks 
{Error using <a href="matlab:matlab.internal.language.introspective.errorDocCallback('plot')" style="font-weight:bold">plot</a>
Vectors must be the same length.
} 
figure; plot(by_ht.time,Ht,'o'); legend('layer height');dynamicDateTicks 
figure; scatter(Sa,Bb, 12, Ht,'filled'); xlabel('Bb'); ylabel('Sa');
figure; plot(Ht./1000, Sa,'*'); xlabel('Height [km]'); ylabel('Sa');
figure; 
subplot(1,2,1); histogram(Sa(Bb>1e4));title({'PDF for Bs>1e4 sr/m';'"Cloud"'});; xlabel('Sa')
subplot(1,2,2); histogram(Sa(Bb<1e4));title({'PDF for Bs<1e4 sr/m';'"Aerosol"'});; xlabel('Sa')
figure; imagesc(by_ht.time, by_ht.height, real(log10(pos_ext))); axis('xy');  dynamicDateTicks
ylabel('Ext [1/Mm]');
colorbar;caxis([.25,3])
cm = colormap; cm(1,:) = 0;cm(end,:) = 1; 
colormap(cm)
colorbar;caxis([.25,2.5])
cm = colormap; cm(1,:) = 0;cm(end,:) = 1; 
colormap(cm)
colorbar;caxis([.25,3])
cm = colormap; cm(1,:) = 0;cm(end,:) = 1; 
colormap(cm)
figure; plot(by_ht.Aerosol_Backscatter_Coefficient(:), pos_ext(:),'.')
figure; plot(by_ht.Aerosol_Backscatter_Coefficient(:), pos_ext(:)./by_ht.Aerosol_Backscatter_Coefficient(:),'.')
figure; plot(by_ht.Aerosol_Backscatter_Coefficient(:), 1e6.*pos_ext(:)./by_ht.Aerosol_Backscatter_Coefficient(:),'.')
figure; plot(1e6.*by_ht.Aerosol_Backscatter_Coefficient(:), 1e-6/*pos_ext(:)./by_ht.Aerosol_Backscatter_Coefficient(:),'.')
 figure; plot(1e6.*by_ht.Aerosol_Backscatter_Coefficient(:), 1e-6/*pos_ext(:)./by_ht.Aerosol_Backscatter_Coefficient(:),'.')
                                                                  ↑
{Invalid use of operator.
} 
figure; plot(1e6.*by_ht.Aerosol_Backscatter_Coefficient(:), 1e-6.*pos_ext(:)./by_ht.Aerosol_Backscatter_Coefficient(:),'.')
figure; plot(1e6.*by_ht.Aerosol_Backscatter_Coefficient(:), 1e-6.*pos_ext(:)./by_ht.Aerosol_Backscatter_Coefficient(:),'.'); logy; logx
Ext_Coef = by_ht.Aerosol_Backscatter_Coefficient;
cld = Ext_Coef >1e-4; cld_mask = zeros(size(Ext_Coef)); cld_mask(cld) = NaN;
aero = Ext_Coef<1e-4;
Ext_Coef(cld) = Ext_Coef(cld).*11;
Ext_Coef(aero) = Ext_Coef(aero).*21;
Ext_Coef(:,scope==1) = NaN;


figure; imagesc(by_ht.time, by_ht.height./1000, real(log10(Ext_Coef*1e6))+cld_mask);axis('xy'); dynamicDateTicks; ylabel('Height [km AMSL]');colorbar 
caxis([0,4])
cm = colormap; cm(1,:) = 0;cm(end,:) = 1; 
colormap(cm)
Ext_Coef = by_ht.Aerosol_Backscatter_Coefficient+pos_ext-pos_ext;
cld = Ext_Coef >1e-4; cld_mask = zeros(size(Ext_Coef)); cld_mask(cld) = NaN;
aero = Ext_Coef<1e-4;
Ext_Coef(cld) = Ext_Coef(cld).*11;
Ext_Coef(aero) = Ext_Coef(aero).*21;
Ext_Coef(:,scope==1) = NaN;


figure; imagesc(by_ht.time, by_ht.height./1000, real(log10(Ext_Coef*1e6))+cld_mask);axis('xy'); dynamicDateTicks; ylabel('Height [km AMSL]');colorbar 
caxis([0,4])
cm = colormap; cm(1,:) = 0;cm(end,:) = 1; 
colormap(cm)
sum(sum(isNan(pos_ext)))
{Unrecognized function or variable 'isNan'.
} 
sum(sum(isnan(pos_ext)))

ans =

     2873728

sum(sum(~isnan(pos_ext)))

ans =

     1248608

figure; imagesc(by_ht.time, by_ht.height./1000, isnan(pos_ext)); axis('xy');
Ext_Coef(pos_ext<=0) = NaN;
figure; imagesc(by_ht.time, by_ht.height./1000, real(log10(Ext_Coef*1e6))+cld_mask);axis('xy'); dynamicDateTicks; ylabel('Height [km AMSL]');colorbar 
caxis([0,4])
cm = colormap; cm(1,:) = 0;cm(end,:) = 1; 
colormap(cm)
caxis([0.5,3])
cm = colormap; cm(1,:) = 0;cm(end,:) = 1; 
colormap(cm)
cld_mask(cld) = inf;
figure; imagesc(by_ht.time, by_ht.height./1000, real(log10(Ext_Coef*1e6))+cld_mask);axis('xy'); dynamicDateTicks; ylabel('Height [km AMSL]');colorbar 
caxis([0.5,3])
cm = colormap; cm(1,:) = 0;cm(end,:) = 1; 
colormap(cm)
