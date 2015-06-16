function spectralon_temp_tests
%%
% read Temp_Data
% starts at 2013/8/8 16:27:40.850
clear ins in_temp
ins = SAS_read_Albert_csv;
in_temp.time = ins.time;
%
in_temp.TempC = ins.Temp2;

figure; plot(serial2Hh(in_temp.time), in_temp.TempC, 'go',serial2Hh(ins.time), ins.Temp2,'kx')
clear ins
%%
bare_fiber = pack_specs_in_dir;
bare_fiber.TempC = interp1(serial2doy(in_temp.time), in_temp.TempC, serial2doy(bare_fiber.time));
%%
save([bare_fiber.pname, bare_fiber.fname,'.mat'],'-struct','bare_fiber');
pname_ref = bare_fiber.pname;
%%
clear bare_fiber
%%
button_tempRamp = pack_specs_in_dir;

button_tempRamp.TempC = interp1(serial2doy(in_temp.time), in_temp.TempC, serial2doy(button_tempRamp.time));
if sum(~isNaN(button_tempRamp.TempC))==0
    button_tempRamp.time = button_tempRamp.time - (6+5/6)./24;
    button_tempRamp.TempC = interp1(serial2doy(in_temp.time), in_temp.TempC, serial2doy(button_tempRamp.time));
end
%%
save([button_tempRamp.pname, button_tempRamp.fname, '.mat'],'-struct','button_tempRamp');

pname_ramp = button_tempRamp.pname;
clear button_tempRamp 
spec = load([pname_ref,'ReferenceFiber.mat']);
ii = find(spec.Shutter_open_TF==1&~isNaN(spec.TempC));
vis_nm = spec.nm_vis>=400 & spec.nm_vis<=1030;
nir_nm = spec.nm_nir>=1000 & spec.nm_nir<=1700;

figure; nlines = plot(spec.nm_nir(nir_nm), ...
    spec.nir_spec(ii(1:10:end),nir_nm)./(ones(size(ii(1:10:end)))*spec.nir_spec(ii(end),nir_nm)),'-');...
    recolor(nlines,serial2doy(spec.time(ii(1:10:end))));

figure; vlines = plot(spec.nm_vis(vis_nm), ...
    spec.vis_spec(ii(1:10:end),vis_nm)./(ones(size(ii(1:10:end)))*spec.vis_spec(ii(end),vis_nm)),'-');...
    recolor(vlines,serial2doy(spec.time(ii(1:10:end))));

%%
spec2 = load([pname_ramp,'SpectralonFiber_QFS_Button_tempRamp.mat']);;
jj = find(spec2.Shutter_open_TF==1&~isNaN(spec2.TempC));
[ainb, bina] = nearest(spec.time(ii), spec2.time(jj([1,end])));
[maxT,maxi] = max(spec2.TempC(jj));
maxj = jj(maxi);
%
vis_nm = spec2.nm_vis>400 & spec2.nm_vis<=1030;
nir_nm = spec2.nm_nir>=1000 & spec2.nm_nir<=1700;

%%

figure; nlines2 = plot(spec2.nm_nir(nir_nm), ...
    spec2.nir_spec(jj(1:10:end),nir_nm)./(ones(size(jj(1:10:end)))*spec2.nir_spec(jj(end),nir_nm)),'-');...
    recolor(nlines2,serial2doy(spec2.time(jj(1:10:end))));

figure; vlines2 = plot(spec2.nm_vis(vis_nm), ...
    spec2.vis_spec(jj(1:10:end),vis_nm)./(ones(size(jj(1:10:end)))*spec2.vis_spec(jj(end),vis_nm)),'-');...
    recolor(vlines2,serial2doy(spec2.time(jj(1:10:end))));

%%
 figure; ss(1) = subplot(2,1,2); plot(serial2Hh(spec2.time(ii)), ...
      spec2.nir_spec(ii,64)./spec2.nir_spec(maxj,64),'r-',...
      serial2Hh(spec2.time(ii)), ...
      spec2.vis_spec(ii,64)./spec2.vis_spec(maxj,64),'b-',...
      serial2Hh(spec2.time(ii(ainb(1):ainb(2)))), ...
      spec2.nir_spec(ii(ainb(1):ainb(2)),64)./spec2.nir_spec(maxj,64),'ro',...
      serial2Hh(spec2.time(ii(ainb(1):ainb(2)))), ...
      spec2.vis_spec(ii(ainb(1):ainb(2)),64)./spec2.vis_spec(maxj,64),'bo');
  legend('nir pixel','vis pixel')
  ss(2) = subplot(2,1,1); plot(serial2Hh(spec2.time(ii)), ...
      spec2.TempC(ii),'k-');legend('TempC');

linkaxes(ss,'x');
zoom('on');
%

!! Break into warming, cooling, warming legs.
!! Try displaying these legs vs T instead of vs time.

minT_before = min(spec2.TempC(1:maxj));
T = floor(minT_before):floor(maxT);
subT = spec2.TempC>=floor(maxT)&spec2.Shutter_open_TF==1;
warming_specs.time(length(T)+1) = mean(spec2.time(subT));
warming_specs.TempC(length(T)+1) = mean(spec2.TempC(subT));
warming_specs.nir_spec(length(T)+1,:) = mean(spec2.nir_spec(subT,:));
warming_specs.vis_spec(length(T)+1,:) = mean(spec2.vis_spec(subT,:));

