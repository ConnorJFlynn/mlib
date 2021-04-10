function [psapo] = parse_psapi_hex(psapi);

% The following statements are just pre-declaring variables...

tmp = NaN(size(psapi.time));
current_boxcar_index = tmp; boxcar_flow = tmp; boxcar_secs = tmp; 
dark_sig = tmp;dark_ref = tmp;
adc_gain = tmp;N_boxcars = tmp;over_ranges = tmp;
blue_sig_boxcar = tmp;blue_sig = tmp;blue_ref_boxcar = tmp;blue_ref = tmp;
green_sig_boxcar = tmp;green_sig = tmp;green_ref_boxcar = tmp;green_ref = tmp;
red_sig_boxcar = tmp;red_sig = tmp;red_ref_boxcar = tmp;red_ref = tmp;
reset_last = tmp;
reset_2nd = reset_last;
blue_sig_ref_ratio = tmp;
green_sig_ref_ratio = tmp;
red_sig_ref_ratio = tmp;

% Previous filter reset times...
mod0 = find(mod(psapi.SS,4)==0&psapi.SS~=0);
for m = 1:length(mod0)
   %       disp(m)
   ender = psapi.ender{mod0(m)};
   %  'fa,00572bea,0bfa,fffffa,ffffff,02'
   B = textscan(ender,'%s %s %s %s %s %s %[^\n]','delimiter',',');
   current_boxcar_index(mod0(m)) = hex2nm(B{1});
   boxcar_flow(mod0(m))= hex2nm(B{2}); boxcar_secs(mod0(m))= hex2nm(B{3});
   dark_sig(mod0(m))= hex2nm(B{4}); dark_ref(mod0(m))= hex2nm(B{5}); adc_gain(mod0(m))= hex2nm(B{6});
   if psapi.SS(mod0(m))==4
      try
         reset_last(mod0(m)) = datenum(B{7},'yymmddHHMMSS');
      catch
         reset_last(mod0(m)) = NaN;
      end
   elseif psapi.SS(mod0(m))==8
      try
         reset_2nd(mod0(m)) = datenum(B{7},'yymmddHHMMSS');
      catch
         reset_2nd(mod0(m)) = NaN;
      end
   elseif psapi.SS(mod0(m))==12
      try
         reset_3rd(mod0(m)) = datenum(B{7},'yymmddHHMMSS');
      catch
         reset_3rd(mod0(m)) = NaN;
      end
   end
end

% Blue signals...
mod1 =  find(mod(psapi.SS,4)==1);
for m = 1:length(mod1)
   ender = psapi.ender{mod1(m)};
   %  'fa,00572bea,0bfa,fffffa,ffffff,02'
   B = textscan(ender,'%s %s %s %s %[^\n]','delimiter',',');
   blue_sig_boxcar(mod1(m)) = hex2nm(B{1});blue_ref_boxcar(mod1(m)) = hex2nm(B{2});
   N_boxcars(mod1(m))= hex2nm(B{3}); over_ranges(mod1(m))= hex2nm(B{4});
   if psapi.SS(mod1(m))==5
      sr = B{5};
      blue_sig_ref_ratio(mod1(m)) = sscanf(sr{1},'%f');
   end
end
% Compute signal at full precision from hex strings
blue_sig(mod1(2:end)) = blue_sig_boxcar(mod1(2:end))-blue_sig_boxcar(mod1(1:end-1)) - 256.*(N_boxcars(mod1(2:end))-N_boxcars(mod1(1:end-1)));
blue_ref(mod1(2:end)) = blue_ref_boxcar(mod1(2:end))-blue_ref_boxcar(mod1(1:end-1)) - 256.*(N_boxcars(mod1(2:end))-N_boxcars(mod1(1:end-1)));
roll = false(size(N_boxcars));
roll(mod1(2:end)) = (N_boxcars(mod1(2:end))-N_boxcars(mod1(1:end-1)))<0;
blue_sig(roll) = blue_sig(roll) - 2.^32;
blue_ref(roll) = blue_ref(roll) - 2.^32;

