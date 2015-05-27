function flight = rd_g1_met(met_file) 

if ~exist('met_file','var')||~exist(met_file,'file')
met_file = getfullname_('*met*.txt','tcap_g1','Select met file');
end

fid = fopen(met_file);
first = fgetl(fid);
%%
C = textscan(first, '%s','delimiter',',');
%%
f_str = repmat('%f ',[1,length(C{:})+2]);
D = textscan(fid,f_str,'delimiter',':,');
fclose(fid);
%%

[pname, fname, ext] = fileparts(met_file);
flight.fname = met_file;
%%
flight_date = datenum(fname(1:8),'yyyymmdd');
DV = datevec(flight_date);
DV = repmat(DV,length(D{1}),1);
DV(:,4) = D{1};DV(:,5) = D{2};DV(:,6) = D{3};
flight.time = datenum(DV);
D(3)=[]; D(2) = []; D(1) = [];
%%

%Pstat(mb),Ppitot(mb),Tmeas(C),Tstat(C),Tdew_GE(C),RH_GE(%),TAS_pitot(m/s),TAS_gust(m/s),WndSpd(m/s),WndDir(deg),Wnd_u(m/s),Wnd_v(m/s),Wnd_w(m/s)  
flight.Pstat_mb = D{1};
flight.Ppitot_mb = D{2};
flight.Tmeas_C = D{3};
flight.Tstat_C = D{4};
flight.Tdew_C = D{5};
flight.RH_GE = D{6};
flight.TAS_pito_mps = D{7};
flight.TAS_gust_mps = D{8};
flight.WindSpeed_mps = D{9};
flight.WindDir_deg = D{10};
flight.Wnd_u_mps = D{11};
flight.Wnd_v_mps = D{12};
flight.Wnd_w_mps = D{13};

return

