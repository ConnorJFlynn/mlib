gv = [1:65];
gv2= [50:55];
do_plot(1:6) = false;
do_plot(6) = true;
do_plot(7) = false;do_plot(~do_plot) = true;
ACCP_SITA_Sept_pngs_ppts_v25(gv, gv2, do_plot);