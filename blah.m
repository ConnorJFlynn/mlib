function blah
% psap
psap = anc_bundle_files;
pname = fileparts(psap.fname); out_pname = [pname, filesep,'..',filesep];
% ARM_display(psap);

psap_good = anc_sift(psap,psap.vdata.impactor_state==1 &...
    psap.vdata.qc_Ba_B_Bond==0 & psap.vdata.qc_Ba_G_Bond==0 &...
    psap.vdata.qc_Ba_R_Bond==0 & psap.vdata.Ba_B_Bond> -.2 & ...
    psap.vdata.Ba_G_Bond> -.2 & psap.vdata.Ba_R_Bond> -.2 & ...
    psap.vdata.Ba_B_Bond < 200 & psap.vdata.Ba_G_Bond< 200 & ...
    psap.vdata.Ba_R_Bond< 200);

% ARM_display(psap_good);
Start_date = floor(min(psap_good.time)); End_date = ceil(max(psap_good.time));
hours = [Start_date: 1./24 : End_date];
for hh = (length(hours)-1):-1:1   
    dt = psap_good.time-(hours(hh)+0.25/24);
    dt_ = abs(dt)<(0.5./24);
    datestr((hours(hh)+0.25/24))
     disp([hh,sum(dt_)])
    if sum(dt_)>5
        psap_1hr_out.time(hh) = mean(psap_good.time(dt_));
        psap_1hr_out.Ba_B_psap(hh) = mean(psap_good.vdata.Ba_B_Bond(dt_));
        psap_1hr_out.Ba_G_psap(hh) = mean(psap_good.vdata.Ba_G_Bond(dt_));
        psap_1hr_out.Ba_R_psap(hh) = mean(psap_good.vdata.Ba_R_Bond(dt_));
    else
        psap_1hr_out.time(hh) = hours(hh)+.25/24;
        psap_1hr_out.Ba_B_psap(hh) = NaN;
        psap_1hr_out.Ba_G_psap(hh) = NaN;
        psap_1hr_out.Ba_R_psap(hh) = NaN;        
    end
end
save([out_pname, 'psap_good.mat'],'-struct','psap_good');
save([out_pname, 'psap_1hr.mat'],'-struct','psap_1hr_out');
% actually clap

psap2 = anc_bundle_files;

% ARM_display(psap2);

psap2_good = anc_sift(psap2,psap2.vdata.impactor_state==1 &...
    psap2.vdata.qc_Ba_B_Bond==0 & psap2.vdata.qc_Ba_G_Bond==0 &...
    psap2.vdata.qc_Ba_R_Bond==0 & psap2.vdata.Ba_B_Bond> -.2 & ...
    psap2.vdata.Ba_G_Bond> -.2 & psap2.vdata.Ba_R_Bond> -.2 & ...
    psap2.vdata.Ba_B_Bond < 200 & psap2.vdata.Ba_G_Bond< 200 & ...
    psap2.vdata.Ba_R_Bond< 200);

% ARM_display(psap2_good);
Start_date = floor(min(psap2_good.time)); End_date = ceil(max(psap2_good.time));
hours = [Start_date: 1./24 : End_date];
for hh = (length(hours)-1):-1:1   
    dt = psap2_good.time-(hours(hh)+0.25/24);
    dt_ = abs(dt)<(0.5./24);
    datestr((hours(hh)+0.25/24))
     disp([hh,sum(dt_)])
    if sum(dt_)>5
        clap_1hr_out.time(hh) = mean(psap2_good.time(dt_));
        clap_1hr_out.Ba_B_psap(hh) = mean(psap2_good.vdata.Ba_B_Bond(dt_));
        clap_1hr_out.Ba_G_psap(hh) = mean(psap2_good.vdata.Ba_G_Bond(dt_));
        clap_1hr_out.Ba_R_psap(hh) = mean(psap2_good.vdata.Ba_R_Bond(dt_));
    else
        clap_1hr_out.time(hh) = hours(hh)+.25/24;
        clap_1hr_out.Ba_B_psap(hh) = NaN;
        clap_1hr_out.Ba_G_psap(hh) = NaN;
        clap_1hr_out.Ba_R_psap(hh) = NaN;        
    end
end
save([out_pname, 'clap_good.mat'],'-struct','psap2_good');
save([out_pname, 'clap_1hr.mat'],'-struct','clap_1hr_out');



[ainb, bina] = nearest(psap_good.time, psap2_good.time);

psap_both = anc_sift(psap_good,ainb);
psap2_both = anc_sift(psap2_good, bina);
figure; plot(psap_both.time, psap_both.vdata.Ba_B_Bond, 'o',psap2_both.time, psap2_both.vdata.Ba_B_Bond, 'x')
figure; plot(psap_both.vdata.Ba_B_Bond,psap2_both.vdata.Ba_B_Bond, 'o'); xlabel('PSAP Ba_B'); ylabel('CLAP Ba_B');
% v = axis; v_ = psap_both.vdata.Ba_B_Bond>v(1) & psap_both.vdata.Ba_B_Bond<v(2)&psap2_both.vdata.Ba_B_Bond>v(3)&psap2_both.vdata.Ba_B_Bond<v(4);

% figure; plot(psap_both.vdata.Ba_G_Bond(v_),psap2_both.vdata.Ba_G_Bond(v_), 'k.'); xlabel('PSAP Ba_G'); ylabel('CLAP Ba_G');

Start_date = floor(min(psap_both.time)); End_date = ceil(max(psap_both.time));
hours = [Start_date: 1./24 : End_date];
for hh = (length(hours)-1):-1:1
   
    dt = psap_both.time-(hours(hh)+0.25/24);
    dt_ = abs(dt)<(0.5./24);
    datestr((hours(hh)+0.25/24))
     disp([hh,sum(dt_)])
    if sum(dt_)>5
        out_1hr.time(hh) = mean(psap_both.time(dt_));
        out_1hr.Ba_B_psap(hh) = mean(psap_both.vdata.Ba_B_Bond(dt_));
        out_1hr.Ba_B_clap(hh) = mean(psap2_both.vdata.Ba_B_Bond(dt_));
        out_1hr.Ba_G_psap(hh) = mean(psap_both.vdata.Ba_G_Bond(dt_));
        out_1hr.Ba_G_clap(hh) = mean(psap2_both.vdata.Ba_G_Bond(dt_));
        out_1hr.Ba_R_psap(hh) = mean(psap_both.vdata.Ba_R_Bond(dt_));
        out_1hr.Ba_R_clap(hh) = mean(psap2_both.vdata.Ba_R_Bond(dt_));
    else
        out_1hr.time(hh) = hours(hh)+.25/24;
        out_1hr.Ba_B_psap(hh) = NaN;
        out_1hr.Ba_B_clap(hh) = NaN;
        out_1hr.Ba_G_psap(hh) = NaN;
        out_1hr.Ba_G_clap(hh) = NaN;
        out_1hr.Ba_R_psap(hh) = NaN;
        out_1hr.Ba_R_clap(hh) = NaN;
    end
end
save([out_pname, 'both_1hr.mat'],'-struct','out_1hr');
return