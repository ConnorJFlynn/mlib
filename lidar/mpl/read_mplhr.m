function newmplhr = read_mplhr(fname, oldmplhr)

if nargin < 1;
   [fname, pname] = uigetfile('*.cdf;*.nc');
   fname = [pname fname];
end
mpl_id = ncmex('open', fname);
if mpl_id >0
   bin_heights = nc_getvar(mpl_id, 'bin_heights');
   time = nc_time(mpl_id);
   det = nc_getvar(mpl_id, 'backscatter');
   lower = mean(det(1:10,:)');
   zt = min(find(lower>1));
   det(1:zt-1,:) = [];
   range = bin_heights(1:end-zt+1);
   bg = mean(det(1500:1990,:))';
   signal = det - ones(size(range))*bg';
   prof = signal .* ((range.^2)*ones(size(time')));
   ncmex('close', mpl_id);
   figure(1); imagesc(serial2Hh(time), range(1:500), prof(1:500,:)); axis('xy')
   xlabel('Time (hours GMT)');
   ylabel('range (meters)');
   title(['MPL backscatter plot for ', datestr(time(1),1)]);
   if nargin > 1
      newmplhr.time = [oldmplhr.time; time];
      newmplhr.range = oldmplhr.range;
      newmplhr.bg = [oldmplhr.bg; bg];
      newmplhr.backscatter = [oldmplhr.backscatter'; prof']';
      figure(2); imagesc(serial2Hh(newmplhr.time), newmplhr.range(1:500), newmplhr.backscatter(1:500,:)); axis('xy')
      xlabel('Time (hours GMT)');
      ylabel('range (meters)');
      title(['MPL backscatter plot for ', datestr(time(1),1)]);
   else
      newmplhr.time = time;
      newmplhr.range = range;
      newmplhr.bg = bg;
      newmplhr.backscatter = prof;
   end
else
   if nargin > 1
      newmplhr = oldplhr;
   else
      newmplhr = [];
   end
end
