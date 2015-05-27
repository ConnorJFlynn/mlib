%%
function [pcasp,out_ds] = sort_pcasp_peaks(pcasp,in_ds);
% [pcasp,out_ds] = sort_pcasp_peaks(pcasp,in_ds);
% Used repeatedly to build structure of bin peaks (from plot_pcasp_bins) to generate 
% a time-sorted structure of all bin peaks and PSLs
% Will also retain complete input data structures

if ~exist('pcasp','var')
    pcasp=[];
    in_ds = [];
end
% if isempty(pcasp)
   d = rd_pcasp_dat;

% end
out_ds = in_ds;
%%
%%
% d = rd_pcasp_dat(d.pname);
d = plot_pcasp_bins(d); %plot_pcasp_bins has probably been renamed plot_pcasp.
%%
K = menu('Keep this result or discard?','Keep','Discard')
if K==1
    [tmp,fname] = fileparts(d.fname);
    print( gcf, '-dmeta', [d.pname, fname, '.emf']);
    saveas( gcf, [d.pname, fname, '.fig'],'fig');
    if isempty(pcasp)
        out_ds{1} = d;
        pcasp.time = d.probeTimestamp(1);
        pcasp.peakBin = d.peakBin;
        pcasp.CMBin = d.CMBin;
        pcasp.range = d.setup.range;
        pcasp.chCount =d.setup.chCount;
        pcasp.table = d.setup.userTable;
        if isfield(d,'PSLnm')
            pcasp.PSLnm = d.PSLnm;
        end
    else
        new_time = d.probeTimestamp(1);
        temp = [pcasp.time,d.probeTimestamp(1)];
        [temp_times,I,J] = unique(temp);
        if length(temp_times)>length(pcasp.time)
            pcasp.time = temp(I);
            in_ds{length(temp_times)} = d;
            for t = 1:length(in_ds)
                tt = find(pcasp.time==in_ds{t}.time(1));
                out_ds{tt} = in_ds{t};
            end
            temp = [pcasp.peakBin,d.peakBin];
            pcasp.peakBin = temp(I);
            temp = [pcasp.CMBin , d.CMBin];
            pcasp.CMBin =temp(I);
            temp = [pcasp.range , d.setup.range];
            pcasp.range =temp(I);
            temp = [pcasp.chCount ,d.setup.chCount];
            pcasp.chCount =temp(I);
            temp = {pcasp.table; d.setup.userTable};
            pcasp.table =temp(I);
            if isfield(d,'PSLnm')
                temp = [pcasp.PSLnm ,d.PSLnm];
                pcasp.PSLnm = temp(I);
            end
        end
    end
else
    out_ds = in_ds;
end