% Green signals...
mod2 =  find(mod(psapi.SS,4)==2);
for m = 1:length(mod2)
   ender = psapi.ender{mod2(m)};
   %  'fa,00572bea,0bfa,fffffa,ffffff,02'
   B = textscan(ender,'%s %s %s %s %[^\n]','delimiter',',');
   green_sig_boxcar(mod2(m)) =  hex2nm(B{1});green_ref_boxcar(mod2(m)) =  hex2nm(B{2});
   N_boxcars(mod2(m))= hex2nm(B{3}); over_ranges(mod2(m))= hex2nm(B{4});
   if psapi.SS(mod2(m))==6
      sr = B{5};
      green_sig_ref_ratio(mod2(m)) = sscanf(sr{1},'%f');
   end
end
roll = false(size(N_boxcars));
roll(mod2(2:end)) = (N_boxcars(mod2(2:end))-N_boxcars(mod2(1:end-1)))<0;
% Compute signal at full precision from hex strings
green_sig(mod2(2:end)) = green_sig_boxcar(mod2(2:end))-green_sig_boxcar(mod2(1:end-1)) - 256.*(N_boxcars(mod2(2:end))-N_boxcars(mod2(1:end-1)));
green_ref(mod2(2:end)) = green_ref_boxcar(mod2(2:end))-green_ref_boxcar(mod2(1:end-1)) - 256.*(N_boxcars(mod2(2:end))-N_boxcars(mod2(1:end-1)));
green_sig(roll) = green_sig(roll) - 2.^32;
green_ref(roll) = green_ref(roll) - 2.^32;

% Red signals...
mod3 =  find(mod(psapi.SS,4)==3);
for m = 1:length(mod3)
   ender = psapi.ender{mod3(m)};
   %  'fa,00572bea,0bfa,fffffa,ffffff,02'
   B = textscan(ender,'%s %s %s %s %[^\n]','delimiter',',');
   red_sig_boxcar(mod3(m)) = hex2nm(B{1}); red_ref_boxcar(mod3(m)) = hex2nm(B{2});
   N_boxcars(mod3(m))= hex2nm(B{3}); over_ranges(mod3(m))= hex2nm(B{4});
   if psapi.SS(mod3(m))==7
      sr = B{5};
      red_sig_ref_ratio(mod3(m)) = sscanf(sr{1},'%f');
   end
   
end
% Compute signal at full precision from hex strings
red_sig(mod3(2:end)) = red_sig_boxcar(mod3(2:end))-red_sig_boxcar(mod3(1:end-1)) - 256.*(N_boxcars(mod3(2:end))-N_boxcars(mod3(1:end-1)));
red_ref(mod3(2:end)) = red_ref_boxcar(mod3(2:end))-red_ref_boxcar(mod3(1:end-1)) - 256.*(N_boxcars(mod3(2:end))-N_boxcars(mod3(1:end-1)));

% Catch boxcar rollover
roll = false(size(N_boxcars));
roll(mod3(2:end)) = (N_boxcars(mod3(2:end))-N_boxcars(mod3(1:end-1)))<0;
red_sig(roll) = red_sig(roll) - 2.^32;
red_ref(roll) = red_ref(roll) - 2.^32;

% Okay, done reading the file.
% %    disp('Eliminating darks, blue, green, and red refs and sigs <= 0')
% bad = dark_sig<0 | dark_ref<0 | N_boxcars<=0 | blue_sig<=0 | green_sig<=0 | red_sig<=0 ...
%    | blue_ref<=0 | green_ref<=0 | red_ref<=0;
%          TS(bad) = [];
%          for d = dmp
% %             psapi.(char(d))(bad) = []; % this may be a bug.  Not sure dmp is defined correctly
%          end


% All screening is done. Now keep only records that make a complete set
% with darks, R, G, B
dark_ii = find(~isNaN(dark_sig)); dark_ii(dark_ii>(length(psapi.time)-3)) = [];
good = mod(psapi.SS(dark_ii+1),4)==1 &mod(psapi.SS(dark_ii+2),4)==2 &mod(psapi.SS(dark_ii+3),4)==3;
dark_ii = dark_ii(good);
blue_ii = dark_ii+1; blue_ii(blue_ii>length(psapi.time)) = [];
green_ii = dark_ii+2; green_ii(green_ii>length(psapi.time)) = [];
red_ii = dark_ii+3; red_ii(red_ii>length(psapi.time)) = [];

