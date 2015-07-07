%%
% Let's try identifying filter changes in reverse, identify periods where
% the filter is stable, or more accurately where the front-panel / raw
% transmission ratio is sufficiently stable. 
% 


% Cursory look at BNL AOS 1-s data
% After cursory examination, path should be:
% Import existing NOAA AOS 60-second b1-level file used as input to AIP.  
% Identify the corresponding fields in BNL AOS 1-s datastream.
% For first stage, simply eliminate any unmatched fields.  This defines a first
% cut at the 60-s file.  At a later stage, perhaps identify  unmatched fields
% from the BNL stream that should be propagated in addition.
% Apply filters and averaging to the 1-s BNL data to populate the 60-s
% b1-file.  Optimally also populate the QC fields, but if necessary to make
% the deadline postpone this activity.
%%
% Trying to improve PSAP filter detection and our handling of pathologicals

% Examine std of ratio between raw and front-panel transmittance as
% indication of filter change.
% Add in requirement of largish positive delta in Tr

% What should we really be doing when the front-panel transmittances exceed
% unity?  


tr_blue=maob1_.vdata.tr_blue;
ch = maob1_.vdata.tr_blue > 9;
tr_blue(tr_blue>9) = NaN;
transmittance_blue_raw=maob1_.vdata.transmittance_blue_raw;
transmittance_blue_raw(transmittance_blue_raw<-9000) = NaN;

tr_B_rat = tr_blue./transmittance_blue_raw;
good = madf_span(tr_B_rat,300); good(good) = madf_span(tr_B_rat(good),300); 
good(good) = madf_span(tr_B_rat(good),300,3); 

std_10min_tr_B_rat = NaN(size(good));

tic;
std_10min_tr_B_rat(good) = stdwin(tr_B_rat(good), 300);
toc;
figure; 
xx(1) = subplot(3,1,1); 
plot(maob1_.time, transmittance_blue_raw, 'k-',(maob1_.time), tr_blue, '-b.',maob1_.time(ch), tr_blue(ch), 'ro');dynamicDateTicks;
legend('raw','Tr')
xx(2) = subplot(3,1,2); 
plot(maob1_.time, tr_B_rat, 'r.',maob1_.time(good), tr_B_rat(good), 'b.');dynamicDateTicks; legend('Tr Rat')
xx(3) = subplot(3,1,3); 
plot(maob1_.time, std_10min_tr_B_rat,'-r.');dynamicDateTicks;
legend('std');
logy
linkaxes(xx, 'x');

change = std_10min_tr_B_rat > 1e-3;
start_ch =(change(1:end-1)==0&change(1:end-1)~=change(2:end));
figure; plot(maob1_.time, maob1_.vdata.tr_blue,'b.', maob1_.time(find(start_ch)),maob1_.vdata.tr_blue(find(start_ch)),'rx')
dynamicDateTicks; linkaxes([xx,gca],'x')
change = std_10min_tr_B_rat>1e-3; 
change(2:end-1) =change(1:end-2)|change(2:end-1)|change(3:end);


% Apply Neph truncation correction and correct to STP.
% Apply PSAP 3w scattering corrections as identified in Ogren paper
% (generalization of Bond et all correction). 
met_dir = 'H:\data\dmf\sbs\sbsaosmetS2.a1\';
if ~exist(met_dir,'dir')
    met_dir = getdir('aos_met','Select directory for BNL AOS Met data.');
end
cpc_dir = 'H:\data\dmf\sbs\sbsaoscpcS2.a1\';
if ~exist(cpc_dir,'dir')
    cpc_dir = getdir('aos_cpc','Select directory for BNL AOS CPC data.');
end
psap3w_dir = 'H:\data\dmf\sbs\sbsaospsap3wS2.a1\';
if ~exist(psap3w_dir,'dir')
    psap3w_dir = getdir('aos_psap3w','Select directory for BNL AOS PSAP-3w data.');
end
neph_ref_dir = 'H:\data\dmf\sbs\sbsaosnephdryS2.a1\';
if ~exist(neph_ref_dir,'dir')
    neph_ref_dir = getdir('aos_neph_ref','Select directory for BNL AOS Ref Neph data.');
end
neph_ramp_dir = 'H:\data\dmf\sbs\sbsaosnephwetS2.a1\';
if ~exist(neph_ramp_dir,'dir')
    neph_ramp_dir = getdir('aos_neph_ramp','Select directory for BNL AOS Ramp Neph.');
end

[pname, fname, ext] = fileparts(neph_ramp_dir);
emanp = fliplr(pname);
[kot, dad] = strtok(emanp,filesep);
tok = fliplr(kot);
dad = fliplr(dad);
site = tok(1:3);
fac = tok(end-4:end);

