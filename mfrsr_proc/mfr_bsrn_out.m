function mfr_bsrn_out(indir,outdir)
%mfr_bsrn_out(indir,outdir)
% Produces monthly files for BSRN from daily mfrsr aod files
while ~exist('indir','var')||~exist(indir,'dir')
   indir = uigetdir;
end
if ~exist('outdir','var')
   outdir = indir;
end
% idea is to read directory of mfrsr files and generate monthly BSRN files
% Most comprehensive/correct would be to sort the input data into monthly
% chunks and assess it for filter changes, calibrations, etc before
% creating output file.
% But we'll use the more primitive method of simply checking for changes to
% filter attributes and keeping only those records in a month for which the
% filter atts match the first record.

in_list = dir([indir,filesep,'*.cdf']);
   mfr1 = ancload([indir,filesep,in_list(1).name]);
   mfr1 = ancstatic2rec(mfr1,'surface_pressure');
m = 2;
while m <=length(in_list)
   disp(['File: ',in_list(m).name, ' remaining: ',num2str(length(in_list)-m)])
   V1 = datevec(mfr1.time(1));
   mfr2 = ancload([indir,filesep,in_list(m).name]);m = m +1;
   mfr2 = ancstatic2rec(mfr2,'surface_pressure');
   if same_filters(mfr1.atts,mfr2.atts) % then accumulate data for same month
      V2 = datevec(mfr2.time);
      same_month = (V1(2)==V2(:,2));
      [mfr2,mfr3] = ancsift(mfr2, mfr2.dims.time,same_month);
      mfr1 = anccat(mfr1, mfr2);
      if ~isempty(mfr3.time)
         write_out_bsrn(outdir, mfr1);
         mfr1 = mfr3;
      end
   else %filters changed 
      write_out_bsrn(outdir, mfr1);
      this_month = V1(2);
      mfr1 = ancsift(mfr1,mfr1.dims.time, mfr1.time>mfr1.time(end));
      while isempty(mfr1.time) & m < length(in_list)
         mfr1 = ancload([indir,filesep,in_list(m).name]);m = m +1;
         V2 = datevec(mfr1.time);
         mfr1 = ancsift(mfr1, mfr1.dims.time, V2(:,2)~=this_month);
      end
      mfr1 = ancstatic2rec(mfr1,'surface_pressure');
   end
end

return
function same = same_filters(att1, att2)
same = false;
atts1 = fieldnames(att1);
% atts2 = fieldnames(att2);
a = 1;
while a <= length(atts1) 
   if ~isempty(findstr('ilter',atts1{a}))
      same = isfield(att2,atts1{a})&&strcmp(att1.(atts1{a}).data,att2.(atts1{a}).data);
      if ~same 
         return
      end
   end
   a = a +1;
end
return

