function gen_mfr7nch_corrs
% gen_mfr7nch_corrs
% 2023-02-05: Implementing emailed path forward from 2022-09-22 and 2022-11-11
% 2022-11-11: regenerated TAPE12 files for mfr7nch and cimel for CO2, CH4, and H2O at
% % 0.001 1/cm res.  
% So, we'll want to load them as well as the filter transmittance.
mfr_lbl_path = ['C:\Users\flyn0011\OneDrive - University of Oklahoma\Documents\MATLAB\'];
if isafile([mfr_lbl_path,'mfr_ch7.mat'])
   mfr_lbl_ch7 = load([mfr_lbl_path,'mfr_ch7.mat']);
else
   [ch4] = rd_lblrtm_tape12_od; %1860 ppb
   [co2] = rd_lblrtm_tape12_od; %410 ppm
   [h2o_p1] = rd_lblrtm_tape12_od;[h2o_p5] = rd_lblrtm_tape12_od;[h2o_1] = rd_lblrtm_tape12_od;
   [h2o_2] = rd_lblrtm_tape12_od;[h2o_4] = rd_lblrtm_tape12_od;[h2o_6] = rd_lblrtm_tape12_od;
   [h2o_8] = rd_lblrtm_tape12_od;
   h2o.nm = h2o_1.nm;h2o.nu = h2o_1.nu; h2o.pwv = [.1, .5, 1, 2, 4,6, 8];
   h2o.od = [h2o_p1.od, h2o_p5.od, h2o_1.od, h2o_2.od, h2o_4.od, h2o_6.od, h2o_8.od];

   mfr_lbl_ch7.ch4 = ch4; mfr_lbl_ch7.co2 = co2; mfr_lbl_ch7.h2o = h2o;
   save([mfr_lbl_path, 'mfr_ch7.mat'],'-struct','mfr_lbl_ch7');
end

mfr_files = getfullname('*mfr*7nch*.nc','mfr7'); % this is  now and empty directory...
if ischar(mfr_files) mfr_files = {mfr_files}; end

m = 1; c0_fname = [];
% Not the most efficient solution but it seems to work.  It gets
% complicated because we need to check not only that the head_id is changed
% but also that the filter trace is legit
while isempty(c0_fname) & m<length(mfr_files)
   mfr = anc_loadcoords(mfr_files{m});
   head_id = sscanf(mfr.gatts.head_id,'%f');
   disp([num2str(length(mfr_files) - m),' ', dec2hex(head_id)])
   while head_id<=0 & m<length(mfr_files)
      m = m +1; length(mfr_files) - m
      mfr = anc_loadcoords(mfr_files{m});
      head_id = sscanf(mfr.gatts.head_id,'%f');
   end
   if head_id>=0 % A non-missing was found for head ID so try to write c0
     c0_fname = write_mfr7nch_c0(anc_load(mfr_files{m}), mfr_lbl_ch7);
     if ~isempty(c0_fname) % Then write was successful so display the head ID
        sscanf(mfr.gatts.head_id,'%f')
     else 
        m = m + 1;
     end
   end
end

while m<length(mfr_files)   
   while (head_id == sscanf(mfr.gatts.head_id,'%f') || (sscanf(mfr.gatts.head_id,'%f')<0) ) & m<length(mfr_files) 
      m = m + 1;  disp([num2str(length(mfr_files) - m),' ', dec2hex(head_id)])
      mfr = anc_loadcoords(mfr_files{m});
   end
   if m<length(mfr_files)
      c0_fname = write_mfr7nch_c0(anc_load(mfr_files{m}), mfr_lbl_ch7);
      if ~isempty(c0_fname)
         sscanf(mfr.gatts.head_id,'%f')
      end
   end
   if ~isempty(c0_fname)
      head_id = sscanf(mfr.gatts.head_id,'%f');
   end
end

return

