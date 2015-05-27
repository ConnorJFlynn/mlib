function check_assist_nc

% in_dir = ['D:\case_studies\assist\finland\finland_assist_raw\R537_21_43_47\'];
if ~exist('in_dir','var')
    in_dir = getdir('Select directory');
end
resaved = [in_dir 'resaved\'];
if ~exist(resaved,'dir')
    mkdir(resaved)
end

in_nc = dir([in_dir,'*.cdf']);
for in = length(in_nc):-1:1
    nc = ancload([in_dir, in_nc(in).name]);
    nc.clobber = true;
    nc.quiet = true;
    ancsave(nc,[resaved, in_nc(in).name]);
    outs = dir([resaved,in_nc(in).name]);
    if outs.bytes~=in_nc(in).bytes
        disp(char(in_nc(in).name))
        disp(['New size - old size: ',num2str(outs.bytes - in_nc(in).bytes)]);
    else
        delete([resaved,in_nc(in).name])
    end
    nc2 = ancload([[resaved, in_nc(in).name]]);
    opts.verbose = true;
    nc3 = ancdiff(nc, nc2,opts);
        
end
    
