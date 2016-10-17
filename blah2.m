function blah2
% psap
psap = anc_bundle_files(getfullname('sgpaosaoppsap*.nc','psap'));
pname = fileparts(psap.fname); out_pname = [pname, filesep,'..',filesep];
% ARM_display(psap);

psap_good = anc_sift(psap,psap.vdata.impactor_state==1 &...
    psap.vdata.qc_Ba_B_Bond==0 & psap.vdata.qc_Ba_G_Bond==0 &...
    psap.vdata.qc_Ba_R_Bond==0 & psap.vdata.Ba_B_Bond> -.2 & ...
    psap.vdata.Ba_G_Bond> -.2 & psap.vdata.Ba_R_Bond> -.2 & ...
    psap.vdata.Ba_B_Bond < 200 & psap.vdata.Ba_G_Bond< 200 & ...
    psap.vdata.Ba_R_Bond< 200);

done = false;
good_psap = true(size(psap_good.time));
good_ = good_psap;
figure; plot(serial2doys(psap_good.time(good_psap)), psap_good.vdata.Ba_G_Bond(good_psap), 'k.',...
    serial2doys(psap_good.time(good_)), psap_good.vdata.Ba_G_Bond(good_), 'g.'); zoom('on');

while ~done
ok = menu('Mark points as bad','Bad','RESET','Done')
v = axis;
if ok == 1
    v_ = serial2doys(psap_good.time)>v(1)&serial2doys(psap_good.time)<v(2)&psap_good.vdata.Ba_G_Bond>v(3)&psap_good.vdata.Ba_G_Bond<v(4);
    good_(v_) = false;
elseif ok ==2
    good_ = good_psap;
elseif ok==3
    done = true;
end
plot(serial2doys(psap_good.time(good_psap)), psap_good.vdata.Ba_G_Bond(good_psap), 'k.',...
    serial2doys(psap_good.time(good_)), psap_good.vdata.Ba_G_Bond(good_), 'g.'); zoom('on');
xlim([v(1),v(2)])
end
psap_good = anc_sift(psap_good,good_);
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

psap_good_.time = psap_good.time;
psap_good_.Ba_B_Bond = psap_good.vdata.Ba_B_Bond;
psap_good_.Ba_G_Bond = psap_good.vdata.Ba_G_Bond;
psap_good_.Ba_R_Bond = psap_good.vdata.Ba_R_Bond;



psap_dstr = [datestr(min(psap.time),'yyyymmdd'),'.',datestr(max(psap.time),'yyyymmdd')];
save([out_pname, 'psap_good.',psap_dstr,'.mat'],'-struct','psap_good_');
save([out_pname, 'psap_1hr.',psap_dstr,'.mat'],'-struct','psap_1hr_out');
% actually clap

clap = anc_bundle_files(getfullname('sgpaosaopclap*.nc','clap'));

% ARM_display(clap);

clap_good = anc_sift(clap,clap.vdata.impactor_state==1 &...
    clap.vdata.qc_Ba_B_Bond==0 & clap.vdata.qc_Ba_G_Bond==0 &...
    clap.vdata.qc_Ba_R_Bond==0 & clap.vdata.Ba_B_Bond> -.2 & ...
    clap.vdata.Ba_G_Bond> -.2 & clap.vdata.Ba_R_Bond> -.2 & ...
    clap.vdata.Ba_B_Bond < 200 & clap.vdata.Ba_G_Bond< 200 & ...
    clap.vdata.Ba_R_Bond< 200);

done = false;
good_clap = true(size(clap_good.time));
good_ = good_clap;
figure; plot(serial2doys(clap_good.time(good_clap)), clap_good.vdata.Ba_G_Bond(good_clap), 'k.',...
    serial2doys(clap_good.time(good_)), clap_good.vdata.Ba_G_Bond(good_), 'g.'); zoom('on');

while ~done
ok = menu('Mark points as bad','Bad','RESET','Done')
v = axis;
if ok == 1
    v_ = serial2doys(clap_good.time)>v(1)&serial2doys(clap_good.time)<v(2)&clap_good.vdata.Ba_G_Bond>v(3)&clap_good.vdata.Ba_G_Bond<v(4);
    good_(v_) = false;
elseif ok ==2
    good_ = good_clap;
elseif ok==3
    done = true;
end
plot(serial2doys(clap_good.time(good_clap)), clap_good.vdata.Ba_G_Bond(good_clap), 'k.',...
    serial2doys(clap_good.time(good_)), clap_good.vdata.Ba_G_Bond(good_), 'g.'); zoom('on');
xlim([v(1),v(2)])
end
clap_good = anc_sift(clap_good,good_);