for Ti = length(T):-1:1
    subT = spec2.TempC>=T(Ti)-1 & spec2.TempC<T(Ti)+1 & spec2.time<spec2.time(maxj)&spec2.Shutter_open_TF==1;
    if sum(subT)>1
        warming_specs.time(Ti) = mean(spec2.time(subT));
        warming_specs.TempC(Ti) = mean(spec2.TempC(subT));
        warming_specs.nir_spec(Ti,:) = mean(spec2.nir_spec(subT,:))./warming_specs.nir_spec(end,:);
        warming_specs.vis_spec(Ti,:) = mean(spec2.vis_spec(subT,:))./warming_specs.vis_spec(end,:);
    elseif sum(subT)==1
        warming_specs.time(Ti) = (spec2.time(subT));
        warming_specs.TempC(Ti) = (spec2.TempC(subT));
        warming_specs.nir_spec(Ti,:) = (spec2.nir_spec(subT,:))./warming_specs.nir_spec(end,:);
        warming_specs.vis_spec(Ti,:) = (spec2.vis_spec(subT,:))./warming_specs.vis_spec(end,:);
        
    end
end

minT_after = min(spec2.TempC(maxj:end));
T = floor(minT_after):floor(maxT);
subT = spec2.TempC>=floor(maxT)&spec2.Shutter_open_TF==1;
cooling_specs.time(length(T)+1) = mean(spec2.time(subT));
cooling_specs.TempC(length(T)+1) = mean(spec2.TempC(subT));
cooling_specs.nir_spec(length(T)+1,:) = mean(spec2.nir_spec(subT,:));
cooling_specs.vis_spec(length(T)+1,:) = mean(spec2.vis_spec(subT,:));

for Ti = length(T):-1:1
    subT = spec2.TempC>=T(Ti)-1 & spec2.TempC<T(Ti)+1 & spec2.time>spec2.time(maxj)&spec2.Shutter_open_TF==1;
    if sum(subT)>1
        cooling_specs.time(Ti) = mean(spec2.time(subT));
        cooling_specs.TempC(Ti) = mean(spec2.TempC(subT));
        cooling_specs.nir_spec(Ti,:) = mean(spec2.nir_spec(subT,:))./warming_specs.nir_spec(end,:);
        cooling_specs.vis_spec(Ti,:) = mean(spec2.vis_spec(subT,:))./warming_specs.vis_spec(end,:);
    elseif  sum(subT)==1
        cooling_specs.time(Ti) = (spec2.time(subT));
        cooling_specs.TempC(Ti) = (spec2.TempC(subT));
        cooling_specs.nir_spec(Ti,:) = (spec2.nir_spec(subT,:))./warming_specs.nir_spec(end,:);
        cooling_specs.vis_spec(Ti,:) = (spec2.vis_spec(subT,:))./warming_specs.vis_spec(end,:);
    end
end
%%
figure; these = plot([spec2.nm_vis(vis_nm) ,spec2.nm_nir(nir_nm)], [cooling_specs.vis_spec(1:end-1,vis_nm), cooling_specs.nir_spec(1:end-1,nir_nm)],'-'); recolor(these,floor(cooling_specs.TempC(1:end-1)));colorbar
figure; these = plot([spec2.nm_vis(vis_nm) ,spec2.nm_nir(nir_nm)], [warming_specs.vis_spec(1:end-1,vis_nm), warming_specs.nir_spec(1:end-1,nir_nm)],'-'); recolor(these,floor(warming_specs.TempC(1:end-1)));colorbar


T_8_10 = spec2.TempC>=8 & spec2.TempC<=10;
max_T = spec2.TempC>53;
figure; plot(spec2.nm_vis(vis_nm), mean(spec2.vis_spec(T_8_10,vis_nm))./mean(spec2.vis_spec(max_T,vis_nm)),'o-b',spec2.nm_nir(nir_nm), mean(spec2.nir_spec(T_8_10,nir_nm))./mean(spec2.nir_spec(max_T,nir_nm)),'x-r')
%%


%%
figure;
DN = 50;
s(1) = subplot(3,1,1); plot(serial2Hh(spec.time(ii)), ...
    spec.TempC(ii),'k-');legend('TempC');
s(2) = subplot(3,1,2); vis_lines = plot(downsample(serial2Hh(spec2.time(jj)),DN), ...
    downsample(spec2.vis_spec(jj,vis_nm),DN)./(ones(size(downsample(spec2.time(jj),DN)))*spec2.vis_spec(jj(end),vis_nm)),'-');
recolor(vis_lines, spec2.nm_vis(vis_nm));
s(3) = subplot(3,1,3); nir_lines = plot(downsample(serial2Hh(spec2.time(jj)),DN), ...
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
    % vis.lambda = downsample(vis.lambda,16);
    % vis.spec = downsample(vis.spec,16,2);
    vis.lambda = downsample(vis.lambda,4);
    vis.spec = downsample(vis.spec,4,2);
    vis.spec = vis.spec - ones(size(vis.time))*mean(vis.spec(vis.Shutter_open_TF==0,:));
    %%
    for f = 2:length(files)
        nir2 = rd_raw_SAS([pname, files(f).name]);
        nir2.lambda = downsample(nir2.lambda, 2);nir2.spec = downsample(nir2.spec,2,2);
        nir2.spec = nir2.spec - ones(size(nir2.time))*mean(nir2.spec(nir2.Shutter_open_TF==0,:));
        nir = stitch_in_time(nir, nir2);
        vis2 = rd_raw_SAS([pname, strrep(files(f).name,'nir','vis')]);
        %     vis2.lambda = downsample(vis2.lambda,16); vis2.spec = downsample(vis2.spec,16,2);
        vis2.lambda = downsample(vis2.lambda,4); vis2.spec = downsample(vis2.spec,4,2);
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