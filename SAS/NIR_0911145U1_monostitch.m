% Stitch two monochromator scans together for NIR spectrometer 0911145U1
clear
pname_1 = ['C:\case_studies\sas\testing_and_characterization\monoscans\0911145U1_NIR\0911145U1_SingleMono_1100LP_selected\'];
in_spec1 = load([pname_1, '0911145U1_SingleMono_1100LP_selected.mat']);
pname_2 = ['C:\case_studies\sas\testing_and_characterization\monoscans\post_second_repair\20100825_45U1_NIR_post2ndRepair_2xInt\'];
in_spec2 = load([pname_2, '0911145U1_mono.mat']);

scan_wl = [in_spec2.scan_nm(in_spec2.scan_nm<1450)',in_spec1.scan_nm(1:end-5)]';
norm = [in_spec2.norm(in_spec2.scan_nm<1450,:)',in_spec1.normB(:,6:end)]';
figure_(777)
imagegap(in_spec2.nm, scan_wl, real(log10(norm)));
axis('xy'); caxis([-3.7,0]); cb=colorbar;
axis([950,1650, 950,1650]); axis('square')
cb_title = get(cb,'title');
set(cb_title,'string','log_1_0(signal)');
title({[in_spec2.sn, ': max signal normalized to unity']}, 'interp','none');
ylabel('scan nm (de-gapped)')
xlabel('pixel wavelength [nm]')
saveas(gcf,[getnamedpath('EK_figs'),'NIR_spec_monoscan.fig']);
saveas(gcf,[getnamedpath('EK_figs'),'NIR_spec_monoscan.png']);