aos_grid_dir = [dad,site,'aosgrid1s',fac];
if ~exist(aos_grid_dir,'dir')
    mkdir(aos_grid_dir);
end
aos_gridd_dir = [dad,site,'aosgrid60s',fac];
if ~exist(aos_gridd_dir,'dir')
    mkdir(aos_gridd_dir);
end
%%
mets = dir([met_dir,'*.cdf']);
for m = 1:length(mets)
    met_name = mets(m).name;
    [tok,rest] = strtok(met_name, '.');
    [tok,rest] = strtok(rest, '.');
    [ymd,rest] = strtok(rest, '.');
    
    in_ymd = dir([met_dir,'*',ymd,'*.cdf']);
    aos_met = ancload([met_dir,in_ymd(1).name]);
    for ys = 2:length(in_ymd)
        aos_met = anccat(aos_met,ancload([met_dir,in_ymd(ys).name]));
    end
    
    in_ymd = dir([cpc_dir,'*',ymd,'*.cdf']);
    aos_cpc = ancload([cpc_dir,in_ymd(1).name]);
    for ys = 2:length(in_ymd)
        aos_cpc = anccat(aos_cpc,ancload([cpc_dir,in_ymd(ys).name]));
    end

    in_ymd = dir([psap3w_dir,'*',ymd,'*.cdf']);
    aos_psap3w = ancload([psap3w_dir,in_ymd(1).name]);
    for ys = 2:length(in_ymd)
        aos_psap3w = anccat(aos_psap3w,ancload([psap3w_dir,in_ymd(ys).name]));
    end
    
    in_ymd = dir([neph_ref_dir,'*',ymd,'*.cdf']);
    aos_neph_ref = ancload([neph_ref_dir,in_ymd(1).name]);
    for ys = 2:length(in_ymd)
        aos_neph_ref = anccat(aos_neph_ref,ancload([neph_ref_dir,in_ymd(ys).name]));
    end
    
    in_ymd = dir([neph_ramp_dir,'*',ymd,'*.cdf']);
    aos_neph_ramp = ancload([neph_ramp_dir,in_ymd(1).name]);
    for ys = 2:length(in_ymd)
        aos_neph_ramp = anccat(aos_neph_ramp,ancload([neph_ramp_dir,in_ymd(ys).name]));
    end
    

%%

% aos_cpc = ancload(getfullname('*.cdf','aos_cpc'));
% aos_psap3w = ancload(getfullname('*.cdf','aos_psap3w'));
% aos_neph_ref = ancload(getfullname('*.cdf','aos_neph1'));
% aos_neph_ramp = ancload(getfullname('*.cdf','aos_neph2'));

met_grid = anctimegrid2(aos_met,1./(24*60*60),floor(aos_met.time(1)),floor(aos_met.time(1))+1-1./(24*60*60),NaN);
cpc_grid = anctimegrid2(aos_cpc,1./(24*60*60),floor(aos_cpc.time(1)),floor(aos_cpc.time(1))+1-1./(24*60*60),NaN);
psap3w_grid = anctimegrid2(aos_psap3w,1./(24*60*60),floor(aos_psap3w.time(1)),floor(aos_psap3w.time(1))+1-1./(24*60*60),NaN);
neph_ref_grid = anctimegrid2(aos_neph_ref,1./(24*60*60),floor(aos_neph_ref.time(1)),floor(aos_neph_ref.time(1))+1-1./(24*60*60),NaN);
neph_ramp_grid = anctimegrid2(aos_neph_ramp,1./(24*60*60),floor(aos_neph_ramp.time(1)),floor(aos_neph_ramp.time(1))+1-1./(24*60*60),NaN);
aos_grid = met_grid;


met_ij = interp1(met_grid.time, (1:length(met_grid.time)), aos_met.time, 'nearest','extrap');
met_ij(met_ij<1) = 1; met_ij(met_ij>length(met_grid.time))=length(met_grid.time);
met_grid.vars.met_time_offset = met_grid.vars.time_offset;
met_grid.vars.met_time_offset.data = zeros(size(met_grid.vars.met_time_offset.data));
met_grid.vars.met_time_offset.data(met_ij) = 24.*60.*60.*(aos_met.time - met_grid.time(met_ij));
met_grid.vars.met_time_offset.atts.long_name.data = 'time offset of met data relative to time field';
met_grid.vars.met_time_offset.atts.units.data = 'seconds since time';
%%
% Copy met_grid into retention container, delete non-time-varying fields.
vars = fieldnames(aos_grid.vars);
for v = vars(:)'
    if ~strcmp(v,'base_time')&~any(strcmp(aos_grid.recdim.name, aos_grid.vars.(char(v)).dims))
        aos_grid.vars = rmfield(aos_grid.vars,v);
    end
