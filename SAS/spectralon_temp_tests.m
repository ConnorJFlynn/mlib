function spectralon_temp_tests
%%
% read Temp_Data
% starts at 2013/8/8 16:27:40.850
% clear ins in_temp
% ins = SAS_read_Albert_csv;
% in_temp.time = ins.time;
% %
% in_temp.TempC = ins.Temp2;
% ins = SAS_read_Albert_csv;
% [in_temp.time, ij] = unique([in_temp.time; ins.time]);
% tmp = [in_temp.TempC; ins.Temp2];
% in_temp.TempC = tmp(ij);
% 
% figure; plot(serial2doy(in_temp.time), in_temp.TempC, 'go',serial2doy(ins.time), ins.Temp2,'kx')
% clear ins
% % read ReferenceFiber data
% %%
% infile = getfullname('*.csv','ref_spec','Select a file from the reference spec directory');
% [pname, fname,ext] = fileparts(infile); pname = [pname, filesep];
% files = dir([pname,'*nir*.csv']);
% %%
% nir = rd_raw_SAS([pname, files(1).name]);
% nir.lambda = downsample(nir.lambda, 2);
% nir.spec = downsample(nir.spec,2,2); 
% nir.spec = nir.spec - ones(size(nir.time))*mean(nir.spec(nir.Shutter_open_TF==0,:));
% vis= rd_raw_SAS([pname, strrep(files(1).name,'nir','vis')]);
% vis.lambda = downsample(vis.lambda,16); 
% vis.spec = downsample(vis.spec,16,2);
% vis.spec = vis.spec - ones(size(vis.time))*mean(vis.spec(vis.Shutter_open_TF==0,:));
% %%
% for f = 2:length(files)
%     nir2 = rd_raw_SAS([pname, files(f).name]);
%     nir2.lambda = downsample(nir2.lambda, 2);nir2.spec = downsample(nir2.spec,2,2);
%     nir2.spec = nir2.spec - ones(size(nir2.time))*mean(nir2.spec(nir2.Shutter_open_TF==0,:));
%     nir = stitch_in_time(nir, nir2);
%     vis2 = rd_raw_SAS([pname, strrep(files(f).name,'nir','vis')]);
%     vis2.lambda = downsample(vis2.lambda,16); vis2.spec = downsample(vis2.spec,16,2);
%     vis2.spec = vis2.spec - ones(size(vis2.time))*mean(vis2.spec(vis2.Shutter_open_TF==0,:));
%     vis = stitch_in_time(vis, vis2);
%     
%     disp(f)
% end
% 
% %%
% % vis.vis_spec = vis.spec; vis.nir_spec = nir.spec; vis = rmfield(vis, 'spec');
% % vis.nm_vis = vis.lambda, vis.nm_nir = nir.lambda; vis = rmfield(vis,'lambda');
% vis.TempC = interp1(serial2doy(in_temp.time), in_temp.TempC, serial2doy(vis.time));
% save([vis.pname, 'ref_spec.mat'],'-struct','vis');
%%
bare_fiber = pack_specs_in_dir;
 %%
 QFS_tempRamp = pack_specs_in_dir;
 %%
 QFS = pack_specs_in_dir;
%%
button_tempRamp = pack_specs_in_dir;

spec = load(['D:\case_studies\SAS\testing_and_characterization\20130808_SpectralonResponse_vsTemp\ReferenceFiber\ReferenceFiber.mat']);
ii = find(spec.Shutter_open_TF==1);
 vis_nm = spec.nm_vis>=350 & spec.nm_vis<=1050;
 nir_nm = spec.nm_nir>=950 & spec.nm_nir<=1700;
 
 figure; nlines = plot(spec.nm_nir(nir_nm), ...
     spec.nir_spec(ii(1:10:end),nir_nm)./(ones(size(ii(1:10:end)))*spec.nir_spec(ii(end),nir_nm)),'-');...
     recolor(nlines,serial2doy(spec.time(ii(1:10:end))));
 
  figure; vlines = plot(spec.nm_vis(vis_nm), ...
     spec.vis_spec(ii(1:10:end),vis_nm)./(ones(size(ii(1:10:end)))*spec.vis_spec(ii(end),vis_nm)),'-');...
     recolor(vlines,serial2doy(spec.time(ii(1:10:end))));

 %%
 spec2 = button_tempRamp;
 jj = find(spec2.Shutter_open_TF==1);
 [ainb, bina] = nearest(spec.time(ii), spec2.time(jj([1,end])));
 figure; ss(1) = subplot(3,1,3); plot(serial2doy(spec.time(ii)), ...
      spec.nir_spec(ii,64)./spec.nir_spec(ii(ainb(2)),64),'r-',...
      serial2doy(spec.time(ii)), ...
      spec.vis_spec(ii,64)./spec.vis_spec(ii(ainb(2)),64),'b-',...
      serial2doy(spec.time(ii(ainb(1):ainb(2)))), ...
      spec.nir_spec(ii(ainb(1):ainb(2)),64)./spec.nir_spec(ii(ainb(2)),64),'ro',...
      serial2doy(spec.time(ii(ainb(1):ainb(2)))), ...
      spec.vis_spec(ii(ainb(1):ainb(2)),64)./spec.vis_spec(ii(ainb(2)),64),'bo');
  legend('nir pixel','vis pixel')
  ss(2) = subplot(3,1,2); plot(serial2doy(spec.time(ii)), ...
      spec.TempC(ii),'k-');legend('TempC');
  ss(3) = subplot(3,1,1);  
  plot(serial2doy(spec2.time(jj)), ...
      spec2.nir_spec(jj,64)./spec2.nir_spec(jj(end),64),'r-',...
      serial2doy(spec2.time(jj)), ...
      spec2.vis_spec(jj,64)./spec2.vis_spec(jj(end),64),'b-');
