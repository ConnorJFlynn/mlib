function [pxap, raw] = rd_pxapr_(infile)
% [pxap, raw] = rd_pxapr_(infile)
% 2024-12-25: Connor, modifying to run line-by-line to screen fragmented packets
% generated during AMICE 1c

if ~isavar('infile')
   infile = getfullname('P*AP*.R.*dat','pxap_amice','Select AMICE PXAP "R" file.');
end

if iscell(infile)&&length(infile)>1
   [pxap, raw] = rd_pxapr_(infile{1});
   raw.time = pxap.time; pxap.fname = raw.fname; 
   [pxap2, raw2] = rd_pxapr_(infile(2:end));
   raw2.time = pxap2.time;pxap2.fname = raw2.fname;
%    xap_.fname = unique([xap.fname,xap2.fname]);
   raw_.fname = unique([raw.fname, raw2.fname]);
   raw = cat_timeseries(raw, raw2);raw.fname = raw_.fname;
   pxap = cat_timeseries(pxap, pxap2); pxap.fname = raw.fname; pxap.pname = raw.pname;
else
   if iscell(infile); infile = infile{1}; end
   if isafile(infile)
      %   Detailed explanation goes here
      % 2024-07-26, 20:15:55, R 240727005758 03cd48f3 06b4799f 09c 00 041c74eb 05548bea 09c 00 038997b0 04fc9c04 09c 00 fffff920 fffffb74 09c 00 1085  .106 0084

      fid = fopen(infile);
   else
      disp('No valid file selected.')
      return
   end

   [raw.pname,raw.fname, ext] = fileparts(infile); raw.fname = [raw.fname, ext];
   if iscell(raw.fname)
      raw.fname = raw.fname{1}; 
   end
   [~, fname] = fileparts(raw.fname);
      % enamf = fliplr(fname); [emit, etad] = strtok(enamf, '.');
      % time_str = fliplr(emit); etad = strtok(etad,'.'); d_str = fliplr(etad);
      % start_time = datenum([d_str, ' ',time_str],'yyyy-mm-dd HH:MM:SS');

   raw.pname = {[raw.pname, filesep]}; raw.fname = {[raw.fname, ext]};
   pxap.fname = raw.fname; pxap.pname = raw.pname;
   
   n = 1;
   fmt_str = ''; 
   % 2024-07-26, 20:15:55, R 240727005758 03cd48f3 06b4799f 09c 00 041c74eb 05548bea 09c 00 038997b0 04fc9c04 09c 00 fffff920 fffffb74 09c 00 1085  .106 0084
   % 2024-07-26, 20:15:55, R 240727005758
   fmt_str = [fmt_str, '%s %s %*s %s ']; % date, time, msg_type, itime, 
   % 03cd48f3 06b4799f 09c 00   
   fmt_str = [fmt_str, '%x %x %x %x ']; % Sig_B, Ref_B, Samples_B, Overflow_B
   %  041c74eb 05548bea 09c 00 
   fmt_str = [fmt_str, '%x %x %x %x ']; % Sig_G, Ref_G, Samples_G, Overflow_G
   % 038997b0 04fc9c04 09c 00 
  fmt_str = [fmt_str, '%x %x %x %x ']; % Sig_R, Ref_R, Samples_R, Overflow_R
   %fffff920 fffffb74 09c 00 
   fmt_str = [fmt_str, '%x %x %x %x ']; % Sig_Dark, Ref_Dark, Samples_Dark, Overflow_Dark
   % 1085  .106 0084
   fmt_str = [fmt_str, '%f %f %x ']; % Flow_mv, flow_LPM, status

   while ~feof(fid)
      inline = fgetl(fid);
      inline = deblank(inline); enil = fliplr(inline);
      enil = deblank(enil); inline = fliplr(enil);
      if length(inline)>133 && strcmp(inline(1:2),'20')
         Aa_ = textscan(inline, fmt_str);
         if isavar('Aa')
            c =1; while c<=length(Aa_); Aa(c) = {[Aa{c};Aa_{c}]}; c = c + 1; end
         else
            Aa = Aa_;
         end
      end
   end
   fclose(fid);


  % Aa = textscan(fid,fmt_str); fclose(fid);
  %xap.signal_dark_raw(ch,:) =  typecast(uint32(num),'int32');
  Dd = Aa{1}; Tt = Aa{2};
  for dt = length(Dd):-1:1 
     DT(dt) = {[Dd{dt},' ', Tt{dt}]};
  end
  for X = 4:19
     Aa(X)= {double(typecast(uint32(Aa{X}),'int32'))};
  end
  try
     raw.time = datenum(DT,'yyyy-mm-dd, HH:MM:SS,');
  catch
     raw.time = datenum(DT,'yyyy-mm-dd HH:MM:SS,');
  end
  raw.itime = datenum(Aa{3},'yymmddHHMMSS');
  Aa(1:3) = [];
  raw.Sig_B = Aa{1}; raw.Ref_B = Aa{2}; raw.Samples_B = Aa{3}; raw.Over_B = Aa{4};
  Aa(1:4) = [];
  raw.Sig_G = Aa{1}; raw.Ref_G = Aa{2}; raw.Samples_G = Aa{3}; raw.Over_G = Aa{4};
  Aa(1:4) = [];
  raw.Sig_R = Aa{1}; raw.Ref_R = Aa{2}; raw.Samples_R = Aa{3}; raw.Over_R = Aa{4};
  Aa(1:4) = [];
  raw.Sig_Dark = Aa{1}; raw.Ref_Dark = Aa{2}; raw.Samples_Dark = Aa{3}; raw.Over_Dark = Aa{4};
  Aa(1:4) = [];
  raw.flow_mV = Aa{1}; raw.flow_LPM = Aa{2}; raw.status = Aa{3};
  Aa(1:3) = [];

  pxap = raw;
  pxap.nm = [470, 522, 660];
  % Question about whether we need to subtract the 256*sample offset
  % as per PSAP manual "Do delta field2/3 boxcars - (delta field4 boxcars * 256)"
  % or whether that is only related to the values for the I string.
  sig_rate = double(raw.Sig_R)./double(raw.Samples_R) - double(raw.Sig_Dark)./double(raw.Samples_Dark);
  ref_rate = double(raw.Ref_R)./double(raw.Samples_R) - double(raw.Ref_Dark)./double(raw.Samples_Dark);
  pxap.rel_BGR(:,3) = sig_rate./ref_rate;
  sig_rate = double(raw.Sig_G)./double(raw.Samples_G) - double(raw.Sig_Dark)./double(raw.Samples_Dark);
  ref_rate = double(raw.Ref_G)./double(raw.Samples_G) - double(raw.Ref_Dark)./double(raw.Samples_Dark);
  pxap.rel_BGR(:,2) = sig_rate./ref_rate;
  sig_rate = double(raw.Sig_B)./double(raw.Samples_B) - double(raw.Sig_Dark)./double(raw.Samples_Dark);
  ref_rate = double(raw.Ref_B)./double(raw.Samples_B) - double(raw.Ref_Dark)./double(raw.Samples_Dark);
  pxap.rel_BGR(:,1) = sig_rate./ref_rate;
  % pxap.Ba_raw = Bap_ss(pxap.time, pxap.flow_LPM, pxap.rel_BGR,60);
end

return

