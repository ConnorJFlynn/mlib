function mono = SAS_temp_test_interp_dk_with_headers(indir)
% Now reading new data format with 1 file per spectrometer, each file has a
% header row identifying the measurements in underlying columns.

% The case of the NIR has been removed to speed approach of thermal
% equilibrium

inside_spec = SAS_read_Albert_csv(getfullname('*.csv','ava','Select inside spectrometer'));
outside_spec = SAS_read_Albert_csv(getfullname('*.csv','ava','Select outside spectrometer'));
trh = SAS_read_trh(getfullname('*.csv','ava','Select trh file'));

ins_dark = (inside_spec.Shuttered_0==0);
for m = length(inside_spec.time):-1:1
     for ii = length(inside_spec.nm):-1:1
             back_ins(ii) = interp1(inside_spec.time(ins_dark)-inside_spec.time(1), inside_spec.spec(ins_dark,ii),inside_spec.time(m)-inside_spec.time(1),'linear','extrap'); 
     end
     inside_spec.spec_sans_dark(m,:) = inside_spec.spec(m,:) - back_ins;
end     

figure; plot(serial2Hh(trh.time), trh.Temp1+9, 'r',serial2Hh(inside_spec.time), inside_spec.Temp, 'g',serial2Hh(outside_spec.time), outside_spec.Temp, 'b'  )
legend('Temp sensor','spec temp','oat');
%%
figure; lines1 = plot(inside_spec.nm, inside_spec.spec_sans_dark./outside_spec.spec, '-');
lines1 = recolor(lines1, inside_spec.Temp',[-5,5]);colorbar

%%
figure; lines2 = plot(inside_spec.nm, inside_spec.spec_sans_dark, '-');

lines2 = recolor(lines2, inside_spec.Temp');colorbar
%%
inside_spec.dif_spec = diff(inside_spec.spec_sans_dark);
inside_spec.normdif_spec = inside_spec.dif_spec./inside_spec.spec_sans_dark(2:end,:);
inside_spec.dif_temp = diff(inside_spec.Temp);
inside_spec.normdif_spec_dT = inside_spec.normdif_spec./(inside_spec.dif_temp*ones(size(inside_spec.nm)));


%%
figure; lines3 = semilogy(inside_spec.nm, abs(inside_spec.normdif_spec), '-');
lines3 = recolor(lines3,inside_spec.Temp(2:end)',[-5,10]);
colorbar
title('differential stability versus nm and temperature')

%%
figure; plot(inside_spec.Temp, sum(abs(diff(inside_spec.spec_sans_dark,[],2)),2),'o')
%%
%%
figure; plot(inside_spec.Temp(inside_spec.Shuttered_0==0), mean(inside_spec.spec(inside_spec.Shuttered_0==0,:),2),'o')
title('Sum of dark counts vs Temp')
%%

return
     