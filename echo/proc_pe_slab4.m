function pe = proc_pe_slab4(pe,ins);
% pe = proc_pe_slab4(pe,ins);
% Same as proc_pe_slab3, but with extraneous stuff trimmed out.
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

pe = suppress_artifacts(pe);

for p = pe.slab_win:10:pe.profs
   slab = [(p-pe.slab_win+1):p];
   start = find(mean(pe.trace(:,slab),2)>0,1,'first');
   pe.start = start; 
   pe.var = var(pe.trace2(:,slab),[],2);
   pe.maxabs = max(abs(pe.trace2(:,slab)),[],2);
   pe.maxdiff = max(abs(diff2(pe.trace2(:,slab))),[],2);
   pe.env = (pe.maxabs .* pe.maxdiff);%These are all still normalized to one.
   windowSize = 20;
   pe.env = filter(ones(1,windowSize)/windowSize,1,pe.env); pe.env = filter(ones(1,windowSize)/windowSize,1,pe.env);
   pe.var = filter(ones(1,windowSize)/windowSize,1,pe.var); pe.var = filter(ones(1,windowSize)/windowSize,1,pe.var);
   pe.relvar = pe.var ./ pe.env; %These are all still normalized to one.
   pe.relvar(start:end) = backsmooth(pe.relvar(start:end),10);
   pe.relvar = pe.relvar ./ mean(pe.relvar(1800:pe.bins)); %Normalized to one at high bins
   pe.bed(p) = find(pe.relvar(start:pe.bins)>.5,1,'first')+start;
   if exist('bed_line','var')
      delete(bed_line(1)); delete(bed_line(3));
   end
end
figure(11); set(gcf,'position',[616    38   560   420]);
plot([1:pe.profs],(pe.bed-start)*pe.us, '-or');
title(['Bed depths computed for file: ' fname], 'interpreter','none');
xlim([0,pe.profs]);
xlabel('profile number')
ylabel('bed depth (us from wall)')
ylim('auto');yl = ylim; ylim([0,yl(2)])
print('-dpng', [pname, filesep,fname,'.bed_depth.png']);

function pe = suppress_artifacts(pe);

arts = zeros(size(pe.no_bed));
ring1 = [960:1030];
arts(ring1) = (abs(pe.no_bed(ring1)))./(max(abs(pe.no_bed(ring1))));
tank2 = [1290:1360];
arts(tank2) = (abs(pe.no_bed(tank2)))./(max(abs(pe.no_bed(tank2))));
start = find(pe.no_bed>0,1,'first');
bins = length(arts(start:end));
w = (linspace(1,.5,bins)').^2; 
arts(start:end) = arts(start:end) + w;
arts = arts./max(arts);
pe.trace2 = pe.trace - pe.no_bed*ones([1,pe.profs]);
pe.trace2 = pe.trace2 - 0.9.*arts.*mean(pe.trace2,2)*ones([1,pe.profs]);

function trace = backsmooth(trace,span);
full = size(trace,1);
for i = 1:full;
   frac = i/full;
   back = floor(span*frac);
   if back > 0
      trace(i) = mean(trace((i-back):i));
   end
end