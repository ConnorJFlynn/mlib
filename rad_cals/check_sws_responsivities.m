function sws = check_sws_responsivities(sws)
% sws= check_sws_responsivities(sws);
% accept directory name containing responsivity files or a structure
% containing responsivities

% Read and compare SWS responsivity files for Si, InGaAs
if ~exist('sws','var')
    pname = 'C:\case_studies\SWS\docs\b1_data_processing\official_resp_functions\';
    pname = 'C:\case_studies\SWS\docs\from_DMF_Suty\sgpswsC1\response_funcs\official_dmf\';
    pname = 'C:\case_studies\SWS\docs\from_DMF_Suty\sgpswsC1\response_funcs\';
    sws = [];
else
    if ~isstruct(sws)&&exist(sws,'dir')
        pname = sws;
    elseif ~isstruct(sws)&&~exist(sws,'dir')
        pname = 'C:\case_studies\SWS\docs\b1_data_processing\official_resp_functions\';
        pname = 'C:\case_studies\SWS\docs\from_DMF_Suty\sgpswsC1\response_funcs\official_dmf\';
        pname = 'C:\case_studies\SWS\docs\from_DMF_Suty\sgpswsC1\response_funcs\';
    end
end
if ~isstruct(sws)
    Si = dir([pname, 'sgpswsC1.resp_func.*.si.*.dat']);
    for f = length(Si):-1:1
        tmp = load([pname, Si(f).name]);
        [~,tok] = strtok(Si(f).name,'.'); [~,tok] = strtok(tok,'.');
        [ds,tok] = strtok(tok,'.');[~,tok] = strtok(tok,'.');
        tint = strtok(tok,'.');
        sws.Si.time(f) = datenum(ds,'yyyymmddHHMM');
        sws.Si.tint(f) = sscanf(tint,'%d');
        sws.Si.nm = tmp(:,1);
        sws.Si.resp(:,f) = tmp(:,2);
        sws.Si.resp_max(f) = max(sws.Si.resp(:,f));
        sws.Si.fname{f} = Si(f).name;
        sws.Si.date{f} = datestr(sws.Si.time(f),'yyyy-mm-dd');
    end
    %%
    InGaAs = dir([pname, 'sgpswsC1.resp_func.*.ir.*.dat']);
    for f = length(InGaAs):-1:1
        tmp = load([pname, InGaAs(f).name]);
        [~,tok] = strtok(InGaAs(f).name,'.'); [~,tok] = strtok(tok,'.');
        [ds,tok] = strtok(tok,'.');[~,tok] = strtok(tok,'.');
        tint = strtok(tok,'.');
        sws.In.time(f) = datenum(ds,'yyyymmddHHMM');
        sws.In.tint(f) = sscanf(tint,'%d');
        sws.In.nm = tmp(:,1);
        sws.In.resp(:,f) = tmp(:,2);
        sws.In.resp_max(f) = max(sws.In.resp(:,f));
        sws.In.fname{f} = InGaAs(f).name;
        sws.In.date{f} = datestr(sws.In.time(f),'yyyy-mm-dd');
    end
end

%%
% resp = sws_Si_resp_201103;
%%
% This file is for checking SWS responsivities over time.
% Note that the baffle and window were introduced in 2009? and the InGaAs
% spectrometer was replaced in 2011.
%%
figure; lines = plot(sws.Si.nm, sws.Si.resp,'-');
% figure; plot(sws.Si_nm, sws.Si_resp(:,1:end-1),'-',resp(:,1), 1000.*resp(:,2),'o');
recolor(lines,[1:length(lines)]);
for f =length(sws.Si.time):-1:1
    legstr{f} = [datestr(sws.Si.time(f),'mmm dd, yyyy')];
end
legend(legstr{:})


%%
% InGaAs_resp = sws_In_resp_201103;

%%
% figure; plot(sws.InGaAs_nm, sws.InGaAs_resp,'-',InGaAs_resp(:,1), 1000.*InGaAs_resp(:,2),'o');
figure; lines = plot(sws.In.nm, sws.In.resp,'-');
recolor(lines,[1:length(lines)]);
clear legstr
for f =length(sws.In.time):-1:1
    legstr{f} = [datestr(sws.In.time(f),'mmm dd, yyyy')];
end
legend(legstr{:})

%%
return