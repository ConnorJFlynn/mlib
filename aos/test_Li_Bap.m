function test_Li_Bap

% Get PSAP and Neph 1m datastreams.  Filter both to accept only good.
% Plot both time series and anc_sift

psap = anc_bundle_files(getfullname('sgpaospsap*','psap'));
neph = anc_bundle_files(getfullname('sgpaosneph*','neph'));

good_BaB= anc_qc_impacts(psap.vdata.qc_Ba_B_Weiss, psap.vatts.qc_Ba_B_Weiss)==0;
good_BaG = anc_qc_impacts(psap.vdata.qc_Ba_G_Weiss, psap.vatts.qc_Ba_G_Weiss)==0;
good_BaR = anc_qc_impacts(psap.vdata.qc_Ba_R_Weiss, psap.vatts.qc_Ba_R_Weiss)==0;
psap_good = anc_sift(psap, good_BaB & good_BaG & good_BaR);

good_BsB = anc_qc_impacts(neph.vdata.qc_Bs_B_Dry_Neph3W, neph.vatts.qc_Bs_B_Dry_Neph3W)==0;
good_BsG = anc_qc_impacts(neph.vdata.qc_Bs_G_Dry_Neph3W, neph.vatts.qc_Bs_G_Dry_Neph3W)==0;
good_BsR = anc_qc_impacts(neph.vdata.qc_Bs_R_Dry_Neph3W, neph.vatts.qc_Bs_R_Dry_Neph3W)==0;
neph_good = anc_sift(neph, good_BsB & good_BsG & good_BsR);

ARM_display_beta(psap_good); %Zoom into plot to select desired time range
menu('Click ok after zooming into plot to select desired time range','OK')
xl = xlim;
xl_psap = psap_good.time>=xl(1)&psap_good.time<xl(2);
psap_good = anc_sift(psap_good, xl_psap);
xl_neph = neph_good.time>=xl(1)&neph_good.time<xl(2);
neph_good = anc_sift(neph_good,xl_neph);

[ninp, pinn] = nearest(neph_good.time, psap_good.time);
neph_good = anc_sift(neph_good, ninp);
psap_good = anc_sift(psap_good, pinn);

Tr = [psap_good.vdata.transmittance_blue; psap_good.vdata.transmittance_green; psap_good.vdata.transmittance_red];
Ba = [psap_good.vdata.Ba_B_raw; psap_good.vdata.Ba_G_raw; psap_good.vdata.Ba_R_raw];
Bsp = [neph_good.vdata.Bs_B_Dry_Neph3W; neph_good.vdata.Bs_G_Dry_Neph3W; neph_good.vdata.Bs_R_Dry_Neph3W ];
Tr_ = psap_good.vdata.transmittance_blue; Ba_raw = psap_good.vdata.Ba_B_raw; Bs = neph_good.vdata.Bs_B_Dry_Neph3W;
[Ba_V,ii_,k0,k1,h0,h1,s,ssa] = Virk_wi_sca(Tr_,Ba_raw,Bs,4);

Bep = Bs + Ba_V;

[Ba_1, Ba_2, Ba_3, Z1, Z2, Z3] = Virk4P(Tr_,Ba_raw, Bep, Bs, ssa);

[Bap,aae,ssa, Gn] = Li_Bap(Tr,Ba, [],Bsp);
figure; plot(psap_good.time, Ba,'*')

dout = [Bsp(3,:);Bsp(2,:);Bsp(1,:);Ba(3,:); Ba(2,:); Ba(1,:); Tr(3,:); Tr(2,:); Tr(1,:)];
fid = fopen(['C:\Users\flyn0011\OneDrive - University of Oklahoma\Lit\Pubs\AOS-related\Algo_Li\SGP_PSAP_algo_B_July2.csv'],'w')
fprintf(fid, '%s \n', 'bscat_red, bscat_green, bscat_blue, batn_red, batn_green, batn_blue, Tr_red, Tr_green, Tr_blue');
fprintf(fid,'%f, %f, %f, %f, %f, %f, %f, %f, %f \n',dout);
fclose(fid)
end