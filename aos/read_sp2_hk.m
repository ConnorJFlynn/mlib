function sp2_hk = read_sp2_hk(filename);
if ~exist('filename','var')||~exist(filename,'file')
   filename = getfullname('*.hk','sp2_hk','Select an SP2 housekeeping file');
end
[hk_path, hk_fname, ext] = fileparts(filename);
% hk_path = ['D:\case_studies\aos\harmony_summary\sp2_hk\'];
% hk_fname = ['maoaossp2S1.00.20150112.010601.raw.20150111000000.hk'];
emanf = fliplr(hk_fname); % This is 'fname' spelled backwards.
[emitetad, rest] = strtok(emanf,'.'); % this picks off the last portion
datetime = fliplr(emitetad);% this flips it back around the right ways
basetime = datenum(datetime, 'yyyymmddHHMMSS');
hk_id = fopen([filename]);
if hk_id>2
   sp2_hk.fname = [hk_fname, ext];
   
   header = fgetl(hk_id);
   
   headers = textscan(header, '%s','delimiter',char(9));
   headers = headers{:};
   format_str = repmat('%f ',[1,length(headers)]);
   hk = textscan(hk_id,format_str, 'headerlines',1);
   fclose(hk_id);
   
   sp2_hk.time_2 = basetime + hk{1}./(24*60*60);
   hk(1) = [];
   for fld = 2:length(headers)
%       plot(sp2_hk.time, hk{1}, '.'); lg = legend(headers{fld}); set(lg,'interp','none');dynamicDateTicks;
      sp2_hk.(legalize_fieldname(headers{fld})) = hk{1};
      hk(1) = [];
   end
   sp2_hk.time = igor2serial(sp2_hk.Timestamp);
end
return