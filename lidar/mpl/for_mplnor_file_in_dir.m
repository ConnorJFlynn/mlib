% This procedure is just an empty shell.
% It interactively requests a raw data file directory and then 
% loops over the user specified actions for each file.

disp('Please select a file from a directory.');
[dirlist,pname] = dir_list('*.cdf', 'mplnor');
for i = 1:length(dirlist);
   disp(['Processing ', dirlist(i).name, ' : ', num2str(i), ' of ', num2str(length(dirlist))]);
   %    do_somethin_to_it([pname dirlist(i).name], [outdir dirlist(i).name]);
   [mpl_id] = ncmex('open', [pname, dirlist(i).name], 'write');
   sonde_path = ['F:\datastream\sgp\sgplssondeC1\cdf\'];
   [sonde_id] = ncmex('open', [sonde_path, dirlist(i).name]);
   max_dev = [ .25];
   for j = length(max_dev):-1:1
      [time, cod, below_lo, below_hi, above_lo, above_hi]  = mplnor_cod(max_dev(j), mpl_id, sonde_id);
%       figure; plot(serial2Hh(time), [above_hi', above_lo', below_hi', below_lo'], '.');
%       xlabel('Time (H.h)');
%       ylabel('height(km)');
%       legend('above upper', 'above lower', 'below upper', 'below lower');
%       title(['Rayleigh comparison regions ', datestr(time(1),29), '. max dev=', num2str(max_dev(j)) ]);
      
      figure; plot(serial2Hh(time), cod, 'r.'); 
      title([' Cloud optical depth for ', datestr(time(1),29), '. max dev=', num2str(max_dev(j)) ]);
      xlabel('Time (H.h)');
      ylabel('Cloud Optical Depth');
      print('-dpng',[pname, datestr(time(1),29), '.cloud_od.mdev_',num2str(max_dev(j)),'.png']);
      pause(5)
%      close
   end
   disp(['Done processing ', dirlist(i).name]);
end;
disp(' ')
disp(['Finished with processing all files in directory ' pname])
disp(' ')