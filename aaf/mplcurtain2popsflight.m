function ants = timehtcurtain2fltlvl(mpl, pops)
if ~isavar('mpl')||isempty(mpl)
    mpl = anc_load(getfullname('*mpl*kext*.mat','kext'));
end
% alpha_a is transpose so size(dim1) == length(mpl.time) for interp1
ext_curtain = interp1(mpl.time, mpl.klett.alpha_a', pops.time, 'linear')';

bin = interp1(mpl.range(1:1001),[1:1001],pops.vdata.alt./1000, 'nearest','extrap');

ants = real(ext_curtain(sub2ind(size(ext_curtain),bin, 1:length(bin))));

% % This also works...
% for t = length(aafnav.time):-1:1
%    out(t) = real(ext_curtain(bin(t),t));
% end
miss = pops.vdata.alt < 0; pops.vdata.alt(miss) = NaN;

figure; scatter((pops.time), pops.vdata.alt./1000, 12, ants); dynamicDateTicks;
cb = colorbar; set(get(cb,'title'),'string',{'B_e_x_t [1/km]'}); 

figure; plot(ants, pops.vdata.alt,'x'); xlabel('ext [1/km]'); ylabel('flight alt (m AGL)');
title('MPL extinction profile mapped to AAF U2 flight for July 9, 2022')

figure; sb(1) = subplot(2,1,2); plot(pops.time, pops.vdata.alt, 'o'); dynamicDateTicks
ylabel('altitude [m AGL]'); xlabel('time [UT]')
sb(2) = subplot(2,1,1); plot(pops.time, ext_by_Mm.*10, '.', pops.time, ants.*1000,'m');logy;liny
dynamicDateTicks; ylabel('Extinction [1/km]'); legend('10xPOPS','MPLext')
title({'Extinction comparison, POPS and MPL';['SGP ',datestr(pops.time(1),'yyyy-mm-dd HH:MM-'),datestr(pops.time(end),'HH:MM')]});
linkaxes(sb,'x');

figure; plot(ants.*1000, ext_by_Mm.*10, '.')


end