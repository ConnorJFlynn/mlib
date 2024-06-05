% hsrl = bundlen_gvhsrl([],20);
% save('C:\Users\Connor Flynn\OneDrive - University of Oklahoma\Desktop\xdata\eol\socrates\hsrl_10s.mat','-struct','hsrl');
tic;
hsrl = load(['C:\Users\Connor Flynn\OneDrive - University of Oklahoma\Desktop\xdata\eol\socrates\hsrl_10s.mat']);
toc

tic
% Check "Channel"s for range correction and bg subtraction...
for Tt = length(hsrl.vdata.time):-1:1
   mol_bg(Tt) = mean(hsrl.vdata.Molecular_Backscatter_Channel(end-100:end,Tt));
   % hsrl.vdata.Molecular_Backscatter_Channel = hsrl.vdata.Molecular_Backscatter_Channel - bg;
   hg_bg(Tt) = mean(hsrl.vdata.High_Gain_Total_Backscatter_Channel(end-100:end,Tt));
   % hsrl.vdata.High_Gain_Total_Backscatter_Channel = hsrl.vdata.High_Gain_Total_Backscatter_Channel - bg;
   mg_bg(Tt) = mean(hsrl.vdata.Merged_Combined_Channel(end-100:end,Tt));
   % hsrl.vdata.Merged_Combined_Channel = hsrl.vdata.Merged_Combined_Channel - bg;
   cp_bg(Tt) = mean(hsrl.vdata.Cross_Polarization_Channel(end-100:end,Tt));
   % hsrl.vdata.Cross_Polarization_Channel = hsrl.vdata.Cross_Polarization_Channel - bg;
end
toc
tic
hsrl.vdata.Molecular_Backscatter_Channel = hsrl.vdata.Molecular_Backscatter_Channel-mol_bg;
hsrl.vdata.High_Gain_Total_Backscatter_Channel = hsrl.vdata.High_Gain_Total_Backscatter_Channel-hg_bg;
hsrl.vdata.Merged_Combined_Channel = hsrl.vdata.Merged_Combined_Channel-mg_bg;
hsrl.vdata.Cross_Polarization_Channel = hsrl.vdata.Cross_Polarization_Channel-cp_bg;
toc

tic
hsrl.vdata.Molecular_Backscatter_Channel = hsrl.vdata.Molecular_Backscatter_Channel .* (hsrl.vdata.range.^2);
hsrl.vdata.Merged_Combined_Channel = hsrl.vdata.Merged_Combined_Channel .* (hsrl.vdata.range.^2);
hsrl.vdata.High_Gain_Total_Backscatter_Channel = hsrl.vdata.High_Gain_Total_Backscatter_Channel .* (hsrl.vdata.range.^2);
hsrl.vdata.Cross_Polarization_Channel = hsrl.vdata.Cross_Polarization_Channel .* (hsrl.vdata.range.^2);
toc

raycor = hsrl_raycor(hsrl.vdata.range);


tic
hsrl.vdata.Molecular_Backscatter_Channel = hsrl.vdata.Molecular_Backscatter_Channel .* raycor;
hsrl.vdata.Merged_Combined_Channel = hsrl.vdata.Merged_Combined_Channel .* raycor;
hsrl.vdata.High_Gain_Total_Backscatter_Channel = hsrl.vdata.High_Gain_Total_Backscatter_Channel .* raycor;
hsrl.vdata.Cross_Polarization_Channel = hsrl.vdata.Cross_Polarization_Channel .* raycor;
toc

figure; plot(hsrl.vdata.range, ...
   [hsrl.vdata.Molecular_Backscatter_Channel(:,1500),hsrl.vdata.High_Gain_Total_Backscatter_Channel(:,1500),...
   hsrl.vdata.Merged_Combined_Channel(:,1500), hsrl.vdata.Cross_Polarization_Channel(:,1500) ],'-'); logy
legend('mole','high gain','merged','cross')


figure; plot(hsrl.vdata.range, ...
   [hsrl.vdata.Molecular_Backscatter_Channel(:,1500)],'-',...
   hsrl.vdata.range, 5e13.*hsrl.vdata.Molecular_Backscatter_Coefficient(:,1500),'k-'); logy
legend('mole ch', 'mole coef');


% Apparently I did this correctly before because the function for raycor does a good
% job of recovering a flat ratio.



height = hsrl.vdata.range;
height2 = [0:7.5:max(height)];
clear by_ht
by_ht.time = hsrl.time;
by_ht.height = height2';
fields = fieldnames(hsrl.vatts);

