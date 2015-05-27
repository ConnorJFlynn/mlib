function status = synctest
% Processes raw mpl pol data for ISDAC images
status = 0;
in_dir = ['C:\ISDAC\nsamplpolC1.00\'];
out_dir = ['C:\ISDAC\nsamplpolC1.00\processed\done\'];
fig_dir = ['C:\ISDAC\nsamplpolC1.00\processed\fig\'];
png_dir = ['C:\ISDAC\nsamplpolC1.00\processed\png\'];
mat_dir = ['C:\ISDAC\nsamplpolC1.00\processed\mat\'];
% t = timer('TimerFcn',@rsyncMPL, 'Period', 60.0, 'execution','fixedRate');
% start(t);
in_files = dir([in_dir,'*.mpl']);
for d = length(in_files):-1:1
    tmp = fliplr(in_files(d).name);
    [dmp,tmp] = strtok(tmp,'.');
    [tmp,dmp] = strtok(tmp,'.');
    tmp = fliplr(tmp);
    dates(d) = datenum(tmp,'yyyymmddHHMM_s');
end
[ds, ind] = sort(dates);

out_files = dir([out_dir,'*.mpl']);
for m = 1:length(in_files)
    done = false;
    for n = 1:length(out_files)
        done = done|strcmp(in_files(ind(m)).name,out_files(n).name);
    end
    if ~done
        status = status + 1;
        disp(['processing ',in_files(ind(m)).name]);
        mplpol = rd_Sigma([in_dir,in_files(ind(m)).name]);
        fid_out = fopen([out_dir,in_files(m).name],'w');
        fclose(fid_out);
        %if successful fwrite, then delete

        if ~exist('polavg','var')
            polavg = proc_mplpolraw(mplpol);
        else
            polavg = catpol(polavg,proc_mplpolraw(mplpol));
        end
        polavg.statics = mplpol.statics;
        hours = 6;
        polavg = cutpol(polavg,hours);
        inarg.pngdir = png_dir;
        inarg.matdir = mat_dir;
        inarg.figdir = fig_dir;
        inarg.ldr_snr = 1.;
        quicklook_pol(polavg,inarg)
    end
end
end