% ARM_display(clap_good);
Start_date = floor(min(clap_good.time)); End_date = ceil(max(clap_good.time));
hours = [Start_date: 1./24 : End_date];
for hh = (length(hours)-1):-1:1   
    dt = clap_good.time-(hours(hh)+0.25/24);
    dt_ = abs(dt)<(0.5./24);
    datestr((hours(hh)+0.25/24))
     disp([hh,sum(dt_)])
    if sum(dt_)>5
        clap_1hr_out.time(hh) = mean(clap_good.time(dt_));
        clap_1hr_out.Ba_B_psap(hh) = mean(clap_good.vdata.Ba_B_Bond(dt_));
        clap_1hr_out.Ba_G_psap(hh) = mean(clap_good.vdata.Ba_G_Bond(dt_));
        clap_1hr_out.Ba_R_psap(hh) = mean(clap_good.vdata.Ba_R_Bond(dt_));
    else
        clap_1hr_out.time(hh) = hours(hh)+.25/24;
        clap_1hr_out.Ba_B_psap(hh) = NaN;
        clap_1hr_out.Ba_G_psap(hh) = NaN;
        clap_1hr_out.Ba_R_psap(hh) = NaN;        
    end
end
clap_dstr = [datestr(min(clap.time),'yyyymmdd'),'.',datestr(max(clap.time),'yyyymmdd')];

clap_good_.time = clap_good.time;
clap_good_.Ba_B_Bond = clap_good.vdata.Ba_B_Bond;
clap_good_.Ba_G_Bond = clap_good.vdata.Ba_G_Bond;
clap_good_.Ba_R_Bond = clap_good.vdata.Ba_R_Bond;

save([out_pname, 'clap_good.',clap_dstr,'.mat'],'-struct','clap_good_');
save([out_pname, 'clap_1hr.',clap_dstr,'.mat'],'-struct','clap_1hr_out');



[ainb, bina] = nearest(psap_good.time, clap_good.time);

psap_both = anc_sift(psap_good,ainb);
clap_both = anc_sift(clap_good, bina);
figure; plot(psap_both.time, psap_both.vdata.Ba_B_Bond, 'o',clap_both.time, clap_both.vdata.Ba_B_Bond, 'x')


done = false;
good_both = true(size(psap_both.time));
good_ = good_both;

figure; 
plot(psap_both.vdata.Ba_B_Bond(good_both),clap_both.vdata.Ba_B_Bond(good_both), 'kx',...
    psap_both.vdata.Ba_B_Bond(good_),clap_both.vdata.Ba_B_Bond(good_), 'go'); 
xlabel('PSAP Ba_B'); ylabel('CLAP Ba_B');

while ~done
ok = menu('Mark points as bad','Bad','RESET','Done')
v = axis;
if ok == 1
    v_ = psap_both.vdata.Ba_B_Bond>v(1)&psap_both.vdata.Ba_B_Bond<v(2)&...
        clap_both.vdata.Ba_B_Bond>v(3)&clap_both.vdata.Ba_B_Bond<v(4);
    good_(v_) = false;
elseif ok ==2
    good_ = good_clap;
elseif ok==3
    done = true;
end
plot(psap_both.vdata.Ba_B_Bond(good_both),clap_both.vdata.Ba_B_Bond(good_both), 'kx',...
    psap_both.vdata.Ba_B_Bond(good_),clap_both.vdata.Ba_B_Bond(good_), 'go'); 
xlabel('PSAP Ba_B'); ylabel('CLAP Ba_B');xlim([v(1),v(2)])
end

clap_both = anc_sift(clap_both,good_);
psap_both = anc_sift(psap_both,good_);

% v = axis; v_ = psap_both.vdata.Ba_B_Bond>v(1) & psap_both.vdata.Ba_B_Bond<v(2)&clap_both.vdata.Ba_B_Bond>v(3)&clap_both.vdata.Ba_B_Bond<v(4);

% figure; plot(psap_both.vdata.Ba_G_Bond(v_),clap_both.vdata.Ba_G_Bond(v_), 'k.'); xlabel('PSAP Ba_G'); ylabel('CLAP Ba_G');

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
        out_1hr.Ba_B_clap(hh) = mean(clap_both.vdata.Ba_B_Bond(dt_));
        out_1hr.Ba_G_psap(hh) = mean(psap_both.vdata.Ba_G_Bond(dt_));
        out_1hr.Ba_G_clap(hh) = mean(clap_both.vdata.Ba_G_Bond(dt_));
        out_1hr.Ba_R_psap(hh) = mean(psap_both.vdata.Ba_R_Bond(dt_));
        out_1hr.Ba_R_clap(hh) = mean(clap_both.vdata.Ba_R_Bond(dt_));
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
notNaN = ~isNaN(out_1hr.Ba_B_psap)&~isNaN(out_1hr.Ba_B_clap);
[P] = polyfit(out_1hr.Ba_B_psap(notNaN), out_1hr.Ba_B_clap(notNaN),1);
[P_] = polyfit(out_1hr.Ba_B_clap(notNaN), out_1hr.Ba_B_psap(notNaN),1);
P_new = [mean([P(1),1./P_(1)]),P(2)];
figure; plot(out_1hr.Ba_B_psap, out_1hr.Ba_B_clap, 'k.',...
[0,max(out_1hr.Ba_B_psap)], polyval(P_new,[0,max(out_1hr.Ba_B_psap)]),'r-'); xlabel('PSAP Ba_G'); ylabel('CLAP Ba_G');

both_dstr = [datestr(min([clap.time(1),psap.time(1)]),'yyyymmdd'),'.',datestr(max([clap.time(end),psap.time(end)]),'yyyymmdd')];

save([out_pname, 'both_1hr.',both_dstr,'.mat'],'-struct','out_1hr');
return