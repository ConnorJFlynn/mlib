function tz = get_tzr_ret(files)
if ~isavar('files')||isempty(files)
   files = getfullname_('*.nc','tzr_ret_nc');
end
tz = [];
for d = 1:length(files)
   infile = files{d}; [pname, fname] = fileparts(infile);
   [tzstr,rest] = strtok(fname,'_');
   [~,rest] = strtok(rest,'_');[~,rest] = strtok(rest,'_');[~,rest] = strtok(rest,'_');
   dstr = strtok(rest,'_')
   disp(dstr)
   day = datenum(dstr,'yyyymmdd');
   if isafile(infile)
      vdata = anc_load(infile);
      vdata = vdata.vdata;
      vdata.time = epoch2serial(vdata.time);
      vdata = rmfield(vdata,{'time_index'});
      good = vdata.time>day & vdata.time<(day+1);
      vdata = sift_tstruct(vdata,good);
      tz = cat_timeseries(tz,vdata);
   end
end
good = tz.qc_rcod_valid==0 | tz.liq_success==1 | tz.ice_success==1;
tz = sift_tstruct(tz,good);
tz.rcod(tz.qc_rcod_valid~=0)= NaN;
tz.liq_cod(tz.liq_status~=0)= NaN;
tz.ice_cod(tz.ice_status~=0|tz.ice_cod<=0) = NaN;
save([pname, filesep,'..',filesep,tzstr, '_ret.mat'],'-struct','tz')

end
% figure; plot(tz.time(tz.qc_rcod_valid==0), tz.rcod(tz.qc_rcod_valid==0),'.',...
%    tz.time(tz.qc_rcod_valid==1), tz.rcod(tz.qc_rcod_valid==1),'r.'); legend('rcod', 'qc == 1')
% 
% figure; plot(tz.time(tz.liq_success==1), tz.liq_cod(tz.liq_success==1),'.',...
%    tz.time(tz.liq_success==0), tz.liq_cod(tz.liq_success==0),'r.'); legend('liq cod', 'liq success==0')
% % This is inconsistent with rcod
% 
% figure; plot(tz.time(tz.ice_success==1), tz.ice_cod(tz.ice_success==1),'k.',...
%    tz.time(tz.ice_success==0), tz.ice_cod(tz.ice_success==0),'r.'); legend('ice cod', 'ice_success==0')
% 
% figure; plot(tz.time(tz.liq_status==-1), tz.liq_cod(tz.liq_status==-1),'.',...
%    tz.time(tz.liq_status==0), tz.liq_cod(tz.liq_status==0),'.',...
%    tz.time(tz.liq_status==2), tz.liq_cod(tz.liq_status==2),'.'); legend('liq status -1', '0','2')
% % This is inconsistent with rcod
% 
% 
% figure; plot(tz.time(tz.ice_success==1), tz.ice_cod(tz.ice_success==1),'k.',...
%    tz.time(tz.ice_success==0), tz.ice_cod(tz.ice_success==0),'r.'); legend('ice cod', 'ice_success==0')
% 
% figure; plot(tz.time(tz.ice_success==1), tz.ice_cod(tz.ice_success==1),'k.',...
%    tz.time(tz.ice_success==0), tz.ice_cod(tz.ice_success==0),'r.'); legend('ice cod', 'ice status =-')
% 
% figure; plot(tz.time(tz.ice_status==-1), tz.ice_cod(tz.ice_status==-1),'.',...
%    tz.time(tz.ice_status==0), tz.ice_cod(tz.ice_status==0),'.',...
%    tz.time(tz.ice_status==2), tz.ice_cod(tz.ice_status==2),'.'); legend('ice cod -1', '0','2')