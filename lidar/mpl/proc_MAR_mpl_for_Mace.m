% Process MAR data from Jay Mace
mpl_inarg = define_mpl_inarg;
mpl_inarg = populate_mpl_inarg(mpl_inarg);% set colorscales appropriately. log_bs
mpl_inarg.cv_log_bs = [1.2500    5.2500];  mpl_inarg.cv_dpr = [-3     0];
mpl_inarg.assess_ray = false;mpl_inarg.assess_ap = false; mpl_inarg.Nsecs = 30; mpl_inarg.vis = 'off'; %mpl_inarg.vis = 'on';
% flip_toggle settings: assess_ray, replace ol, replace ap all false
[status,polavg] = batch_fsb1todaily(mpl_inarg); 

mats = getfullname('marM1_mpl*.mat','marmats');
if ~isempty(mats)&&isafile(mats{1})
[pname, fname, ext] = fileparts(mats{1}); pname = [pname, filesep];
end
if ~isadir([pname, '..',filesep,'nc'])
mkdir([pname, '..',filesep,'nc']);
end
pname = [pname,'..',filesep,'nc',filesep];
for m = 1:length(mats)
mplpol = load(mats{m});
[~, fname] = fileparts(mats{m});
emanf = fliplr(fname); [kot,eman] = strtok(emanf,'.');
name = fliplr(eman(2:end));
if isfield(mplpol,'polavg')
mplpol = mplpol.polavg;
end
mplpol.fname = name;
status = write_mplpolfs_flynn(mplpol, pname); 
end