end
%%
cpc_ij = interp1(cpc_grid.time, (1:length(cpc_grid.time)), aos_cpc.time, 'nearest','extrap');
cpc_ij(cpc_ij<1) = 1; cpc_ij(cpc_ij>length(cpc_grid.time))=length(cpc_grid.time);
cpc_grid.vars.cpc_time_offset = cpc_grid.vars.time_offset;
cpc_grid.vars.cpc_time_offset.data = zeros(size(cpc_grid.vars.cpc_time_offset.data));
cpc_grid.vars.cpc_time_offset.data(cpc_ij) = 24.*60.*60.*(aos_cpc.time - cpc_grid.time(cpc_ij));
cpc_grid.vars.cpc_time_offset.atts.long_name.data = 'time offset of cpc data relative to time field';
cpc_grid.vars.cpc_time_offset.atts.units.data = 'seconds since time';
%%
% Copy non-recdim dims and time-varying fields from cpc_grid into retention container.
dims = fieldnames(cpc_grid.dims);
for d = dims(:)'
    if ~strcmp(d,cpc_grid.recdim.name)
        if ~isfield(aos_grid.dims,d)
        aos_grid.dims.(d) = cpc_grid.dims.(d);
        else
            disp('duplicate name for non-recdim');
            break
        end
    end
end
vars = fieldnames(cpc_grid.vars);
for v = vars(:)'
    v = char(v);
    if ~strcmp(v,'base_time')&&~strcmp(v,'time_offset')&&~strcmp(v,'time')& ...
            any(strcmp(cpc_grid.recdim.name, cpc_grid.vars.(v).dims))
        if ~isfield(aos_grid.vars,v)
            aos_grid.vars.(v) = cpc_grid.vars.(v);
        else
            disp('attempt to copy duplicate var name');
            aos_grid.vars.(['cpc_',v]) = cpc_grid.vars.(v);
        end
    end
end
%%

%%

psap3w_ij = interp1(psap3w_grid.time, (1:length(psap3w_grid.time)), aos_psap3w.time, 'nearest','extrap');
psap3w_ij(psap3w_ij<1) = 1; psap3w_ij(psap3w_ij>length(psap3w_grid.time))=length(psap3w_grid.time);
psap3w_grid.vars.psap3w_time_offset = psap3w_grid.vars.time_offset;
psap3w_grid.vars.psap3w_time_offset.data = zeros(size(psap3w_grid.vars.psap3w_time_offset.data));
psap3w_grid.vars.psap3w_time_offset.data(psap3w_ij) = 24.*60.*60.*(aos_psap3w.time - psap3w_grid.time(psap3w_ij));
psap3w_grid.vars.psap3w_time_offset.atts.long_name.data = 'time offset of psap3w data relative to time field';
psap3w_grid.vars.psap3w_time_offset.atts.units.data = 'seconds since time';
% Copy non-recdim dims and time-varying fields from cpc_grid into retention container.
dims = fieldnames(psap3w_grid.dims);
for d = dims(:)'
    if ~strcmp(d,psap3w_grid.recdim.name)
        if ~isfield(aos_grid.dims,d)
        aos_grid.dims.(d) = psap3w_grid.dims.(d);
        else
            disp('duplicate name for non-recdim');
            break
        end
    end
end
vars = fieldnames(psap3w_grid.vars);
for v = vars(:)'
    v = char(v);
    if ~strcmp(v,'base_time')&&~strcmp(v,'time_offset')&&~strcmp(v,'time')& ...
            any(strcmp(psap3w_grid.recdim.name, psap3w_grid.vars.(v).dims))
        if ~isfield(aos_grid.vars,v)
            aos_grid.vars.(v) = psap3w_grid.vars.(v);
        else
            disp('attempt to copy duplicate var name');
            aos_grid.vars.(['psap3w_',v]) = psap3w_grid.vars.(v);
        end
    end
end

