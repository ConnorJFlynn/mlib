function [mplavg,ind] = proc_mpl_a1(mpl,inarg)
%[mplavg,ind] = proc_mpl_a1(mpl,inarg)
% mplavg contains averaged mpl data
% ind contains index of last used value from mplpol
% nc_mpl is an ancstruct with mplpol data
% inarg has the following optional elements 
% .outdir 
% .Nsecs
% .ldr_snr
% 2008/05/21 fixed ldr_snr computations

if ~exist('mpl','var')||isempty(mpl)
   mpl = read_mpl;
   disp('Loaded file');
end
if ~exist('inarg','var');
   inarg = [];
   Nsecs = 120;
   ldr_snr = .25;
else
   if isfield(inarg,'out_dir')
      outdir = inarg.out_dir;
   else
      outdir = [];
   end
   if isfield(inarg,'Nsecs')
      Nsecs = inarg.Nsecs;
   else
      Nsecs = 60;
   end

end
mplavg = proc_mplraw(mpl,inarg);

return

