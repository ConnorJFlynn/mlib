%%
function [pcasp,new_d] = sort_pcasp(pcasp,old_d);
if ~exist('pcasp','var')
    pcasp=[];
    old_d = [];
end
new_d = old_d;
%%
d = rd_pcasp_dat('C:\case_studies\PCASP\20070209\');
%%
% d = rd_pcasp_dat(d.pname);
d = plot_pcasp(d);
%%
K = menu('Keep this result or discard?','Keep','Discard')
if K==1
    [tmp,fname] = fileparts(d.fname);
    print( gcf, '-dmeta', [d.pname, fname, '.emf']);
    saveas( gcf, [d.pname, fname, '.fig'],'fig');
    if isempty(pcasp)
        new_d{1} = d;
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
            old_d{length(temp_times)} = d;
            for t = 1:length(old_d)
                tt = find(pcasp.time==old_d{t}.time(1));
                new_d{tt} = old_d{t};
            end
            temp = [pcasp.peakBin,d.peakBin];
            pcasp.peakBin = temp(I);
            temp = [pcasp.CMBin , d.CMBin];
            pcasp.CMBin =temp(I);
            temp = [pcasp.range , d.setup.range];
            pcasp.range =temp(I);
            temp = [pcasp.chCount ,d.setup.chCount];
            pcasp.chCount =temp(I);
            temp = [pcasp.table; d.setup.userTable];
            pcasp.table =temp(I);
            if isfield(d,'PSLnm')
                temp = [pcasp.PSLnm ,d.PSLnm];
                pcasp.PSLnm = temp(I);
            end
        end
    end
else
    new_d = old_d;
end