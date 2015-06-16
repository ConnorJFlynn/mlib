function sws = proc_sws_raw;
% sws = proc_sws_raw;
% pname = ['C:\case_studies\SGP\July23\sws_raw\'];

sws =bundle_sws_raw_2;
% infile = getfullname('sgpsws*.00.*.raw.dat','sws_raw','Select a raw SWS file or mat file');
% 
% 
%         [pname, fname] = fileparts(infile);pname = [pname, filesep];
%         files = dir([pname,'sgpsws*.00.*.raw.dat']);
%         tmp = load([pname, filesep,files(1).name]); sws = tmp.sws_raw; clear tmp;
%         for f = 2:length(files)
%             tmp = load([pname, filesep,files(f).name]);
%             sws = cat_sws_raw_2(sws,tmp.sws_raw); clear tmp;
%         end
% 
% pname = getdir('C:\case_studies\SGP', 'sws_raw','Select directory wtih sws raw data.')
% infiles = dir([pname, '*raw.dat']);
% 
% 
% 
% sws = read_sws_raw_2([pname, infiles(1).name]);
% for f = 2:length(infiles)
%    disp(['Loading file #',num2str(f), ' of ',num2str(length(infiles))]);
%    sws = cat_sws_raw_2(sws,read_sws_raw_2([pname, infiles(f).name]));
%    
% end
      blah = load(getfullname('sgpswsC1.resp_func.*.si.*ms.dat','sws_resp','Select SWS Si responsivity file'));
      sws.Si_resp = blah(:,2);
      blah = load(getfullname('sgpswsC1.resp_func.*.ir.*ms.dat','sws_resp','Select SWS InGaAs responsivity file'));
      sws.In_resp = blah(:,2); clear blah;

sws = rmfield(sws, 'Si_spec');
sws = rmfield(sws, 'In_spec');
%%
% sws = loadinto;
%%
      all_darks = sws.Si_DN(:,sws.shutter==1);
      darks = NaN(size(sws.Si_DN));
      for pix = length(sws.Si_lambda):-1:1
         darks(pix,:) = interp1(find(sws.shutter==1),all_darks(pix,:), [1:length(sws.time)],'nearest','extrap');
      end
      sws.Si_spec = (sws.Si_DN - darks)./(ones(size(sws.Si_lambda))*sws.Si_ms);
      clear darks
%       blah = sws_Si_resp_201103;
%       sws.Si_resp = blah(:,2);
      sws.Si_spec = sws.Si_spec./(sws.Si_resp*ones(size(sws.time)));
      %%
clear blah
      all_darks = sws.In_DN(:,sws.shutter==1);
      darks = NaN(size(sws.In_DN));
      for pix = length(sws.In_lambda):-1:1
         darks(pix,:) = interp1(find(sws.shutter==1),all_darks(pix,:), [1:length(sws.time)],'nearest','extrap');
      end
       sws.In_spec = (sws.In_DN - darks)./(ones(size(sws.In_lambda))*sws.In_ms);
      clear dark
%       blah = sws_In_resp_201103;
%       sws.In_resp = blah(:,2);
%       sws.In_resp = blah(:,3); % I think column 3 is smoothed interpolation over rel maxima.
      sws.In_spec = sws.In_spec./(sws.In_resp*ones(size(sws.time)));
      [~, max_ii_132] = max(sws.In_spec(132,:));
      wl = [990,1025]; wl_si = sws.Si_lambda>=wl(1)&sws.Si_lambda<=wl(2);
      wl_ir = sws.In_lambda>=wl(1)&sws.In_lambda<=wl(2);
      pin = mean(sws.Si_spec(wl_si,max_ii_132))./mean(sws.In_spec(wl_ir,max_ii_132));
      sws.In_spec = pin.*sws.In_spec;
%       pin = mean(sws.Si_spec(wl_si,:))./mean(sws.In_spec(wl_ir,:));
%       sws.In_spec = (ones(size(sws.In_lambda))*pin).*sws.In_spec;
      %%
save([sws.filename(1:end-7),'radiance.mat'],'sws');
%%
% Find darks and interpolate to nearest spectra.
% Divide by integration time
% Divide by responsivity

disp('Done loading files');

return