function eae = caps_neph


caps = anc_bundle_subsample([],60);
caps = anc_sift(caps,anc_qc_impacts(caps.vdata.qc_Bext_B, caps.vatts.qc_Bext_B)==0);
caps = anc_sift(caps,anc_qc_impacts(caps.vdata.qc_Bext_G, caps.vatts.qc_Bext_G)==0);
caps = anc_sift(caps,anc_qc_impacts(caps.vdata.qc_Bext_R, caps.vatts.qc_Bext_R)==0);
caps_1um = anc_sift(caps,caps.vdata.impactor_state==1);
Bext = [caps_1um.vdata.Bext_B; caps_1um.vdata.Bext_G; caps_1um.vdata.Bext_R ];
ewl = [450; 532; 632];

EAE_R = log(Bext(2,:)./Bext(3,:))-log(ewl(2)./ewl(3));
EAE_B = log(Bext(1,:)./Bext(2,:))-log(ewl(1)./ewl(2));


neph = anc_bundle_files;
neph = anc_sift(neph,anc_qc_impacts(neph.vdata.qc_Bs_B_Dry_Neph3W, neph.vatts.qc_Bs_B_Dry_Neph3W)==0);
neph = anc_sift(neph,anc_qc_impacts(neph.vdata.qc_Bs_G_Dry_Neph3W, neph.vatts.qc_Bs_G_Dry_Neph3W)==0);
neph = anc_sift(neph,anc_qc_impacts(neph.vdata.qc_Bs_R_Dry_Neph3W, neph.vatts.qc_Bs_R_Dry_Neph3W)==0);
neph_1um = anc_sift(neph,neph.vdata.impactor_state==1);
Bs = [neph_1um.vdata.Bs_B_Dry_Neph3W; neph_1um.vdata.Bs_G_Dry_Neph3W;neph_1um.vdata.Bs_R_Dry_Neph3W ];
swl = [450; 550; 700];

SAE_R = log(Bs(2,:)./Bs(3,:))-log(swl(2)./swl(3));
SAE_B = log(Bs(1,:)./Bs(2,:))-log(swl(1)./swl(2));

figure; 
ss(1) = subplot(2,1,1); plot(caps_1um.time, Bext,'x'); dynamicDateTicks; legend('Be_B','Be_G','Be_R');
ss(2) = subplot(2,1,2); plot(neph_1um.time, Bs,'o'); dynamicDateTicks; legend('Bs_B','Bs_G','Bs_R');
linkaxes(ss,'xy');

figure; 
sx(1) = subplot(2,1,1); plot(caps_1um.time, Bext,'x'); dynamicDateTicks; legend('Be_B','Be_G','Be_R');
sx(2) = subplot(2,1,2); plot(caps_1um.time, EAE_B,'x',caps_1um.time, EAE_R,'ro'); dynamicDateTicks; legend('EAE_B','EAE_R');
linkaxes(sx,'x');

figure; 
ns(1) = subplot(2,1,1); plot(neph_1um.time, Bs,'*'); dynamicDateTicks; legend('Bs_B','Bs_G','Bs_R');
ns(2) = subplot(2,1,2); plot(neph_1um.time, SAE_B,'x', neph_1um.time, SAE_R,'ro'); dynamicDateTicks; legend('SAE_B','SAE_R');
linkaxes(ns,'x');

ok = menu('Zoom into a desired time range, then hit OK when done','OK')
xl = xlim;
xl_ = neph_1um.time>xl(1) & neph_1um.time<xl(2);
xxl_ = caps_1um.time>xl(1) & caps_1um.time<xl(2);
swl = [450; 550; 700];
ewl = [450; 532; 632];
figure; plot(swl, [mean(Bs(1,xl_)), mean(Bs(2,xl_)), mean(Bs(3,xl_))],'o-',...
   ewl,[mean(Bext(1,xxl_)), mean(Bext(2,xxl_)), mean(Bext(3,xxl_))],'x-' ); logy; logx;
title('Angstrom Plot'); legend('Neph B_s','CAPS B_e_x_t')

figure; 
aa(1) = subplot(3,1,1);
plot(caps_1um.time, Bext(1,:),'x',neph_1um.time, Bs(1,:),'b.');
dynamicDateTicks; legend('Be_B 450nm','Bs_B 450nm');
aa(2) = subplot(3,1,2);
plot(caps_1um.time, Bext(2,:),'gx',neph_1um.time, Bs(2,:),'g.');
dynamicDateTicks; legend('Be_G 532nm','Bs_G 550nm');
aa(3) = subplot(3,1,3);
plot(caps_1um.time, Bext(3,:),'rx',neph_1um.time, Bs(3,:),'r.');
dynamicDateTicks; legend('Be_R 632nm','Bs_R 700nm');
linkaxes(aa,'xy');


return
