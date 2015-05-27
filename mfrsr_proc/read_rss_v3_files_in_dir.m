%%
pname = ['C:\case_studies\Alive\data\kiedron-rss\Oct2006\orig\'];
rss_files = dir([pname,'*.aodN']);
for f = 1:length(rss_files)
    f
    rss1 = read_rss_v3([pname, rss_files(f).name]);
    if ~exist('rss','var')
        rss = rss1;
        vars = fieldnames(rss1);
    else
        for v = 1:length(vars)
            rss.(char(vars(v))) = [rss.(char(vars(v))); rss1.(char(vars(v)))];
        end
    end
end
%%

