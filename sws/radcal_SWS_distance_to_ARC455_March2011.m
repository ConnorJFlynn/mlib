
%% Checking SWS response as function of distance from sphere
% Contents of this file are abridged from ARC_2011_03.m
%% First at 20" distance
ames_path = 'C:\case_studies\SWS\calibration\NASA_ARC_2011_03_07\March7_Monday\ARC455\back_reflection_tests\D_20\';
fname = ['sgpswscf.00.20110307.171438.raw.dat'];
in_file = [ames_path, fname];
% in_file = getfullname([ames_path,'*.dat'],'sws_cals');

figure;
A455_D20 = read_sws_raw(in_file);
%%
figure; lines = plot(A455_D20.Si_lambda, A455_D20.Si_spec(:,21:80)./(A455_D20.mean_Si_sig*A455_D20.Si_ms(21:80))-1,'-');
lines = recolor(lines, [21:80]); colorbar
%
hold('on');
lines2 = semilogy(A455_D20.In_lambda, A455_D20.In_spec(:,21:80)./(A455_D20.mean_In_sig*A455_D20.In_ms(21:80))-1,'-');
lines2 = recolor(lines2,[21:80]); 
hold('off');
% A455_D20.mean_Si_sig = mean(A455_D20.Si_spec(:,21:80),2)./mean(A455_D20.Si_ms(21:80));
% A455_D20.mean_In_sig = mean(A455_D20.In_spec(:,21:80),2)./mean(A455_D20.In_ms(21:80));
A455_D20.mean_Si_sig = A455_D20.mean_Si_sig./mean(A455_D20.Si_ms);
A455_D20.mean_In_sig = A455_D20.mean_In_sig./mean(A455_D20.In_ms);

%% Now for 15" distance
ames_path = 'C:\case_studies\SWS\calibration\NASA_ARC_2011_03_07\March7_Monday\ARC455\back_reflection_tests\D_15\';
% fname = ['sgpswscf.00.20110307.171618.raw.dat'];
% in_file = [ames_path, fname];
in_file = getfullname([ames_path,'*.dat'],'sws_cals');

figure;
A455_D15_a = read_sws_raw(in_file);
in_file = getfullname([ames_path,'*.dat'],'sws_cals');
% fname = ['sgpswscf.00.20110307.171758.raw.dat'];
A455_D15_b = read_sws_raw(in_file);
%%

A455_D15 = cat_sws_raw(A455_D15_a, A455_D15_b);
fld = fieldnames(A455_D15);
for f = 1:length(fld)
   if size(A455_D15.(fld{f}),2)==200
      if size(A455_D15.(fld{f}),1)==1
         A455_D15.(fld{f}) = A455_D15.(fld{f})(52:128);
      else
                  A455_D15.(fld{f}) = A455_D15.(fld{f})(:,52:128);
      end
   end
end
A455_D15.Si_dark = mean(A455_D15.Si_DN(:,A455_D15.shutter==1),2);
A455_D15.In_dark = mean(A455_D15.In_DN(:,A455_D15.shutter==1),2);
A455_D15.Si_spec = A455_D15.Si_DN - A455_D15.Si_dark*ones(size(A455_D15.time));
A455_D15.In_spec = A455_D15.In_DN - A455_D15.In_dark*ones(size(A455_D15.time));
A455_D15.Si_spec = A455_D15.Si_spec./(ones(size(A455_D15.Si_lambda))*A455_D15.Si_ms);
A455_D15.In_spec = A455_D15.In_spec./(ones(size(A455_D15.In_lambda))*A455_D15.In_ms);
%%
figure; plot([1:length(A455_D15.time)], max(A455_D15.Si_DN,[],1),'-o')
% A455_D15.time = A455_D15.time(52:128);

%%
figure; lines = plot(A455_D15.Si_lambda, A455_D15.Si_spec(:,10:69)./(A455_D15.mean_Si_sig*A455_D15.Si_ms(10:69))-1,'-');
lines = recolor(lines, [10:69]); colorbar
%
hold('on');
lines2 = plot(A455_D15.In_lambda, A455_D15.In_spec(:,10:69)./(A455_D15.mean_In_sig*A455_D15.In_ms(10:69))-1,'-');
lines2 = recolor(lines2,[10:69]); 
hold('off');
A455_D15.mean_Si_sig = mean(A455_D15.Si_spec(:,10:69),2)./mean(A455_D15.Si_ms(10:69));
A455_D15.mean_In_sig = mean(A455_D15.In_spec(:,10:69),2)./mean(A455_D15.In_ms(10:69));

%% Now for 7.5" distance
ames_path = 'C:\case_studies\SWS\calibration\NASA_ARC_2011_03_07\March7_Monday\ARC455\back_reflection_tests\D_7p5\';
% fname = ['sgpswscf.00.20110307.171618.raw.dat'];
% in_file = [ames_path, fname];
in_file = getfullname([ames_path,'*.dat'],'sws_cals');
%%
figure;
A455_D7p5 = read_sws_raw(in_file);
%%
figure; plot([1:length(A455_D7p5.time)], max(A455_D7p5.Si_DN,[],1),'-o')
%%
% A4557p5.time = A4557p5.time(52:128);
fld = fieldnames(A455_D7p5);
for f = 1:length(fld)
   if size(A455_D7p5.(fld{f}),2)==100
      if size(A455_D7p5.(fld{f}),1)==1
         A455_D7p5.(fld{f}) = A455_D7p5.(fld{f})(20:end);
      else
                  A455_D7p5.(fld{f}) = A455_D7p5.(fld{f})(:,20:end);
      end
   end
