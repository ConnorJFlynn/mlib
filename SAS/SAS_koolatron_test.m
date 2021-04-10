function mono = SAS_koolatron_test(indir)
% Now reading new data format with 1 file per spectrometer, each file has a
% header row identifying the measurements in underlying columns.
tmp = getfullname('*.csv','ava','Select vis spectrometer 37');
[pname, fname, ext] = fileparts(tmp);
inside_spec = SAS_read_Albert_csv(tmp);
inside_spec.pname = pname;
inside_spec.fname = [fname, ext];
[dmp, sn] = strtok(fname,'_');
inside_spec.sn = sn(2:end);
tmp = getfullname('*.csv','ava','Select NIR spectrometer 46');
[pname, fname, ext] = fileparts(tmp);
outside_spec = SAS_read_Albert_csv(tmp);
outside_spec.pname = pname;
outside_spec.fname = [fname, ext];
[dmp, sn] = strtok(fname,'_');
outside_spec.sn = sn(2:end);
tmp = getfullname('*.csv','ava','Select trh file');
[pname, fname, ext] = fileparts(tmp);
trh = SAS_read_trh(tmp);
trh.pname = pname;
trh.fname = [fname, ext];

%Minor (but unexplained) difference between Albert and my computation of
%Humirel temperatures
%More significant (and unexplained) differences between precon and humirel
%RH measurements
%%
figure; plot(serial2doy(trh.time), [trh.Temp1,trh.Temp2],'-',serial2doy(inside_spec.time), inside_spec.Temp, '-o', serial2doy(outside_spec.time), outside_spec.Temp,'-x');
legend('precon T','humirel T','vis Temp','nir Temp')
%%
ins_dark = (inside_spec.Shuttered_0==0);
for m = length(inside_spec.time):-1:1
     for ii = length(inside_spec.nm):-1:1
             back_ins(ii) = interp1(inside_spec.time(ins_dark)-inside_spec.time(1), inside_spec.spec(ins_dark,ii),inside_spec.time(m)-inside_spec.time(1),'linear','extrap'); 
     end
     inside_spec.spec_sans_dark(m,:) = inside_spec.spec(m,:) - back_ins;
end     

figure; plot(serial2Hh(trh.time), trh.Temp1+9, 'r',serial2Hh(inside_spec.time), inside_spec.Temp, 'g',serial2Hh(outside_spec.time), outside_spec.Temp, 'b'  )
legend('Temp sensor','spec temp','oat');

% figure; lines = plot(inside_spec.nm, inside_spec.spec_sans_dark./outside_spec.spec, '-');
% lines = recolor(lines, inside_spec.Temp');colorbar

%%
figure; lines = plot(inside_spec.nm, inside_spec.spec_sans_dark, '-');
%%
lines = recolor(lines, inside_spec.Temp');colorbar
%%
inside_spec.dif_spec = diff(inside_spec.spec_sans_dark);
inside_spec.normdif_spec = inside_spec.dif_spec./inside_spec.spec_sans_dark(2:end,:);
inside_spec.dif_temp = diff(inside_spec.Temp);
inside_spec.normdif_spec_dT = inside_spec.normdif_spec./(inside_spec.dif_temp*ones(size(inside_spec.nm)));

%%
figure; lines3 = semilogy(inside_spec.nm, abs(inside_spec.normdif_spec), '-');
lines3 = recolor(lines3,inside_spec.Temp(2:end)',[-5,10]);
colorbar
title({['Pixel-by-pixel temporal stability of NIR  under changing temperature'],inside_spec.sn})

%%
figure; plot(inside_spec.Temp(1:400), sum(abs(diff(inside_spec.spec_sans_dark(1:400,:),[],2)),2),'o');
title({['Pixel-to-pixel variability of NIR under changing temperature'],inside_spec.sn})
xlabel('Temperature [deg C]');
ylabel('sum(abs(diff(mono.spec_nir)))','interp','none')
%%
ii = find(inside_spec.Shuttered_0(1:250)==0);
figure; plot(inside_spec.Temp(ii), mean(inside_spec.spec(ii,:),2),'o')
title('Sum of dark counts vs Temp')

%%
return
     