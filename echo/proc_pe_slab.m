function pe = proc_pe_slab(pe,ins);
if ~exist('ins','var')
   ins.slab_win = [];
   ins.no_bed = [];
end
if ~isfield(ins,'slab_win')|isempty(ins.slab_win)
   ins.slab_win = pe.profs;
end
if ~isfield(ins,'no_bed')|isempty(ins.no_bed)
   ins.no_bed = mean(pe.trace,2);
end
pe.no_bed = ins.no_bed;
pe.slab_win = ins.slab_win;
pe.trace2 = pe.trace - pe.no_bed*ones([1,pe.profs]);
   arts = remove_artifacts(pe);
   pe.trace2 = pe.trace2 - 0.8*arts*ones([1,pe.profs]);
% pe.trace2 = pe.trace;
figure(9);
% for p = pe.slab_win:pe.slab_win:pe.profs
   for p = pe.slab_win:5:pe.profs
   slab = [(p-pe.slab_win+1):p];

   windowSize = 20;
   pe.maxabs = max(abs(pe.trace2(:,slab)),[],2);
   noco_abs = mean(pe.maxabs(1800:pe.bins)); %Assumed to have lost all coherence by end of trace
   pe.maxabs = pe.maxabs ./ mean(pe.maxabs(1800:pe.bins));
   pe.maxdiff = max(abs(diff2(pe.trace2(:,slab))),[],2);
   pe.maxdiff = pe.maxdiff ./ mean(pe.maxdiff(1800:pe.bins));
   pe.env = (pe.maxabs .* pe.maxdiff);
   pe.var = var(pe.trace2(:,slab),[],2);
   pe.var = pe.var ./ mean(pe.var(1800:pe.bins));
   start = find(pe.var>0,1,'first');

   pe.env = filter(ones(1,windowSize)/windowSize,1,pe.env);
   pe.var = filter(ones(1,windowSize)/windowSize,1,pe.var);
   pe.env = filter(ones(1,windowSize)/windowSize,1,pe.env);
   pe.var = filter(ones(1,windowSize)/windowSize,1,pe.var);
   pe.relvar = pe.var ./ pe.env;

   bed = find(pe.relvar(start:pe.bins)>.5,1,'first')+start;
   if exist('bed_line','var')
      delete(bed_line(1));   delete(bed_line(2));   delete(bed_line(3));
   end
   if exist('bed_text','var')
      delete(bed_text)
   end

   ax3(1) = subplot(3,1,1);
   plt = plot(pe.us*[start:pe.bins], pe.trace(start:pe.bins,slab), '-');
      plt = recolor(plt, [slab]);
      hold('on');plot(pe.us*[start:pe.bins], pe.no_bed(start:pe.bins), 'k'); hold('off');
   ylim([-1,1])
   bed_line(1) = line(pe.us*[bed,bed],ylim,'color','red');
   title(['Traces from file: ' pe.fname], 'interpreter','none');
   ylabel('amplitude')
   ax3(2) = subplot(3,1,2);
   plt = plot(pe.us*[start:pe.bins], pe.trace2(start:pe.bins,slab), '-');
   plt = recolor(plt, [slab]);
   ylim([-1,1])
   bed_line(2) = line([pe.us*bed,pe.us*bed],ylim,'color','red');
   bed_text = text(21,.5,sprintf('Bed Depth: %3.3g us',(bed-start)*pe.us),'fontsize',18,'color','red');
   title(['Mean subtracted traces']);
   text
   ylabel('amplitude')
   ax3(3) = subplot(3,1,3);
   plot(pe.us*[start:pe.bins], pe.relvar(start:pe.bins), 'k.');
   ylim([0,1.5])
   bed_line(3) = line([pe.us*bed,pe.us*bed],ylim,'color','red');
   title('renormalized variability')
   xlabel('bin time (us)')
   ylabel('variability')
   linkaxes(ax3,'x');
%     pause(.1)
end
function arts = remove_artifacts(pe);
arts = zeros(size(pe.no_bed));
ring1 = [970:1030];
arts(ring1) = mean(pe.trace2(ring1,:),2);
tank2 = [1290:1360];
arts(tank2) = mean(pe.trace2(tank2,:),2);
arts = mean(pe.trace2,2);
start = find(arts>0,1,'first');
bins = length(arts(start:end));
w = (linspace(1,.5,bins)').^2;
arts(start:end) = arts(start:end) .* w;

function trace = backsmooth(trace,span);
full = size(trace,1);
for i = 1:full;
   frac = i/full;
   back = floor(span*frac);
   if back > 0
      trace(i,:) = mean(trace((i-back):i,:));
   end
end