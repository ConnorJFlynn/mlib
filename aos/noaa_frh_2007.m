%test frh xls
[numer, labels]  = xlsread('C:\case_studies\aip\fitrh\fgH07.xls','trimmed','a1:o11424');
%%
for f = length(labels):-1:1
   lab_str = deblank(char(labels{f}));
   lab_str(real(lab_str)==real(' ')) = ['_'];
   frh.(lab_str) = numer(:,f);
end
%3P form a(1+b[(rh/100)^c]);
frh.P3_85 = frh.P3_a.*(1+frh.P3_b.*((85./100).^frh.P3_c));
frh.P3_40 = frh.P3_a.*(1+frh.P3_b.*((40./100).^frh.P3_c));
frh.P3_ratio = frh.P3_85./frh.P3_40;
frh.P3_eff_dry = 100.*((1-frh.P3_a)./(frh.P3_a.*frh.P3_b)).^(1./frh.P3_c);
frh.P3_test_1 = (frh.P3_eff_dry<0) | (frh.P3_eff_dry>100)|(frh.P3_eff_dry~=real(frh.P3_eff_dry));
frh.P3_test_2 = ((1-frh.P3_a)./(frh.P3_a.*frh.P3_b))<0;
frh.P3_test_2a = frh.P3_test_2 & frh.P3_a>1;
frh.P3_test_2b = frh.P3_test_2 & frh.P3_b>0;

% 2P form a(1-rh/100)^-b
frh.P2_85 = frh.P2_A.*((1-.85).^(-1.*frh.P2_B));
frh.P2_40 = frh.P2_A.*((1-.4).^(-1.*frh.P2_B));
frh.P2_ratio = frh.P2_85./frh.P2_40;
frh.P2_eff_dry = 100.*(1 - frh.P2_A.^(1./frh.P2_B)); 
frh.P2_test_1 = (frh.P2_eff_dry<0) | (frh.P2_eff_dry>100)|(frh.P2_eff_dry~=real(frh.P2_eff_dry));
frh.P2_test_2 = frh.P2_A <0;
%%

figure; ax(1) = subplot(2,1,1); plot(frh.time, frh.P3_ratio, 'k.', frh.time(frh.P3_test_1), frh.P3_ratio(frh.P3_test_1), 'r.')
ax(2) = subplot(2,1,2); plot(frh.time, frh.P2_ratio, 'b.',frh.time(frh.P2_eff_dry<0), frh.P2_ratio((frh.P2_eff_dry<0)), 'r.');
linkaxes(ax,'xy'); zoom('on')
%%

figure; ax(1) = subplot(2,1,1); plot(frh.time, frh.P3_eff_dry, 'k.', frh.time(frh.P3_test_1), frh.P3_eff_dry(frh.P3_test_1), 'r.')
ax(2) = subplot(2,1,2); plot(frh.time, frh.P2_eff_dry, 'b.',frh.time(frh.P2_eff_dry<0), frh.P2_eff_dry((frh.P2_eff_dry<0)), 'r.');
linkaxes(ax,'xy'); zoom('on')