% Build an output file with one record per complete input set
psapo.time = psapi.time(dark_ii);
% psapo.Ba_B = psapi.Ba_B(blue_ii); psapo.Ba_G = psapi.Ba_G(green_ii); psapo.Ba_R = psapi.Ba_R(red_ii);
% 
% % Front panel transmittances only good to 3 decimals, insufficient for
% % Ba coef calculation.
% psapo.Tr_B = psapi.Tr_B(blue_ii); psapo.Tr_G = psapi.Tr_G(green_ii); psapo.Tr_R = psapi.Tr_R(red_ii);
% delta field3/delta field4 / 1e5 -> average flow, LPM.
psapo.mass_flow_mv = boxcar_flow(dark_ii)./ boxcar_secs(dark_ii);
psapo.mass_flow_mv(2:end) = diff(boxcar_flow(dark_ii))./ diff(boxcar_secs(dark_ii));
% If I had parsed the parameters from mf0p0,mf0p1,mf0p2 then I'd have saved
% myself embarrassment.  
psapo.mass_flow_LPM = interp1([1000,1240,2600],[0,.3,2],psapo.mass_flow_mv, 'linear');
bad = isNaN(psapo.mass_flow_LPM);
psapo.mass_flow_LPM(bad) = interp1([1000,1240,2600],[0,.3,2],psapo.mass_flow_mv(bad), 'nearest','extrap');

psapo.current_boxcar_index = current_boxcar_index(dark_ii);
psapo.boxcar_flow = current_boxcar_index(dark_ii);
psapo.boxcar_secs = boxcar_secs(dark_ii);
psapo.dark_sig = dark_sig(dark_ii);
psapo.dark_ref = dark_ref(dark_ii);
psapo.adc_gain = adc_gain(dark_ii);

psapo.blue_sig = blue_sig(blue_ii);
psapo.blue_ref = blue_ref(blue_ii);
psapo.green_sig = green_sig(green_ii);
psapo.green_ref = green_ref(green_ii);
psapo.red_sig = red_sig(red_ii);
psapo.red_ref = red_ref(red_ii);

psapo.blue_sig_boxcar = blue_sig_boxcar(blue_ii);
psapo.blue_ref_boxcar = blue_ref_boxcar(blue_ii);
psapo.green_sig_boxcar = green_sig_boxcar(green_ii);
psapo.green_ref_boxcar = green_ref_boxcar(green_ii);
psapo.red_sig_boxcar = red_sig_boxcar(red_ii);
psapo.red_ref_boxcar = red_ref_boxcar(red_ii);
psapo.N_boxcars = N_boxcars(blue_ii);

psapo.blue_sig_ref_ratio = blue_sig_ref_ratio(blue_ii);
psapo.green_sig_ref_ratio = green_sig_ref_ratio(green_ii);
psapo.red_sig_ref_ratio = red_sig_ref_ratio(red_ii);

blueNaN =isNaN(psapo.blue_sig_ref_ratio);
psapo.blue_sig_ref_ratio(blueNaN) = interp1(find(~blueNaN),psapo.blue_sig_ref_ratio(~blueNaN), find(blueNaN),'nearest','extrap');
grnNaN =isNaN(psapo.green_sig_ref_ratio);
psapo.green_sig_ref_ratio(grnNaN) = interp1(find(~grnNaN),psapo.green_sig_ref_ratio(~grnNaN), find(grnNaN),'nearest','extrap');
redNaN =isNaN(psapo.red_sig_ref_ratio);
psapo.red_sig_ref_ratio(redNaN) = interp1(find(~redNaN),psapo.red_sig_ref_ratio(~redNaN), find(redNaN),'nearest','extrap');
psapo.endstr = psapi.ender(dark_ii);
psapo.endstr = psapo.endstr';
% figure; plot(psapo.time, (psapo.blue_sig./psapo.blue_ref)./psapo.blue_sig_ref_ratio, 'b.', psapo.time, psapo.Tr_B,'k.');
% figure; plot(psapo.time, (psapo.green_sig./psapo.green_ref)./psapo.green_sig_ref_ratio, 'g.', psapo.time, psapo.Tr_G,'k.');
% figure; plot(psapo.time, (psapo.red_sig./psapo.red_ref)./psapo.red_sig_ref_ratio, 'r.', psapo.time, psapo.Tr_R,'k.');
% some spurious values
% green_sig = psapo.green_sig_boxcar(2:end)-psapo.green_sig_boxcar(1:end-1) - 256.*(psapo.N_boxcars(2:end)-psapo.N_boxcars(1:end-1));
% green_ref = psapo.green_ref_boxcar(2:end)-psapo.green_ref_boxcar(1:end-1) - 256.*(psapo.N_boxcars(2:end)-psapo.N_boxcars(1:end-1));
% figure; plot(psapo.time(2:end), (psapo.green_sig(2:end)./psapo.green_ref(2:end))./psapo.green_sig_ref_ratio(2:end)-(green_sig./green_ref)./psapo.green_sig_ref_ratio(2:end), 'r.');

