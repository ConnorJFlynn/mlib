a0  = anc_load;
SB1 = find(a0.vdata.tag==7);
SB2 = find(a0.vdata.tag==9);
SB3 = find(a0.vdata.tag==11);
if min(a0.vdata.wavelength)>500
pix = 33;
else
pix = 555;
end

SB1 = find(a0.vdata.tag==7);
SB2 = find(a0.vdata.tag==9);
SB3 = find(a0.vdata.tag==11);
N = N+1;
seq = [SB2(N),SB1(N),  SB3(N)];
bands = [a0.vdata.spectra(pix,SB2(N)),a0.vdata.spectra(pix,SB1(N)),a0.vdata.spectra(pix,SB3(N))];
[BB, ij] = sort(bands);
blocked = a0.vdata.spectra(:,seq(ij(1)));
flip = ij(1)~=1;
if flip
display('flipped!')
unblocked = a0.vdata.spectra(:,seq(ij(end)));
else
display('not flipped')
unblocked = mean(a0.vdata.spectra(:,seq(ij(2:end))),2);
end
dh = (unblocked - blocked)./a0.vdata.integration_time(1);
b1 = anc_load;
dh_irad = dh ./ b1.vdata.responsivity_vis;
figure; plot(a0.vdata.wavelength, dh_irad,'-')

v = axis;

figure; plot(a0.vdata.wavelength, dh_irad.*b1.vdata.cosine_correction_computed(1),'-', b1.vdata.wavelength_vis, b1.vdata.direct_horizontal_vis(:,1), 'r--');
axis(v);
legend('from a0','from b1')

