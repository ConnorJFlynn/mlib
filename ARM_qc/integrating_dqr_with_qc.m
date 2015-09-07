% So idea is to have a datastream loaded.  Check the DQR db for selected 
% variables from this datastream, populating a structure documenting all 
% reported DQRs that cover these fields for all time.
% Then populate time series fields (for each affected field) that 
% identifies applicable DQRS and the qc impact by time.

% We're going to load anc data, call dqr_for_ds for the entire file
% then use the returned DQR struct to express the impact on the datastream.

ds_name = ['maoaosclap*.b1.*'];
anc = anc_bundle_files(getfullname(ds_name));
   [pname, fname, ext] = fileparts(anc.fname);
   
   [fstem,rest] = strtok(fname, '.');
   dlevel = strtok(rest,'.');
   ds_name = [fstem,'.',dlevel];
   ds_name = [fstem,'.a1'];
   fields = fieldnames(anc.vatts);

% This is a dqr struct for these fields in this datastream for all time.
[dqr]= dqr_for_ds(ds_name, fields);

% This subsets the input DQR struct to only those DQRs that are relevant
% to the time and fields within anc. 
[dqr_] = dqr_for_anc(anc, dqr); 

% this expresses the impact of the dqrs in dqr_ on the fields in anc.
% It will include a time-series bit-mapped field identifying active DQRs

dqr_active = uint32(zeros(size(anc.time)));
for n = length(dqr_.all.id):-1:1
   dqr_active = bitset(dqr_active,n,anc.time>dqr_.all.start_time(n)&anc.time<dqr_.all.end_time(n));
   
end

% for each field in dqr_.vars that match a field in anc, we 
vars = fieldnames(dqr_.vars);
for v = 1:length(vars)
   var = vars{v};
    dqr_var.(var) = zeros(size(anc.time));
   for n = length(dqr_.ids_by_var.(var)):-1:1
      id_ij = dqr_.ids_by_var.(var)(n);
      dqr_var.(var) = max( int8(dqr_var.(var)), int8(dqr_.all.qs(id_ij).*bitget(dqr_active,id_ij)));
   end
end

vqc_addtest(qc,qc_test);