% green_sig = psapo.green_sig_boxcar(2:end)-psapo.green_sig_boxcar(1:end-1) - 256.*(psapo.N_boxcars(2:end)-psapo.N_boxcars(1:end-1));
% green_ref = psapo.green_ref_boxcar(2:end)-psapo.green_ref_boxcar(1:end-1) - 256.*(psapo.N_boxcars(2:end)-psapo.N_boxcars(1:end-1));
% figure; plot(psapo.time, (psapo.green_sig./psapo.green_ref)./psapo.green_sig_ref_ratio, 'g.', psapo.time, psapo.Tr_G,'k.',...
%    psapo.time(2:end), (green_sig./green_ref)./psapo.green_sig_ref_ratio(2:end), 'r.');

% Compute transmittances at full precision, and normalize by last PSAP reported signal ratio
psapo.trans_B = (psapo.blue_sig./psapo.blue_ref)./psapo.blue_sig_ref_ratio;
psapo.trans_G = (psapo.green_sig./psapo.green_ref)./psapo.green_sig_ref_ratio;
psapo.trans_R = (psapo.red_sig./psapo.red_ref)./psapo.red_sig_ref_ratio;

% Sometimes packets are corrupt and yield transmittances < 0.02.  Remove...
bad = psapo.trans_B<0.02; psapo.trans_B(bad) = interp1(psapo.time(~bad), psapo.trans_B(~bad),psapo.time(bad),'linear');
bad = psapo.trans_G<0.02; psapo.trans_G(bad) = interp1(psapo.time(~bad), psapo.trans_G(~bad),psapo.time(bad),'linear');
bad = psapo.trans_R<0.02; psapo.trans_R(bad) = interp1(psapo.time(~bad), psapo.trans_R(~bad),psapo.time(bad),'linear');

% green_sig = psapo.green_sig_boxcar(2:end)-psapo.green_sig_boxcar(1:end-1) - 256.*(psapo.N_boxcars(2:end)-psapo.N_boxcars(1:end-1));
% green_ref = psapo.green_ref_boxcar(2:end)-psapo.green_ref_boxcar(1:end-1) - 256.*(psapo.N_boxcars(2:end)-psapo.N_boxcars(1:end-1));
% figure; plot(psapo.time, (psapo.green_sig./psapo.green_ref)./psapo.green_sig_ref_ratio, 'g.', psapo.time, psapo.Tr_G,'k.',...
%    psapo.time(2:end), (green_sig./green_ref)./psapo.green_sig_ref_ratio(2:end), 'r.');
% figure; plot(psapo.time, [psapo.trans_B,psapo.trans_G,psapo.trans_R],'.')

% Now test Tr smoothing and compare to 2-s and 60-s averaged result.
% Gridding was implemented to avoid crazy smoothed transmittances at edges.
% Not necessary if time series is contiguous
% dark_times = psapo.time;
% psapo_grid.time = [psapo.time(1):[4./(24*60*60)]:psapo.time(end)]';
% [ainb, bina] = nearest(psapo.time,psapo_grid.time);
% fields = fieldnames(psapo);
% for f = 1:length(fields)
%    field = fields{f};
%    if ~(strcmp(field,'time')||strcmp(field,'endstr')||strcmp(field,'pname')||strcmp(field,'fname'))
%       psapo_grid.(field) = NaN(size(psapo_grid.time));
%       psapo_grid.(field)(bina) = psapo.(field)(ainb);
%    end
% end
% psapo_grid.endstr = cell(size(psapo_grid.time));
% psapo_grid.endstr(bina) = psapo.endstr(ainb);

%   flow_reg = b0 + b1.*psap_flow_lpm;
%     b0=0.0918849066; b1=1.0544449255;
% psapo.mass_flow_last = b0 + b1.*psapo.mass_flow_last;