end
A455_D7p5.Si_dark = mean(A455_D7p5.Si_DN(:,A455_D7p5.shutter==1),2);
A455_D7p5.In_dark = mean(A455_D7p5.In_DN(:,A455_D7p5.shutter==1),2);
A455_D7p5.Si_spec = A455_D7p5.Si_DN - A455_D7p5.Si_dark*ones(size(A455_D7p5.time));
A455_D7p5.In_spec = A455_D7p5.In_DN - A455_D7p5.In_dark*ones(size(A455_D7p5.time));
A455_D7p5.Si_spec = A455_D7p5.Si_spec./(ones(size(A455_D7p5.Si_lambda))*A455_D7p5.Si_ms);
A455_D7p5.In_spec = A455_D7p5.In_spec./(ones(size(A455_D7p5.In_lambda))*A455_D7p5.In_ms);

%%
figure; lines = plot(A455_D7p5.Si_lambda, A455_D7p5.Si_spec(:,A455_D7p5.shutter==0)./(A455_D7p5.mean_Si_sig*A455_D7p5.Si_ms(A455_D7p5.shutter==0))-1,'-');
lines = recolor(lines, [1:sum(A455_D7p5.shutter==0)]); colorbar
%
hold('on');
lines2 = plot(A455_D7p5.In_lambda, A455_D7p5.In_spec(:,A455_D7p5.shutter==0)./(A455_D7p5.mean_In_sig*A455_D7p5.In_ms(A455_D7p5.shutter==0))-1,'-');
lines2 = recolor(lines2,[1:sum(A455_D7p5.shutter==0)]);
hold('off');
A455_D7p5.mean_Si_sig = mean(A455_D7p5.Si_spec(:,A455_D7p5.shutter==0),2)./mean(A455_D7p5.Si_ms(A455_D7p5.shutter==0));
A455_D7p5.mean_In_sig = mean(A455_D7p5.In_spec(:,A455_D7p5.shutter==0),2)./mean(A455_D7p5.In_ms(A455_D7p5.shutter==0));

%% Now for 4" distance
ames_path = 'C:\case_studies\SWS\calibration\NASA_ARC_2011_03_07\March7_Monday\ARC455\back_reflection_tests\D_4\';
% fname = ['sgpswscf.00.20110307.171618.raw.dat'];
% in_file = [ames_path, fname];
in_file = getfullname([ames_path,'*.dat'],'sws_cals');
%%
figure;
A455_D4 = read_sws_raw(in_file);
%%
figure; plot([1:length(A455_D4.time)], max(A455_D4.Si_DN,[],1),'-o')
%%
fld = fieldnames(A455_D4);
for f = 1:length(fld)
   if size(A455_D4.(fld{f}),2)==100
      if size(A455_D4.(fld{f}),1)==1
         A455_D4.(fld{f}) = A455_D4.(fld{f})(1:60);
      else
                  A455_D4.(fld{f}) = A455_D4.(fld{f})(:,1:60);
      end
   end
end
A455_D4.Si_dark = mean(A455_D4.Si_DN(:,A455_D4.shutter==1),2);
A455_D4.In_dark = mean(A455_D4.In_DN(:,A455_D4.shutter==1),2);
A455_D4.Si_spec = A455_D4.Si_DN - A455_D4.Si_dark*ones(size(A455_D4.time));
A455_D4.In_spec = A455_D4.In_DN - A455_D4.In_dark*ones(size(A455_D4.time));
A455_D4.Si_spec = A455_D4.Si_spec./(ones(size(A455_D4.Si_lambda))*A455_D4.Si_ms);
A455_D4.In_spec = A455_D4.In_spec./(ones(size(A455_D4.In_lambda))*A455_D4.In_ms);

%%
figure; lines = plot(A455_D4.Si_lambda, A455_D4.Si_spec(:,A455_D4.shutter==0)./(A455_D4.mean_Si_sig*A455_D4.Si_ms(A455_D4.shutter==0))-1,'-');
lines = recolor(lines, [1:sum(A455_D4.shutter==0)]); colorbar
%
hold('on');
lines2 = plot(A455_D4.In_lambda, A455_D4.In_spec(:,A455_D4.shutter==0)./(A455_D4.mean_In_sig*A455_D4.In_ms(A455_D4.shutter==0))-1,'-');
lines2 = recolor(lines2,[1:sum(A455_D4.shutter==0)]);
hold('off');
A455_D4.mean_Si_sig = mean(A455_D4.Si_spec(:,A455_D4.shutter==0),2)./mean(A455_D4.Si_ms(A455_D4.shutter==0));
A455_D4.mean_In_sig = mean(A455_D4.In_spec(:,A455_D4.shutter==0),2)./mean(A455_D4.In_ms(A455_D4.shutter==0));

%%
% This figure shows a disturbing dependence on distance throughout with over a 10% change.  
% This is bad news actually as it makes it diffult to separate FOV from
% back-reflection
figure; plot(A455_D20.Si_lambda, [A455_D20.mean_Si_sig,A455_D15.mean_Si_sig,A455_D7p5.mean_Si_sig,A455_D4.mean_Si_sig], '-')
legend('20','15','7p5','4') 

%% But moving on to look at values with the ARC 455 and 5 different
%% apertures at 6" distance from sphere.  
ames_path = 'C:\case_studies\SWS\calibration\NASA_ARC_2011_03_07\March7_Monday\ARC455\back_reflection_tests\D_7p5\';
% fname = ['sgpswscf.00.20110307.171618.raw.dat'];
% in_file = [ames_path, fname];
in_file = getfullname([ames_path,'*.dat'],'sws_cals');
%%
figure;
A455_D7p5 = read_sws_raw(in_file);
%%
figure; plot([1:length(A455_D7p5.time)], max(A455_D7p5.Si_DN,[],1),'-o');

