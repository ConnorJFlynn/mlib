function mplpol = replace_ap(mplpol,inarg)

pname = [fileparts(which('assess_ap')),filesep];
files = dir([pname, inarg.tla, '*.ap.mat']);
if length(files)==1
   ap = load([pname, files(1).name]);
else
   for f = 1:length(files)
      tmp = load([pname, files(f).name]);
      in_time(f) = tmp.time(1);
      in_fname(f) = {files(f).name};
   end
   [in_time, ij] = unique(in_time); 
   in_fname = in_fname(ij);
   ff = interp1(in_time, [1:length(in_time)],mplpol.time(1),'nearest','extrap');
   ap = load([pname, in_fname{ff}]);
end



%    ap.time = mean(mplpol.time(xl_ij(ij(1:floor(length(xl_ij)./4)))));
%    ap.range = mplpol.range;
%    ap.cop_ap = new_ap;
%    ap.crs_ap = new_crs;
%    ap.cop_ap_fit = new_ap_copol;
%    ap.crs_ap_fit = new_ap_crosspol;
   mplpol.r.ap_copol = ap.cop_ap_fit;
   mplpol.r.ap_crosspol = ap.crs_ap_fit;
%    
%    fname = [inarg.tla, '.', datestr(ap.time(1),'yyyymmdd.HHMMSS'),'.ap.mat'];
%    save([pname, fname],'ap','-struct');


return


