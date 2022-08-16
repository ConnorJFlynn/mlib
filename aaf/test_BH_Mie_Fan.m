Fan = load(['C:\Users\flyn0011\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\translator\AAF\2021_Nov\sgpaafpopsext.01\20211109_SN09.mat']);
Fan = Fan.MSave;

cts = Fan.MC(:,28:127);size(cts)

SD = [popsb1.vdata.dn_135_150;popsb1.vdata.dn_150_170;popsb1.vdata.dn_170_195; popsb1.vdata.dn_195_220; popsb1.vdata.dn_220_260; popsb1.vdata.dn_260_335; popsb1.vdata.dn_335_510;popsb1.vdata.dn_510_705; popsb1.vdata.dn_705_1380; popsb1.vdata.dn_1380_1760; popsb1.vdata.dn_1760_2550; popsb1.vdata.dn_2550_3615]';

bounds = [135,150,170,195,220,260,335,510, 705, 1380, 1760, 2550, 3615]';
Dp = mean([bounds(1:end-1), bounds(2:end)],2);
dlogDp = log10(bounds(2:end)./bounds(1:end-1)); % log10
for bin = (length(bounds)-1)-1:1
   these = Fan.Dp>=bounds(bin)&Fan.Dp<bounds(bin+1);
   rebinned(:,bin) = sum(cts(:,these),2);
end
bounds12 = logspace(log10(135), log10(3615),33);
Dp12 = mean([bounds12(1:end-1); bounds12(2:end)]);
dlogDp12 = log10(bounds12(2:end)./bounds12(1:end-1)); 
for bin = (length(bounds12)-1):-1:1
   these = Fan.Dp>=bounds12(bin)&Fan.Dp<bounds12(bin+1);
   rebinned12(:,bin) = sum(cts(:,these),2)./Dp12(bin);
end
% So, we could check to see that we still get the unusual spectral response
% with the dlogDp and dNdlogDp quantities from the b1 file
figure_(12); clf(12)
for t = 100:100:6500
 ok = rebinned12(t,:)>=0; ok(1) = false; ok(16:end)=false;
nm = [350:50:1600]
for ni = 1:length(nm)
retval = SizeDist_Optics(1.52+.01i, Dp12(ok)', rebinned12(t,ok)', nm(ni), 'normalized',false,'nobackscat',true);
ext(ni) = retval.extinction;
end
 plot(nm, ext,'-o'); hold('on')
pause(.1);
end

retval = SizeDist_Optics(1.52, Dp12(ok), rebinned12(t,ok), 355, 'normalized',false,'nobackscat',true)

% And then repeat with a 12-logspaced bins as below.



% rebinned is about a factor of 30 larger than popsb1.dn, but other wise
% the same.
new_bounds = logspace(log10(135), log10(3615),32);

% log10
