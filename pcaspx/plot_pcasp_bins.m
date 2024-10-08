function d = plot_pcasp_bins(d);
% d = plot_pcasp(d);
% Generates a two-panel plot with bin threshold on x and counts and bin
% widht on y.  Interactive selection of peak/region to compute
% center-weighed bin

% offset = 0;
% if d.setup.range >1
%     offset = d.setup.range-1;
% end
% adjThreshold = d.setup.countThreshold+double(4096*offset);
% adjAvg = d.ch_avg./d.setup.binCountWidth;

h = figure; 
sub1 = subplot(2,1,1); plot(d.adjThreshold, d.adjAvg, 'o');
ylabel('counts / bin width');
sub2 = subplot(2,1,2); plot(d.adjThreshold,d.setup.binCountWidth,'+');
ylabel('bin width')
xlabel('bin threshold')
axes(sub1);
yl = ylim;
if (d.setup.range > 1)|(d.setup.range == 0)
line([4096, 4096], yl,'linestyle','--','color','g');
end
if (d.setup.range > 2)|(d.setup.range == 0)
line([2*4096, 2*4096], yl,'linestyle','--','color','g');
end
PSLstr = [];
if isfield(d,'PSLnm')
    if ~isNaN(d.PSLnm)
        PSLstr = ['PSL size= ',num2str(d.PSLnm),'nm, '];
    end
end
titlestr = ['Filename: ',d.fname];
titlestr = {titlestr; [PSLstr,'range=',num2str(d.setup.range),', ch=',num2str(d.setup.chCount),', table ',d.setup.userTable]};
title(titlestr,'Interpreter','none');
% position = get(tt,'Position');
% set(tt,'Position',[position(1), position(2)*.98]);
% text(position(1), position(2)*1.05, ['Filename: ',d.fname],'HorizontalAlignment','center','Interpreter','none');
zoom
zoomstr = ['Zoom to isolate measurement peak.  Hit enter when ready'];
disp(zoomstr);
menu('Select when done','done')


vp = axis;
pts = find((d.adjThreshold>=vp(1))&(d.adjThreshold<=vp(2)));
[binpeak,peak_bin] = max(d.adjAvg(pts));
d.peakBin = d.adjThreshold(pts(peak_bin));
cm = d.peakBin;

% peak = d.adjThreshold(pts(peak_bin));
%%
if length(pts)>1
cm = trapz(d.adjThreshold(pts), d.adjThreshold(pts).*d.adjAvg(pts))./trapz(d.adjThreshold(pts), d.adjAvg(pts));
end
anchor = [cm,mean([binpeak,vp(4)])];
line([cm,cm], [vp(3),anchor(2)],'linestyle',':','color','r');
text(anchor(1), anchor(2),{'center-weighted bin';sprintf('%g',cm)},'color','r','HorizontalAlignment','center','VerticalAlignment','bottom');
% text(d.peakBin, binpeak*1.05,{'peak bin';num2str(d.peakBin)},'color','b','HorizontalAlignment','center','VerticalAlignment','bottom');
d.CMBin = cm;
% [tmp,fname] = fileparts(d.fname);
% print( gcf, '-dmeta', [d.pname, fname, '.emf']);
% saveas( gcf, [d.pname, fname, '.fig'],'fig');
%%
