% Flow cals on Monday July 29, Logan and Connor with Gilibrator and Defender. 
% CLAP92
flowcal_path = getfilepath('AMICE_flowcals');

clap92.rawa = [1.34, 1.49; 1.21, 1.36; 1.104, 1.257; 1.01, 1.142; .91, 1.039; .789, .895; .68, .788]
clap92.puttya = clap92.rawa(:,1); 
clap92.gilia = clap92.rawa(:,2);
[clap92.Respa] = polyfit(clap92.gilia, clap92.puttya,2); clap92.target_1LPMa = polyval(clap92.Respa, 1);
[clap92.P_LPMa, clap92.Sa] = polyfit(clap92.puttya,clap92.gilia, 2); 
figure; plot(clap92.gilia, clap92.puttya, 'o', clap92.gilia, polyval(clap92.Respa, clap92.gilia),'--',1,  clap92.target_1LPMa ,'r*');
xlabel('Gili LPM'); ylabel('Putty LPM');sgtitle('CLAP 92 Flow Cals');
% Data from the above was inadvertently not logged by putty, so repeated cals below.
clap92.rawb = [1.34, 1.464; 1.205, 1.34; 1.107, 1.235; .999, 1.136; .895, 1.008; .804, .924; .7, .801]
clap92.puttyb = clap92.rawb(:,1); 
clap92.gilib = clap92.rawb(:,2);
[clap92.Respb] = polyfit(clap92.gilib, clap92.puttyb,2); clap92.target_1LPMb = polyval(clap92.Respb, 1);
[clap92.P_LPMb, clap92b.Sb] = polyfit(clap92.puttyb,clap92.gilib, 2);
clap92.target_1LPM = (clap92.target_1LPMa + clap92.target_1LPMb)./2;
clap92.P_LPM = mean([clap92.P_LPMa;clap92.P_LPMb]); 
save([flowcal_path,'clap93.mat'],'-struct','clap92');
figure; sgtitle('CLAP 92b Flow Cals'); plot(clap92b.gili, clap92b.putty, 'o', clap92b.gili, polyval(clap92b.Resp, clap92b.gili),'--',1,  clap92b.target_1LPM ,'r*');
xlabel('Gili LPM'); ylabel('Putty LPM')

tap12_1LPM.raw = [1.21,1.10,1,.9,.8,.7,1.3, ; 1.21, 1.105, 1.005, .9, .805, .7, 1.305; 1.283, 1.178, 1.084, .952, .851, .74, 1.394];
tap12_1LPM.screen = tap12_1LPM.raw(1,:);
tap12_1LPM.putty = tap12_1LPM.raw(2,:);
tap12_1LPM.gili = tap12_1LPM.raw(3,:);
figure; plot(tap12_1LPM.gili, tap12_1LPM.screen,'o', tap12_1LPM.gili, tap12_1LPM.putty,'x')
sgtitle('TAP12 1LPM target range'); 
[tap12_1LPM.Resp] = polyfit(tap12_1LPM.gili, tap12_1LPM.screen,2); tap12_1LPM.target_1LPM = polyval(tap12_1LPM.Resp, 1);
[tap12_1LPM.P_LPM, tap12_1LPM.S] = polyfit(tap12_1LPM.putty,tap12_1LPM.gili, 2);
save([flowcal_path,'tap12_1LPM.mat'],'-struct','tap12_1LPM');

tap12_2LPM.raw = [1.98,1.9,1.8,1.7,1.6,1.5;...
                  1.998,1.915,1.818, 1.713, 1.616, 1.505;...
                  2.156, 2.072, 1.931, 1.82, 1.699, 1.601;...
                  2.134, 2.054, 1.946, 1.834, 1.703, 1.609];
tap12_2LPM.screen = tap12_2LPM.raw(1,:);
tap12_2LPM.putty = tap12_2LPM.raw(2,:);
tap12_2LPM.gili = tap12_2LPM.raw(3,:);
tap12_2LPM.defender = tap12_2LPM.raw(4,:);
figure; plot(tap12_2LPM.gili, tap12_2LPM.screen,'o', tap12_2LPM.gili, tap12_2LPM.putty,'x')
figure; plot(tap12_2LPM.defender, tap12_2LPM.screen,'ro', tap12_2LPM.defender, tap12_2LPM.putty,'rx');

[tap12_2LPM.Resp] = polyfit(tap12_2LPM.gili, tap12_2LPM.screen,2); tap12_2LPM.target_2LPM = polyval(tap12_2LPM.Resp, 2);
% Shown to be identical to 4 digits
RespD = polyfit(tap12_2LPM.defender, tap12_2LPM.screen,2); def_target_2LPM = polyval(RespD, 2);
[tap12_2LPM.P_LPM, tap12_2LPM.S] = polyfit(tap12_2LPM.putty,tap12_2LPM.gili, 2);
save([flowcal_path,'tap12_2LPM.mat'],'-struct','tap12_2LPM');

tap13_1LPM.raw = [1.31, 1.35, 1.445;...
                  1.20, 1.234, 1.303; ...
                  1.09, 1.127, 1.190; ...
                  1.01, 1.036, 1.116; ...
                  0.89, .916, .978; ...
                  .79, .817, .874; ...
                  .69, .703, .749];

tap13_1LPM.screen = tap13_1LPM.raw(:,1);
tap13_1LPM.putty = tap13_1LPM.raw(:,2);
tap13_1LPM.gili = tap13_1LPM.raw(:,3);
 figure; plot(tap13_1LPM.gili, tap13_1LPM.screen,'o',tap13_1LPM.gili, tap13_1LPM.putty,'x')
