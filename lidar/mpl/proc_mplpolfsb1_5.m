function [polavg,ind] = proc_mplpolfsb1_5(nc_mplpol,inarg)
%[polavg,ind] = proc_mplpolb1_4(nc_mplpol,inarg)
% polavg contains averaged mplpol data
% ind contains index of last used value from mplpol
% mplpol is an ancstruct with mplpol data
% inarg has the following optional elements
% .outdir
% .Nsecs
% .ldr_snr
% 2008/05/21 fixed ldr_snr computations

if ~exist('nc_mplpol','var')||isempty(nc_mplpol)
   nc_mplpol = anc_load;
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
   if isfield(inarg,'ldr_snr')
      ldr_snr = inarg.ldr_snr;
   else
      ldr_snr = .25;
   end
end
%%
if isfield(nc_mplpol,'fname')&&isfield(nc_mplpol,'atts')&&isfield(nc_mplpol,'recdim')...
      &&isfield(nc_mplpol,'dims')&&isfield(nc_mplpol,'vars')&&isfield(nc_mplpol,'time')
   mplpol = anc2mplpol(nc_mplpol);
   [polavg,ind] = proc_mplpolraw_4(mplpol,inarg);
elseif isfield(nc_mplpol,'fname')&&isfield(nc_mplpol,'gatts')&&isfield(nc_mplpol,'ncdef')...
      &&isfield(nc_mplpol,'time')
   mplpol = anc_2mplpol(nc_mplpol);
   [polavg,ind] = proc_mplpolfsraw_5(mplpol,inarg);
else
   polavg = [];
   ind = [];
end
return

