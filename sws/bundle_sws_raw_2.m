function sws =bundle_sws_raw_2(files,pname);
% sws =bundle_sws_raw_2;
% bundles selected raw sws files into one continuous strucutre 
% Uses rd_sws_raw_2 and cat_sws_raw_2 so also computes rate
if ~exist('files','var')
    files = getfullname('*.raw.dat','sws_raw','Select raw SWS files to bundle.');
end

if ~iscell(files)&&~isstruct(files)
    if ~isempty(files)
        if exist(files,'file')
            if strfind(files,'.mat')
                sws = load(files);
            else
                sws = read_sws_raw_2(files);
            end
        else
            sws = [];
        end
    else
        sws = [];
    end
elseif iscell(files)
    sws = read_sws_raw_2(files{1});
    for F = 2:length(files)
        sws = cat_sws_raw_2(sws, read_sws_raw_2(files{F}));        
    end
    
elseif isstruct(files)&~isempty(pname)
       sws = read_sws_raw_2([pname,files(1).name]);
    for F = 2:length(files)
        sws = cat_sws_raw_2(sws, read_sws_raw_2([pname,files(F).name]));        
    end

end
    
    

%%
% figure(98);
% plot([1:length(sws1.time)],serial2doy(sws1.time), 'o')
%%

return