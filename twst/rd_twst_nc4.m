function twst = rd_twst_nc4(in_file)

while ~isavar('in_file')||isempty(in_file)
   in_file = getfullname('*TWST*.nc','twst_nc4','Select instrument-level TWST file(s)');
end
if ~iscell(in_file) && isafile(in_file)
   in_file = {in_file};
end
try
twst = twst4_to_struct(in_file{1});
if length(in_file)>1
   twst2 = rd_twst_nc4(in_file(2:end)); disp(length(twst.time))
   [twst.time, ind] = unique([twst.time, twst2.time]);
   tmp = [twst.epoch, twst2.epoch];
   twst.epoch = tmp(ind);
   tmp = [twst.cod, twst2.cod];
   twst.cod = tmp(ind);
   tmp = [twst.zenrad_A, twst2.zenrad_A];
   twst.zenrad_A = tmp(:,ind);
   tmp = [twst.zenrad_B, twst2.zenrad_B];
   twst.zenrad_B = tmp(:,ind);
   tmp = [twst.raw_A, twst2.raw_A];
   twst.raw_A = tmp(:,ind);
   tmp = [twst.raw_B, twst2.raw_B];
   twst.raw_B = tmp(:,ind);
   clear twst2
% else
%    [pname, fname, ext] = fileparts(in_file); 
%    pname = [pname, filesep]; pname = strrep(pname, [filesep filesep], filesep);
%    n_str = []; n = 1;
%    while isafile([pname, fname, n_str,'.mat'])
%       n = n+1;
%       n_str = ['_',num2str(n)];
%    end
   % save([pname, fname,n_str,'.mat'],'-struct', 'twst' )
end
catch
   sprintf('Bad? %s',in_file{1})
   in_file(1) = [];
   if length(in_file)>1
      twst = rd_twst_nc4(in_file);
   end
end
end