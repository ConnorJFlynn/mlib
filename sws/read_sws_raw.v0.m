function [sws_raw,dk] = read_sws_raw(filename,dk);
% [sws_raw,dk] = read_sws_raw(filename,dk);
% Read raw SWS files, populate sws_raw struct and dk struct
% dk contains .time, .Si_dark, .In_dark
% This version is mildly deprecated. The new version only reads the raw
% file but leaves the dark count determination to a subsequent process.
%%
if ~exist('filename', 'var')
   filename = getfullname('*.*','sws_raw');
else
   filename = getfullname(filename,'sws_raw');
end
[pname, fname,ext] = fileparts(filename);
fname = [fname,ext];
% length of a record is 1092 bytes.
fid = fopen(filename);
if fid>0
   sws_raw.filename = filename;
   fseek(fid,0,'eof');
   specs = floor(ftell(fid)/1092);
   fseek(fid,0,'bof');
   for s = specs:-1:1
      sws_raw.epoch_us(1:2,s) = fread(fid,2,'uint32');
      sws_raw.bcd(1:12,s) = fread(fid,12,'uchar');
      sws_raw.Si_ms(s) = fread(fid,1,'int32');
      sws_raw.In_ms(s) = fread(fid,1,'int32');
      sws_raw.accum_num(s) = fread(fid,1,'int32');
      sws_raw.shutter(s) = fread(fid,1,'int32');
      sws_raw.zen_Si_temp(s) = fread(fid,1,'uint32');
      sws_raw.zen_In_temp(s) = fread(fid,1,'uint32');
      internal_temp(s) = fread(fid,1,'uint32');
      sws_raw.pc104_5v(s) = fread(fid,1,'uint32');
      sws_raw.pc104_pos12v(s) = fread(fid,1,'uint32');
      sws_raw.pc104_neg12v(s) = fread(fid,1,'uint32');
      sws_raw.ps2_5v(s) = fread(fid,1,'uint32');
      sws_raw.ps2_12v(s) = fread(fid,1,'uint32');
      sws_raw.Si_DN(1:256,s) = fread(fid,256,'int16');
      sws_raw.In_DN(1:256,s) = fread(fid,256,'int16');
   end
   fclose(fid);


   sws_raw.epoch = sws_raw.epoch_us(1,:) + sws_raw.epoch_us(2,:)/1e6;
   sws_raw.time = epoch2serial(sws_raw.epoch);
   ch2 = ((internal_temp./2048.)*5) - 5.;
   rtem          = abs((2000. * ch2)./(1. - (0.2 * ch2)));
   sws_raw.internal_temp   = 1./(1.0295e-3+(2.391e-4 .* log(rtem)) + (1.568e-7*(log(rtem)).^3))-273.;

   lambdasi = [3.02659e2 3.29952 4.73434e-4 -1.74417e-6];
   lambdair = [  2220.03 -4.51056 -5.68468e-4 -6.68489e-6 -5.08914e-9 ];
   inds = [0:255];sdni = fliplr(inds);
   sws_raw.Si_lambda = lambdasi(1) + lambdasi(2).*inds + lambdasi(3).*inds.^2 + lambdasi(4).*inds.^3 ;
   sws_raw.In_lambda = lambdair(1) + lambdair(2).*sdni + lambdair(3).*sdni.^2 + lambdair(4).*sdni.^3 + lambdair(5).*sdni.^4;
   sws_raw.In_lambda = fliplr(sws_raw.In_lambda);
   sws_raw.Si_lambda = sws_raw.Si_lambda';
   sws_raw.In_lambda = sws_raw.In_lambda';
   darks = ~(sws_raw.shutter==0);
   if ~any(darks)
      if exist('dk','var')&&~isempty(dk)
         Si_dark = dk.Si_dark;
         In_dark = dk.In_dark;
         dark_time = dk.time;
      else
         Si_dark = zeros([size(sws_raw.Si_DN,1),1]);
         In_dark = Si_dark;
         dark_time = [];
      end
   else
      dark_time = mean(sws_raw.time(darks));
      Si_dark = mean(sws_raw.Si_DN(:,darks),2);
      In_dark = mean(sws_raw.In_DN(:,darks),2);
   end
   if max(Si_dark(:))>0 
      dk.Si_dark = Si_dark;
      dk.In_dark = In_dark;
      dk.time = dark_time;
   else
      dk = [];
   end
   sws_raw.Si_dark = Si_dark;
   sws_raw.In_dark = In_dark;
   sws_raw.dark_time = dark_time;
   sws_raw.Si_spec = sws_raw.Si_DN - Si_dark*ones([1,size(sws_raw.Si_DN,2)]);
   sws_raw.In_spec = sws_raw.In_DN - In_dark*ones([1,size(sws_raw.In_DN,2)]);
%    save([pname,fname,'.mat'],'sws_raw');
else
   sws_raw = [];
end


% for j=0,nlsi-1 do wlvis[i]     =wlvis[i]     +lamdasi[j]*float(i)^j
% Si coefs: 3.02659e2 3.29952 4.73434e-4 -1.74417e-6
% lamdaIR    2220.03 -4.51056 -5.68468e-4 -6.68489e-6 -5.08914e-9
% for i=0,np-1 do begin
%   for j=0,nlsi-1 do wlvis[i]     =wlvis[i]     +lamdasi[j]*float(i)^j
%   for j=0,nlir-1 do wlnir[np-1-i]=wlnir[np-1-i]+lamdair[j]*float(i)^j
% endfor
%%


% figure;subplot(1,2,1); plot(sws_raw.Si_lambda, sws_raw.si_DN, '.b-'); subplot(1,2,2); plot(sws_raw.In_lambda, sws_raw.in_DN,'.r-');

%%
return