%%
neph_ref_ij = interp1(neph_ref_grid.time, (1:length(neph_ref_grid.time)), aos_neph_ref.time, 'nearest','extrap');
neph_ref_ij(neph_ref_ij<1) = 1; neph_ref_ij(neph_ref_ij>length(neph_ref_grid.time))=length(neph_ref_grid.time);
neph_ref_grid.vars.neph_ref_time_offset = neph_ref_grid.vars.time_offset;
neph_ref_grid.vars.neph_ref_time_offset.data = zeros(size(neph_ref_grid.vars.neph_ref_time_offset.data));
neph_ref_grid.vars.neph_ref_time_offset.data(neph_ref_ij) = 24.*60.*60.*(aos_neph_ref.time - neph_ref_grid.time(neph_ref_ij));
neph_ref_grid.vars.neph_ref_time_offset.atts.long_name.data = 'time offset of neph_ref data relative to time field';
neph_ref_grid.vars.neph_ref_time_offset.atts.units.data = 'seconds since time';
%%
% Copy non-recdim dims and time-varying fields from cpc_grid into retention container.
dims = fieldnames(neph_ref_grid.dims);
for d = dims(:)'
    if ~strcmp(d,neph_ref_grid.recdim.name)
        if ~isfield(aos_grid.dims,d)
        aos_grid.dims.(d) = neph_ref_grid.dims.(d);
        else
            disp('duplicate name for non-recdim');
            break
        end
    end
end
vars = fieldnames(neph_ref_grid.vars);
for v = vars(:)'
    v = char(v);
    if ~strcmp(v,'base_time')&&~strcmp(v,'time_offset')&&~strcmp(v,'time')& ...
            any(strcmp(neph_ref_grid.recdim.name, neph_ref_grid.vars.(v).dims))
        if ~isfield(aos_grid.vars,v)
            aos_grid.vars.(v) = neph_ref_grid.vars.(v);
        else
            disp('attempt to copy duplicate var name');
            aos_grid.vars.(['neph_ref_',v]) = neph_ref_grid.vars.(v);
        end
    end
end
%%
neph_ramp_ij = interp1(neph_ramp_grid.time, (1:length(neph_ramp_grid.time)), aos_neph_ramp.time, 'nearest','extrap');
neph_ramp_ij(neph_ramp_ij<1) = 1; neph_ramp_ij(neph_ramp_ij>length(neph_ramp_grid.time))=length(neph_ramp_grid.time);
neph_ramp_grid.vars.neph_ramp_time_offset = neph_ramp_grid.vars.time_offset;
neph_ramp_grid.vars.neph_ramp_time_offset.data = zeros(size(neph_ramp_grid.vars.neph_ramp_time_offset.data));
neph_ramp_grid.vars.neph_ramp_time_offset.data(neph_ramp_ij) = 24.*60.*60.*(aos_neph_ramp.time - neph_ramp_grid.time(neph_ramp_ij));
neph_ramp_grid.vars.neph_ramp_time_offset.atts.long_name.data = 'time offset of neph_ramp data relative to time field';
neph_ramp_grid.vars.neph_ramp_time_offset.atts.units.data = 'seconds since time';
%%
dims = fieldnames(neph_ramp_grid.dims);
for d = dims(:)'
    if ~strcmp(d,neph_ramp_grid.recdim.name)
        if ~isfield(aos_grid.dims,d)
        aos_grid.dims.(d) = neph_ramp_grid.dims.(d);
        else
            disp('duplicate name for non-recdim');
            break
        end
    end
end
vars = fieldnames(neph_ramp_grid.vars);
for v = vars(:)'
    v = char(v);
    if ~strcmp(v,'base_time')&&~strcmp(v,'time_offset')&&~strcmp(v,'time')& ...
            any(strcmp(neph_ramp_grid.recdim.name, neph_ramp_grid.vars.(v).dims))
        if ~isfield(aos_grid.vars,v)
            aos_grid.vars.(v) = neph_ramp_grid.vars.(v);
        else
            disp('attempt to copy duplicate var name');
            aos_grid.vars.(['neph_ramp_',v]) = neph_ramp_grid.vars.(v);
        end
    end
end
%%
aos_grid.vars.lat = aos_met.vars.lat;
aos_grid.vars.lon = aos_met.vars.lon;
aos_grid.vars.alt = aos_met.vars.alt;


aos_gridd = ancdownsample(aos_grid,60);
%%
aos_grid = anccheck(aos_grid);
aos_gridd = anccheck(aos_gridd);

aos_grid.fname = [aos_grid_dir,filesep,site,'aosgrid1s',fac,datestr(aos_grid.time(1),'.yyyymmdd.HHMMSS'),'.cdf'];
aos_gridd.fname = [aos_gridd_dir,filesep,site,'aosgrid60s',fac,datestr(aos_gridd.time(1),'.yyyymmdd.HHMMSS'),'.cdf'];

aos_grid.clobber = true;
aos_gridd.clobber = true;
aos_grid.quiet = true;
aos_gridd.quiet = true;
ancsave(aos_grid);
ancsave(aos_gridd);
end


return