function status = clean_assist_nc
%%
status = 0;
age_hr = 1.5; % Files older than this will be cleaned and moved.
time_out = 10; % allow processing for up to this number of minutes
catch_up = 20; % allow up to this number of files to be processed per "time_out" loop

zip_dir = 'D:\DATA\ZIP\';
skip_dir = 'D:\DATA\skip\';
if ~exist(skip_dir,'dir')
    mkdir(skip_dir);
end
piz_dir = strrep(zip_dir,'ZIP','PIZ');
nc_dir = [piz_dir,'nc',filesep];
is_piz_dir = exist(piz_dir,'dir');
if is_piz_dir~=7
    mkdir(piz_dir);
end
is_nc_dir = exist(nc_dir,'dir');
if is_nc_dir ~=7
    mkdir(nc_dir);
end

% So, the idea is to first move a bunch of the _RAW.piz files since we
% aren't processing them.
% Catch unprocessed _RAW.piz files
pizs = dir([zip_dir, '*_RAW.piz']);
for z = 1:min([length(pizs),catch_up]) % for up to 'catchup' unprocessed raw piz files
    dt = datenum(pizs(z).date,'dd-mmm-yyyy HH:MM:SS');
    if etime(datevec(now),datevec(dt)) > (60*60*age_hr) % old enough
        try
            if ~exist([skip_dir,pizs(z).name],'file')
                
                movefile([zip_dir,pizs(z).name],[piz_dir,pizs(z).name]); % Move raw file
            end
        catch
            fid = fopen([skip_dir,pizs(z).name],'w');
            fclose(fid);
        end
    end
end

% Next, work on the "*_PROCESSED.piz" files in zip_dir, unzipping them into the nc_dir
% Then ancloading and ancsaving each on top of themselves before rezipping
% into the piz_dir.
pizs = dir([zip_dir, '*_PROCESSED.piz']);
z = 1;tic
while (z <= min([catch_up,length(pizs)])) && (toc < time_out*60)
    dt = datenum(pizs(z).date,'dd-mmm-yyyy HH:MM:SS');
    if etime(datevec(now),datevec(dt)) > (60*60*age_hr) % old enough
        if exist([zip_dir,pizs(z).name],'file')&&~exist([skip_dir,pizs(z).name],'file')
            try
                unzipped = unzip([zip_dir,pizs(z).name], nc_dir);
                if ~isempty(unzipped)
                    ncs = dir([nc_dir,'*.nc']);
                    for n = 1:length(ncs) % clean the nc files
                        if exist([nc_dir,ncs(n).name],'file') && ~exist([skip_dir,ncs(n).name],'file')
                            try
                                inc = ancload([nc_dir,ncs(n).name]);
                                inc.clobber = true;
                                inc.quiet = true;
                                ancsave(inc);
                                clear inc
                            catch
                                %                         movefile([nc_dir,ncs(n).name],[nc_dir,ncs(n).name, '.bad']);
                                fid = fopen([skip_dir,ncs(n).name],'w');
                                fclose(fid);
                            end
                        end % of cleaning nc files
                    end
                    zipped = zip([zip_dir,strrep(pizs(z).name,'piz','zip')],[nc_dir,'*.*']);
                    delete([nc_dir,'*.*']);pause(.1);
                    if length(zipped)==length(unzipped)
                        delete([zip_dir,pizs(z).name]);
                        movefile([zip_dir,strrep(pizs(z).name,'piz','zip')],[piz_dir,pizs(z).name]);
                    end
 
                end
            catch
                fid = fopen([skip_dir,pizs(z).name],'w');
                fclose(fid);
            end
        end 
        z = z+1;
    end % end if old enough           
end % of processing piz files

% Catch unprocessed _RAW.piz files
pizs = dir([zip_dir, '*_RAW.piz']);
for z = 1:min([length(pizs),catch_up]) % for up to 'catchup' unprocessed raw piz files
    dt = datenum(pizs(z).date,'dd-mmm-yyyy HH:MM:SS');
    if etime(datevec(now),datevec(dt)) > (60*60*age_hr) % old enough
        try
            if ~exist([skip_dir,pizs(z).name],'file')
                
                movefile([zip_dir,pizs(z).name],[piz_dir,pizs(z).name]); % Move raw file
            end
        catch
            fid = fopen([skip_dir,pizs(z).name],'w');
            fclose(fid);
        end
    end
end

status = length(pizs);
return