% Copy time&height dimensioned field to "by_ht"
for f = 1:length(fields)
   fld = fields{f};
   if any(strcmp(hsrl.ncdef.vars.(fld).dims,'time'))&&any(strcmp(hsrl.ncdef.vars.(fld).dims,'range')) &&~foundstr(fld,'_variance')&&~foundstr(fld,'_mask')
      by_ht.(fld) = NaN([length(by_ht.height),length(by_ht.time)]);
   end
end

% Incorporate Telescope Direction and aircraft altitude to express height AGL
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

% figure; plot(hsrl.vdata.rangeFull, (hsrl.vdata.Raw_Molecular_Backscatter_Channel(:,1500) - mean(hsrl.vdata.Raw_Molecular_Backscatter_Channel(2000:end,1500))).*hsrl.vdata.rangeFull.^2, 'r-',...
%    hsrl.vdata.range, (hsrl.vdata.Molecular_Backscatter_Channel(:,1500)-mean(hsrl.vdata.Molecular_Backscatter_Channel(end-50:end,1500))),'-b')
% 
% figure; plot(hsrl.vdata.rangeFull, hsrl.vdata.Raw_Molecular_Backscatter_Channel(:,1500) - mean(hsrl.vdata.Raw_Molecular_Backscatter_Channel(2000:end,1500)), 'r-',...
%    hsrl.vdata.range, hsrl.vdata.Molecular_Backscatter_Channel(:,1500),'-k'); logy
% legend('Raw Mol Ch - bg','Mol Ch')
% % Some unexplained factor of ~1.5 between raw_Molecular_*_Channel and
% % Molecular_*_Channel.  Maybe pileup?  Apparently no overlap or range correction
% % applied at this stage.
% 
% figure; plot(...
%    hsrl.vdata.range, 6.5e7.*hsrl.vdata.Molecular_Backscatter_Coefficient(:,1700),'--r',...
%    hsrl.vdata.range, 1e-6.*mean(hsrl.vdata.Molecular_Backscatter_Channel(:,1700:1750),2),'-k'...
%    ); logy;
% legend('1e8*Rayleigh','Mol Ch');
% 
% % was I supposed to range correct for this comparison?
% figure; plot(...
%    hsrl.vdata.range, 1e8.*hsrl.vdata.Molecular_Backscatter_Coefficient(:,1500),'--r',...
%    hsrl.vdata.range, 1.8e-6*(hsrl.vdata.Molecular_Backscatter_Channel(:,1500)-mean(hsrl.vdata.Molecular_Backscatter_Channel((end-50):end,1500)))...
%    .*hsrl.vdata.range.^2,'-k'); logy;
% legend('Rayleigh','Mol Ch');
% 
% % I don't think I can easily apply a range-correction after building into by_ht;

figure; plot(by_ht.height, 6.5e7.*by_ht.Molecular_Backscatter_Coefficient(:,1700),'--r',...
   by_ht.height, 1e-6.*mean(by_ht.Molecular_Backscatter_Channel(:,1700:1750),2),'-k'...
   ); logy;
ln_rho_by_S = 0.5.*real(log(by_ht.Molecular_Backscatter_Coefficient./by_ht.Molecular_Backscatter_Channel)); 


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
figure; plot(by_ht.time,Ht,'o'); legend('layer height');dynamicDateTicks 
figure; plot(Ht./1000, Sa,'*'); xlabel('Height [km]'); ylabel('Sa');


figure; 
subplot(1,2,1); histogram(Sa(Bb>5e4));title({'PDF for Bs>5e4 sr/m';'"Cloud"'});; xlabel('Sa')
subplot(1,2,2); histogram(Sa(Bb<5e4));title({'PDF for Bs<5e4 sr/m';'"Aerosol"'});; xlabel('Sa')
figure; imagesc(by_ht.time, by_ht.height, real(log10(pos_ext))); axis('xy');  dynamicDateTicks
ylabel('Ext [1/Mm]');
colorbar;caxis([.25,3])
cm = colormap; cm(1,:) = 0;cm(end,:) = 1; 
colormap(cm)

Ext_Coef = by_ht.Aerosol_Backscatter_Coefficient+pos_ext-pos_ext;
cld = Ext_Coef >1e-4; cld_mask = zeros(size(Ext_Coef)); cld_mask(cld) = inf;
aero = Ext_Coef<1e-4;
Ext_Coef(cld) = Ext_Coef(cld).*11;
Ext_Coef(aero) = Ext_Coef(aero).*21;
Ext_Coef(:,scope==1) = NaN;
Ext_Coef(pos_ext<=0) = NaN;
figure; imagesc(by_ht.time, by_ht.height./1000, real(log10(Ext_Coef*1e6))+cld_mask);axis('xy'); dynamicDateTicks; ylabel('Height [km AMSL]');colorbar 
caxis([0.5,3])
cm = colormap; cm(1,:) = 0;cm(end,:) = 1; 
colormap(cm)

