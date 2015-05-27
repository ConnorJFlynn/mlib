function [sws_raw] = read_sws_raw(filename);
% [sws_raw] = read_sws_raw(filename);
% Read raw SWS files and populate sws_raw struct

%%

if ~exist('filename', 'var')
   filename = getfullname_('*.*','sws_raw');
else
   filename = getfullname_(filename,'sws_raw');
end
[pname, fname,ext] = fileparts(filename);
pname = [pname, filesep];
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
      sws_raw.internal_temp(s) = fread(fid,1,'uint32');
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
   ch2 = ((sws_raw.internal_temp./2048.)*5) - 5.;
   rtem          = abs((2000. * ch2)./(1. - (0.2 * ch2)));
   sws_raw.internal_temp   = 1./(1.0295e-3+(2.391e-4 .* log(rtem)) + (1.568e-7*(log(rtem)).^3))-273.;
   %%
   lambdasi = [3.02659e2 3.29952 4.73434e-4 -1.74417e-6];
   lambdair = [  2220.03 -4.51056 -5.68468e-4 -6.68489e-6 -5.08914e-9 ]; % old one
%
   lambdair = [2206.58 -4.48404 -3.19203e-4 -9.1953e-6];
   inds = [0:255];sdni = fliplr(inds);
   sws_raw.Si_lambda = lambdasi(1) + lambdasi(2).*inds + lambdasi(3).*inds.^2 + lambdasi(4).*inds.^3 ;
   sws_raw.In_lambda = lambdair(1) + lambdair(2).*sdni + lambdair(3).*sdni.^2 + lambdair(4).*sdni.^3 + lambdair(5).*sdni.^4;
%%
   sws_raw.In_DN = flipud(sws_raw.In_DN);
   sws_raw.In_lambda = fliplr(sws_raw.In_lambda);
   sws_raw.Si_lambda = sws_raw.Si_lambda';
   sws_raw.In_lambda = sws_raw.In_lambda';
   
   [sws_raw.time, time_inds] = sort(sws_raw.time);
   flds = fieldnames(sws_raw);
   for f = [2,3, 16, 17]
      sws_raw.(flds{f})= sws_raw.(flds{f})(:,time_inds);
   end
   for f = [4:15,18]
      sws_raw.(flds{f})= sws_raw.(flds{f})(time_inds);
   end
   sws_raw.pname = pname;
   sws_raw.fname = fname;
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
       figure(100)
      plot([1:length(darks)],sws_raw.Si_DN(120,:),'g-o',...
         [1:length(darks)],sws_raw.In_DN(100,:),'c-x',...
         find(darks),sws_raw.Si_DN(120,darks),'ko',...
         find(darks),sws_raw.In_DN(100,darks),'bx');
      title(sws_raw.fname,'interp','none')
      
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
   sws_raw.Si_spec = (sws_raw.Si_DN - Si_dark*ones([1,size(sws_raw.Si_DN,2)]));
   sws_raw.In_spec = (sws_raw.In_DN - In_dark*ones([1,size(sws_raw.In_DN,2)]));
   sws_raw.mean_Si_sig = mean(sws_raw.Si_spec(:,~darks),2)./mean(sws_raw.Si_ms);
   sws_raw.mean_In_sig = mean(sws_raw.In_spec(:,~darks),2)./mean(sws_raw.In_ms);

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
peak_Si = max(sws_raw.mean_Si_sig);
peak_In = max(sws_raw.mean_In_sig);
r_Si = sws_raw.Si_lambda>500 &sws_raw.Si_lambda<900;
r_In = sws_raw.In_lambda>950 &sws_raw.In_lambda<1750;
trap_Si = trapz(sws_raw.Si_lambda(r_Si), sws_raw.mean_Si_sig(r_Si));
trap_In = trapz(sws_raw.In_lambda(r_In), sws_raw.mean_In_sig(r_In));
%%
figure(101);
plot(sws_raw.Si_lambda, sws_raw.mean_Si_sig, '.b-',sws_raw.In_lambda, sws_raw.mean_In_sig,'.r-');
 title({pname;sws_raw.fname},'interp','none');
 ylabel('mean signal (cts-dk)/tint');
 xlabel('wavelength[nm]')
legend(['Si max(',sprintf('%2.3g',peak_Si),'), trapz: ',sprintf('%2.3d',trap_Si),')'],...
   ['In max(',sprintf('%2.3g',peak_In),'), trapz: ',sprintf('%2.3d',trap_In),')']);
%%
return