[tap13_1LPM.Resp] = polyfit(tap13_1LPM.gili, tap13_1LPM.screen,2); tap13_1LPM.target_1LPM = polyval(tap13_1LPM.Resp, 1);
[tap13_1LPM.P_LPM, tap13_1LPM.S] = polyfit(tap13_1LPM.putty,tap13_1LPM.gili, 2);
save([flowcal_path,'tap13_1LPM.mat'],'-struct','tap13_1LPM');



clap10_1LPM.raw = [0.7, .701, .6179;...
                   0.8, .804, .7142;...
                   0.9, .908, .8096; ...
                   1.0, 1.00,  .8944;...
                   1.1  1.111, .9925;...
                   1.2  1.21,  1.078;...
                   1.3, 1.312,  1.169];
clap10_1LPM.screen =  clap10_1LPM.raw(:,1);
clap10_1LPM.putty = clap10_1LPM.raw(:,2);
clap10_1LPM.defender = clap10_1LPM.raw(:,3);
figure; plot(clap10_1LPM.defender, clap10_1LPM.screen,'o',clap10_1LPM.defender,clap10_1LPM.putty, 'x') 
[clap10_1LPM.Resp] = polyfit(clap10_1LPM.defender, clap10_1LPM.screen,2); clap10_1LPM.target_1LPM = polyval(clap10_1LPM.Resp, 1);
[clap10_1LPM.P_LPM, clap10_1LPM.S] = polyfit(clap10_1LPM.putty,clap10_1LPM.defender, 2);
save([flowcal_path,'clap10.mat'],'-struct','clap10_1LPM');


psap77.raw = [.7, .7, .7219;...
              .8, .8, .8363;...
              .9, .9, .9483;...
              1.0, 1.0, 1.061;...
              1.1, 1.1, 1.171;...
              1.2, 1.2, 1.281;...
              1.3, 1.3, 1.391];
psap77.screen = psap77.raw(:,1);
psap77.putty = psap77.raw(:,2);
psap77.defender = psap77.raw(:,3);
figure; plot(psap77.defender, psap77.screen, 'o',psap77.defender, psap77.putty, 'x');
[psap77.Resp] = polyfit(psap77.defender, psap77.screen,2); psap77.target_1LPM = polyval(psap77.Resp, 1);
[psap77.P_LPM, psap77.S] = polyfit(psap77.putty,psap77.defender, 2);
save([flowcal_path,'psap77.mat'],'-struct','psap77');

psap110.raw = [.7, .7, .8709;...
              .8, .8, .9856;...
              .9, .9, 1.105;...
              1.0, 1.0, 1.216;...
              1.1, 1.1, 1.327;...
              1.2, 1.2, 1.439;...
              1.3, 1.3, 1.551];
psap110.screen = psap110.raw(:,1);
psap110.putty = psap110.raw(:,2);
psap110.defender = psap110.raw(:,3);
figure; plot(psap110.defender, psap110.screen, 'o',psap110.defender, psap110.putty, 'x');
[psap110.Resp] = polyfit(psap110.defender, psap110.screen,2); psap110.target_1LPM = polyval(psap110.Resp, 1);
[psap110.P_LPM, psap110.S] = polyfit(psap110.putty,psap110.defender, 2);
save([flowcal_path,'psap110.mat'],'-struct','psap110');


psap123.raw = [.7, .7, .8183;...
              .8, .8, .9349;...
              .9, .9, 1.052;...
              1.0, 1.0, 1.170;...
              1.1, 1.1, 1.284;...
              1.2, 1.2, 1.398;...
              1.3, 1.3, 1.514];
psap123.screen = psap123.raw(:,1);
psap123.putty = psap123.raw(:,2);
psap123.defender = psap123.raw(:,3);
figure; plot(psap123.defender, psap123.screen, 'o',psap123.defender, psap123.putty, 'x');
[psap123.Resp] = polyfit(psap123.defender, psap123.screen,2); psap123.target_1LPM = polyval(psap123.Resp, 1);
[psap123.P_LPM, psap123.S] = polyfit(psap123.putty,psap123.defender, 2);
save([flowcal_path,'psap123.mat'],'-struct','psap123');

ae33.raw = [2 , 2.067;...
            3 ,  3.076;...
            4 , 4.006; ...
            5,  5.027];
ae33.set_pt = ae33.raw(:,1); 
ae33.defender = ae33.raw(:,2);
figure; plot(ae33.defender, ae33.set_pt,'o');
[ae33.P_LPM, ae33.S] = polyfit(ae33.set_pt,ae33.defender, 2);
save([flowcal_path,'ae33.mat'],'-struct','ae33');


ma92.raw = [170, .1812;...
            150, .1606;...
            125, .1343;...
            100, .1084];
ma92.screen = ma92.raw(:,1);
ma92.defender = ma92.raw(:,2);
figure; plot(ma92.defender, ma92.screen,'o');
[ma92.P_LPM, ma92.S] = polyfit(ma92.screen,ma92.defender, 2);
save([flowcal_path,'ma92.mat'],'-struct','ma92');

ma94.raw = [170, .1787;...
            150, .1581;...
            125, .1312;...
            100, .1059];
ma94.screen = ma94.raw(:,1);
ma94.defender = ma94.raw(:,2);
figure; plot(ma94.defender, ma94.screen,'o')
[ma94.P_LPM, ma94.S] = polyfit(ma94.screen,ma94.defender, 2);
save([flowcal_path,'ma94.mat'],'-struct','ma94');