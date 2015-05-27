function pe = proc_pe_slab(pe,ins);
if ~exist('pe','var')|isempty(pe)
   pe = read_pe_raw;
end
if ~exist('ins','var')
   ins.slab_win = [];
   ins.no_bed = [];
end
if ~isfield(ins,'slab_win')|isempty(ins.slab_win)
   ins.slab_win = min(25,pe.profs);
end
if ~isfield(ins,'no_bed')|isempty(ins.no_bed)
   ins.no_bed = mean(pe.trace,2);
   ins.no_bed = zeros([pe.bins,1]);
   ins.no_bed = loadinto('pe_no_bed.mat');
end
[pname, fname, ext] = fileparts(pe.fname);
pe.no_bed = ins.no_bed;
pe.slab_win = ins.slab_win;
pe.bed = NaN([1,pe.profs]);
pe.trace2 = pe.trace - pe.no_bed*ones([1,pe.profs]);
arts = remove_artifacts(pe);
pe.trace2 = pe.trace2 - 0.8.*arts.*mean(pe.trace2,2)*ones([1,pe.profs]);
% pe.trace2 = pe.trace;
figure(10); set(gcf,'position',[ 20    38   560   420]);
figure(11); set(gcf,'position',[616    38   560   420]);
% pe.trace2 = pe.trace;

% for p = pe.slab_win:pe.slab_win:pe.profs
for p = pe.slab_win:10:pe.profs
   slab = [(p-pe.slab_win+1):p];
   start = find(mean(pe.trace(:,slab),2)>0,1,'first');
   pe.start = start;
   %
   pe.var = var(pe.trace2(:,slab),[],2);
   pe.var = pe.var ./ mean(pe.var(1800:pe.bins)); %Normalized to one at high bins
   pe.maxabs = max(abs(pe.trace2(:,slab)),[],2);
   pe.maxabs = pe.maxabs ./ mean(pe.maxabs(1800:pe.bins)); %Normalized to one at high bins
   pe.maxdiff = max(abs(diff2(pe.trace2(:,slab))),[],2);
   pe.maxdiff = pe.maxdiff ./ mean(pe.maxdiff(1800:pe.bins)); %Normalized to one at high bins
   pe.env = (pe.maxabs .* pe.maxdiff);%These are all still normalized to one.

   %    noco_abs = mean(pe.maxabs(1800:pe.bins)); %Assumed to have lost all coherence by end of trace
   windowSize = 5;
   pe.env = filter(ones(1,windowSize)/windowSize,1,pe.env); pe.env = filter(ones(1,windowSize)/windowSize,1,pe.env);
   pe.var = filter(ones(1,windowSize)/windowSize,1,pe.var); pe.var = filter(ones(1,windowSize)/windowSize,1,pe.var);

   pe.relvar = pe.var ./ pe.env; %These are all still normalized to one.
   pe.relvar(start:end) = backsmooth(pe.relvar(start:end),20);

   pe.bed(p) = find(pe.relvar(start:pe.bins)>.5,1,'first')+start;
   if exist('bed_line','var')
      delete(bed_line(1)); delete(bed_line(3));
      %    delete(bed_line(1));   delete(bed_line(2));    delete(bed_line(3));
   end
   %    if exist('bed_text','var')
   %       delete(bed_text)
   %    end
   figure(10);
   ax3(1) = subplot(2,1,1);
   plt = plot(pe.us*[start:pe.bins], pe.trace(start:pe.bins,slab), '-');
   plt = recolor(plt, [slab]);
   hold('on');plot(pe.us*[start:pe.bins], pe.no_bed(start:pe.bins), 'k'); hold('off');
   %    bed_text = text(19,.5,sprintf('Bed boundary from t-zero: %3.3g us',(pe.bed(p))*pe.us),'fontsize',16,'color','red');
   ylim([-1,1])
   bed_line(1) = line(pe.us*[pe.bed(p),pe.bed(p)],ylim,'color','red');
   title(['Traces from file: ' fname], 'interpreter','none');
   ylabel('amplitude')
   %    ax3(2) = subplot(3,1,2);
   %    plt = plot(pe.us*[start:pe.bins], pe.trace2(start:pe.bins,slab), '-');
   %    plt = recolor(plt, [slab]);
   %    ylim([-1,1])
   %    bed_line(2) = line(pe.us*[pe.bed(p),pe.bed(p)],ylim,'color','red');
   %    title(['Mean subtracted traces']);
   % %    text
   %    ylabel('amplitude')
   ax3(2) = subplot(2,1,2);
   plot(pe.us*[start:pe.bins], pe.relvar(start:pe.bins), 'k.');
   ylim([0,1.5])
   bed_line(3) = line(pe.us*[pe.bed(p),pe.bed(p)],ylim,'color','red');
   %    title('renormalized variability')
   title([sprintf('Bed boundary from t_o=%3.3g us',(pe.bed(p))*pe.us)],'fontsize',14,'color','red')

   xlabel('bin time (us)')
   ylabel('variability')
   linkaxes(ax3,'x');
   figure(11);

   plot([1:pe.profs],(pe.bed-start)*pe.us, '-or');
   title(['Bed depths computed for file: ' fname], 'interpreter','none');
   xlim([0,pe.profs]);
   %    ylim(pe.us*([start,pe.bins]-start));
   xlabel('profile number')
   ylabel('bed depth (us from wall)')
       pause(.1)
end

figure(10);
print('-dpng', [pname, filesep,fname,'.traces.png']);
figure(11);ylim('auto');yl = ylim; ylim([0,yl(2)])
print('-dpng', [pname, filesep,fname,'.bed_depth.png']);



function arts = remove_artifacts(pe);
arts = zeros(size(pe.no_bed));
ring1 = [960:1030];
arts(ring1) = mean(abs(pe.trace2(ring1,:)),2)./max(max(abs(pe.trace2(ring1,:))));
tank2 = [1290:1360];
arts(tank2) = mean(abs(pe.trace2(tank2,:)),2)./max(max(abs(pe.trace2(tank2,:))));
% arts = mean(pe.trace2,2);
start = find(mean(pe.trace2,2)>0,1,'first');
bins = length(arts(start:end));
w = (linspace(1,.5,bins)').^2; 
arts(start:end) = arts(start:end) + w;
arts = arts./max(arts);

function trace = backsmooth(trace,span);
full = size(trace,1);
for i = 1:full;
   frac = i/full;
   back = floor(span*frac);
   if back > 0
      trace(i) = mean(trace((i-back):i));
   end
end