% psapo_grid.Ba_B_sm = psapo_grid.Ba_B_sm'; psapo_grid.Ba_G_sm = psapo_grid.Ba_G_sm';
% psapo_grid.Ba_R_sm = psapo_grid.Ba_R_sm'; psapo_grid.trans_B_sm = psapo_grid.trans_B_sm';
% psapo_grid.trans_G_sm = psapo_grid.trans_G_sm'; psapo_grid.trans_R_sm= psapo_grid.trans_R_sm';

% k1=1.317; ko=0.866;
% psapo_grid.Ba_B_sm_Weiss = psapo_grid.Ba_B_sm./(k1.*psapo_grid.trans_B_sm + ko);
% psapo_grid.Ba_G_sm_Weiss = psapo_grid.Ba_G_sm./(k1.*psapo_grid.trans_G_sm + ko);
% psapo_grid.Ba_R_sm_Weiss = psapo_grid.Ba_R_sm./(k1.*psapo_grid.trans_R_sm + ko);

% figure; plot(psapo.time, [psapo.trans_B,psapo.trans_G,psapo.trans_R],'.',...
%    psapo.time, [psapo.trans_B_sm,psapo.trans_G_sm,psapo.trans_R_sm],'-');dynamicDateTicks
% legend('Tr_B raw','Tr B raw','Tr R raw','Tr B smooth', 'Tr G smooth', 'Tr R smooth');

% figure;
% plot(psapo_grid.time, [psapo_grid.trans_B,psapo_grid.trans_G,psapo_grid.trans_R],'.',...
%    psapo_grid.time, [psapo_grid.trans_B_sm,psapo_grid.trans_G_sm,psapo_grid.trans_R_sm],'-');dynamicDateTicks
% legend('Tr_B raw','Tr B raw','Tr R raw','Tr B smooth', 'Tr G smooth', 'Tr R smooth');

% ax(3) = gca;
% % These are absorption coefs when smoothed to 4x8=32s in transmittance space via smooth_Tr_Bab
% figure; plot(psapo_grid.time, [psapo_grid.Ba_B_sm_Weiss,psapo_grid.Ba_G_sm_Weiss, psapo_grid.Ba_R_sm_Weiss],'-');
% % plot(psapo_grid.time, [psapo_grid.Ba_B_sm,psapo_grid.Ba_G_sm, psapo_grid.Ba_R_sm],'-');
% ax(1) = gca;
% hold('on');
% % These are the original 2-second absorption coefficients reported by the
% % PSAP but smoothed to 2x15=30s in absorbance
% plot(psapi.time + (15./(24*60*60)), [smooth(psapi.Ba_B,60),smooth(psapi.Ba_G,60), smooth(psapi.Ba_R,60)],'o'); hold('off');
% % plot(psapo_grid.time, [smooth(psapo_grid.Ba_B,15),smooth(psapo_grid.Ba_G,15), smooth(psapo_grid.Ba_R,15)],'.');hold('off')
% legend('Ba B 32s in T','Ba G 32s in T', 'Ba R 32s in T', 'Ba B 60s in Ba','Ba G 60s in Ba', 'Ba R 60s in Ba');
% title(['Absorption coeffs ',strtok(psapi.fname,'.')]);
% dynamicDateTicks;
%
% figure; plot(psapo.time, psapo.mass_flow_last, '-x');ax(2) = gca;  dynamicDateTicks;
% % plot(psapo_grid.time, psapo_grid.mass_flow_last, '-x');ax(2) = gca;  dynamicDateTicks;
% legend('mass flow'); title(['Mass flow ',strtok(psapi.fname,'.')]);

% figure; plot((psapo.time), [psapo.blue_ref, psapo.green_ref,psapo.red_ref] ,'.-'); dynamicDateTicks; ax(4) = gca;
% legend('blue ref','green ref','red ref')
%
% figure; plot((psapo.time), [psapo.blue_sig, psapo.green_sig,psapo.red_sig] ,'-'); dynamicDateTicks; ax(5) = gca;
% legend('blue sig','green sig','red sig')
% linkaxes(ax,'x');

% save([matdir, psapi.fname(1:10), 'psapi.mat'],'-struct','psapi');
% save([matdir, psapi.fname(1:10), 'psapo.mat'],'-struct','psapo');
% save([matdir, psapi.fname(1:10), 'psapo_grid.mat'],'-struct','psapo_grid');


return