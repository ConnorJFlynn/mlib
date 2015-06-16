function ts = get_Io_ts(in_dir)

if ~exist('in_dir','var')||~exist(in_dir,'dir')
    in_dir = getfullname('*.cdf','saslang');
    [in_dir, ~,~] = fileparts(in_dir);
    in_dir = [in_dir, filesep];
end

files = dir([in_dir,'*.cdf']);
disp(['loading ',num2str(1),' of ',num2str(length(files))])
tmp = ancloadcoords([in_dir,files(1).name]);
ts.atts = tmp.atts;
ts.recdim = tmp.recdim;
ts.dims = tmp.dims;
ts.vars.base_time = tmp.vars.base_time;
ts.vars.time_offset = tmp.vars.time_offset;
ts.vars.wavelength = tmp.vars.wavelength;

    ts.vars.Io = tmp.vars.am_Io;
    ts.vars.Io.dim = tmp.vars.direct_normal_irradiance.dims;
    
    ts.vars.Io_std = tmp.vars.am_Io_std;
    ts.vars.Io_std.dim = tmp.vars.direct_normal_irradiance.dims;
    
    ts.vars.chi2 = tmp.vars.am_chi2;
    ts.vars.chi2.dim = tmp.vars.direct_normal_irradiance.dims;
    
    ts.vars.tau = tmp.vars.am_tau;
    ts.vars.tau.dim = tmp.vars.direct_normal_irradiance.dims;
    
    ts.vars.tau_std = tmp.vars.am_tau_std;
    ts.vars.tau_std.dim = tmp.vars.direct_normal_irradiance.dims;

Io = ancgetdata(tmp,tmp.vars.am_Io.id);

if ~all(Io<-9990)
    ts.time(1) = floor(tmp.time(1))+15/24;
    
    ts.vars.Io = tmp.vars.am_Io;
    ts.vars.Io.data(:,1) = Io;
    
    ts.vars.Io.dim = tmp.vars.direct_normal_irradiance.dims;
    
    Io_std = ancgetdata(tmp,tmp.vars.am_Io_std.id);
    ts.vars.Io_std = tmp.vars.am_Io_std;
    ts.vars.Io_std.data(:,1) = Io_std;
    ts.vars.Io_std.dim = tmp.vars.direct_normal_irradiance.dims;
    
    chi2 = ancgetdata(tmp,tmp.vars.am_chi2.id);
    ts.vars.chi2 = tmp.vars.am_chi2;
    ts.vars.chi2.data(:,1) = chi2;
    ts.vars.chi2.dim = tmp.vars.direct_normal_irradiance.dims;
    
    tau = ancgetdata(tmp,tmp.vars.am_tau.id);
    ts.vars.tau = tmp.vars.am_tau;
    ts.vars.tau.data(:,1) = tau;
    ts.vars.tau.dim = tmp.vars.direct_normal_irradiance.dims;
    
    tau_std = ancgetdata(tmp,tmp.vars.am_tau_std.id);
    ts.vars.tau_std = tmp.vars.am_tau_std;
    ts.vars.tau_std.data(:,1) = tau_std;
    ts.vars.tau_std.dim = tmp.vars.direct_normal_irradiance.dims;
else
        disp('skipping bad AM langley')
end

Io = ancgetdata(tmp,tmp.vars.pm_Io.id);
if ~all(Io<-9990)
    ts.time(end+1) = floor(tmp.time(1))+15/24+.25;
    ts.vars.Io.data(:,end+1) = Io;
    
    Io_std = ancgetdata(tmp,tmp.vars.pm_Io_std.id);
    ts.vars.Io_std.data(:,end+1) = Io_std;
    
    chi2 = ancgetdata(tmp,tmp.vars.pm_chi2.id);
    ts.vars.chi2.data(:,end+1) = chi2;
    
    tau = ancgetdata(tmp,tmp.vars.pm_tau.id);
    ts.vars.tau.data(:,end+1) = tau;
    
    tau_std = ancgetdata(tmp,tmp.vars.pm_tau_std.id);
    ts.vars.tau_std.data(:,end+1) = tau_std;
    else
        disp('skipping bad PM langley')
end

for f = 2:length(files)
    disp(['loading ',num2str(f),' of ',num2str(length(files))])
    tmp = ancloadcoords([in_dir,files(f).name]);
    
    Io = ancgetdata(tmp,tmp.vars.am_Io.id);
    if ~all(Io<-9990)
        ts.time(end+1) = floor(tmp.time(1))+15/24;
        ts.vars.Io.data(:,end+1) = Io;
        
        Io_std = ancgetdata(tmp,tmp.vars.am_Io_std.id);
        ts.vars.Io_std.data(:,end+1) = Io_std;
        
        chi2 = ancgetdata(tmp,tmp.vars.am_chi2.id);
        ts.vars.chi2.data(:,end+1) = chi2;
        
        tau = ancgetdata(tmp,tmp.vars.am_tau.id);
        ts.vars.tau.data(:,end+1) = tau;
        
        tau_std = ancgetdata(tmp,tmp.vars.am_tau_std.id);
        ts.vars.tau_std.data(:,end+1) = tau_std;
    else
        disp('skipping bad AM langley')
    end
    
    Io = ancgetdata(tmp,tmp.vars.pm_Io.id);
    if ~all(Io<-9990)
        ts.time(end+1) = floor(tmp.time(1))+15/24+.25;
        ts.vars.Io.data(:,end+1) = Io;
        
        Io_std = ancgetdata(tmp,tmp.vars.pm_Io_std.id);
        ts.vars.Io_std.data(:,end+1) = Io_std;
        
        chi2 = ancgetdata(tmp,tmp.vars.pm_chi2.id);
        ts.vars.chi2.data(:,end+1) = chi2;
        
        tau = ancgetdata(tmp,tmp.vars.pm_tau.id);
        ts.vars.tau.data(:,end+1) = tau;
        
        tau_std = ancgetdata(tmp,tmp.vars.pm_tau_std.id);
        ts.vars.tau_std.data(:,end+1) = tau_std;
        else
        disp('skipping bad PM langley')
    end
end
%%
figure; plot(serial2doy(ts.time), ts.vars.Io.data(500,:),'o')

%%
return