linkaxes(ss,'x'); 
zoom('on');
%%
figure; 
DN = 50;
s(1) = subplot(3,1,1); plot(serial2doy(spec.time(ii)), ...
      spec.TempC(ii),'k-');legend('TempC');
s(2) = subplot(3,1,2); vis_lines = plot(downsample(serial2doy(spec2.time(jj)),DN), ...
      downsample(spec2.vis_spec(jj,vis_nm),DN)./(ones(size(downsample(spec2.time(jj),DN)))*spec2.vis_spec(jj(end),vis_nm)),'-');
  recolor(vis_lines, spec2.nm_vis(vis_nm));
s(3) = subplot(3,1,3); nir_lines = plot(downsample(serial2doy(spec2.time(jj)),DN), ...
      downsample(spec2.nir_spec(jj,nir_nm),DN)./(ones(size(downsample(spec2.time(jj),DN)))*spec2.nir_spec(jj(end),nir_nm)),'-');
  recolor(nir_lines, spec2.nm_nir(nir_nm));
 linkaxes(s,'x');

%%
figure; 
spec2.TempC = interp1(serial2doy(spec.time(ii)),spec.TempC(ii),serial2doy(spec2.time));
DN = 10;
temp_lines = plot(downsample(spec2.TempC(jj),DN), ...
      downsample(spec2.vis_spec(jj,vis_nm),DN)./(ones(size(downsample(spec2.time(jj),DN)))*spec2.vis_spec(jj(end),vis_nm)),'-');
  recolor(temp_lines, spec2.nm_vis(vis_nm));

%%
figure; 
DN = 10;
temp_lines = plot(downsample(spec2.TempC(jj),DN), ...
      downsample(spec2.nir_spec(jj,nir_nm),DN)./(ones(size(downsample(spec2.time(jj),DN)))*spec2.nir_spec(jj(end),nir_nm)),'-');
  recolor(temp_lines, spec2.nm_nir(nir_nm));

%%

return

function specs = pack_specs_in_dir
% % read ReferenceFiber data
% %%
infile = getfullname('*.csv','ref_spec','Select a file from the reference spec directory');
[pname, fname,ext] = fileparts(infile); 
mets = strtok(fliplr(pname),filesep); stem = fliplr(mets);
%%
outname = [pname,filesep, stem,'.mat'];
if exist(outname,'file')
    specs = load(outname);
else
pname = [pname, filesep];
files = dir([pname,'*nir*.csv']);
%%
nir = rd_raw_SAS([pname, files(1).name]);
nir.lambda = downsample(nir.lambda, 2);
nir.spec = downsample(nir.spec,2,2); 
nir.spec = nir.spec - ones(size(nir.time))*mean(nir.spec(nir.Shutter_open_TF==0,:));
vis= rd_raw_SAS([pname, strrep(files(1).name,'nir','vis')]);
vis.lambda = downsample(vis.lambda,16); 
vis.spec = downsample(vis.spec,16,2);
vis.spec = vis.spec - ones(size(vis.time))*mean(vis.spec(vis.Shutter_open_TF==0,:));
%%
for f = 2:length(files)
    nir2 = rd_raw_SAS([pname, files(f).name]);
    nir2.lambda = downsample(nir2.lambda, 2);nir2.spec = downsample(nir2.spec,2,2);
    nir2.spec = nir2.spec - ones(size(nir2.time))*mean(nir2.spec(nir2.Shutter_open_TF==0,:));
    nir = stitch_in_time(nir, nir2);
    vis2 = rd_raw_SAS([pname, strrep(files(f).name,'nir','vis')]);
    vis2.lambda = downsample(vis2.lambda,16); vis2.spec = downsample(vis2.spec,16,2);
    vis2.spec = vis2.spec - ones(size(vis2.time))*mean(vis2.spec(vis2.Shutter_open_TF==0,:));
    vis = stitch_in_time(vis, vis2);
    
    disp([num2str(f),' of ',num2str(length(files))])
end
clear nir2 vis2
%%
vis.vis_spec = vis.spec; vis.nir_spec = nir.spec; vis = rmfield(vis, 'spec');
vis.nm_vis = vis.lambda, vis.nm_nir = nir.lambda; vis = rmfield(vis,'lambda');
%%
mets = strtok(fliplr(vis.pname),filesep); stem = fliplr(mets);
%%
outname = [vis.pname, stem,'.mat'];
save(outname,'-struct','vis');
clear vis nir 
specs = load(outname);
end
%%
[pname, fname,ext] = fileparts(outname);
specs.fname = fname;

return