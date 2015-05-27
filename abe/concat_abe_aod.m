% ABE AOD time series
% For each file, load the AOD and the AOD source flag
%%

abe_dir = 'F:\case_studies\ABE_vert_profs\sgpabebe1turn\';
files = dir([abe_dir,'sgp*.cdf']);

   tmp = ancload([abe_dir,files(1).name]);
   %%
   aod.atts = tmp.atts;
   aod.recdim = tmp.recdim;
   aod.dims = tmp.dims;
   aod.vars.be_aod_500 = tmp.vars.be_aod_500;
   if isfield(tmp.vars ,'angst_exponent_mfrsr_filter2')
   aod1.vars.angst_exponent_mfrsr_filter2 = tmp.vars.angst_exponent_mfrsr_filter2;
   elseif isfield(tmp.vars,'mean_angst_exponent_mfrsr')
      aod1.vars.angst_exponent_mfrsr_filter2 = tmp.vars.mean_angst_exponent_mfrsr;
   end
   aod.vars.aod_source_flag = tmp.vars.aod_source_flag;
   aod.time = tmp.time;
   %%
    
  for f = 2:length(files)
     disp(['loading file ',num2str(f),' of ',num2str(length(files))])
     tmp =  ancload([abe_dir,files(f).name]);
     
        aod1.atts = tmp.atts;
   aod1.recdim = tmp.recdim;
   aod1.dims = tmp.dims;
   aod1.vars.be_aod_500 = tmp.vars.be_aod_500;
   if isfield(tmp.vars ,'angst_exponent_mfrsr_filter2')
   aod1.vars.angst_exponent_mfrsr_filter2 = tmp.vars.angst_exponent_mfrsr_filter2;
   elseif isfield(tmp.vars,'mean_angst_exponent_mfrsr')
      aod1.vars.angst_exponent_mfrsr_filter2 = tmp.vars.mean_angst_exponent_mfrsr;
   end
   aod1.vars.aod_source_flag = tmp.vars.aod_source_flag;
   aod1.time = tmp.time;
   aod = anccat(aod,aod1);
  end
