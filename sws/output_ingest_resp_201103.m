% Produce responsivity files for ingest from Matlab resp files
Si_resp = sws_Si_resp_201103;
Si_resp(:,2:end) = 1000.*Si_resp(:,2:end);
Si_tint = 40;
resp_time = datenum('20110307','yyyymmdd');
gen_sws_resp_files(Si_resp, resp_time, Si_tint);
%%
resp_time = datenum('20110307','yyyymmdd');
In_resp = sws_In_resp_201103;
In_resp(:,2:end) = 1000.*In_resp(:,2:end);
In_tint = 20;
gen_sws_resp_files(In_resp, resp_time, In_tint);
%%

