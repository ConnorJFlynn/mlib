function pe = read_pe_noshift;
% Reads a pulse-echo binary data file, 2048 bins as 8-byte "double"
bins = 2048;
pe.bins = bins;
[fid,fname,pname] = getfile('*.bin','echo');
status = fseek(fid,0,1);
profs = ftell(fid)/(8*bins);
pe.profs = profs;
status = fseek(fid,0,-1);
pe.trace = fread(fid,[bins,profs],'double');
pe.fname = fname;
pe.pname = pname;
fclose(fid);

% pe.t_ns = 40*([1:bins]-1); % 40 ns bins.pe
pe.us = 0.02;


windowSize = 20;
pe.maxabs = max(abs(pe.trace),[],2);
noco_abs = mean(pe.maxabs(1800:bins));
pe.maxabs = pe.maxabs ./ mean(pe.maxabs(1800:bins));
pe.maxdiff = max(abs(diff2(pe.trace)),[],2);
pe.maxdiff = pe.maxdiff ./ mean(pe.maxdiff(1800:bins));
pe.env = (pe.maxabs .* pe.maxdiff);
pe.var = var(pe.trace')';
pe.var = pe.var ./ mean(pe.var(1800:bins));
start = find(pe.var>0,1,'first');

pe.env = filter(ones(1,windowSize)/windowSize,1,pe.env);
pe.var = filter(ones(1,windowSize)/windowSize,1,pe.var);
pe.env = filter(ones(1,windowSize)/windowSize,1,pe.env);
pe.var = filter(ones(1,windowSize)/windowSize,1,pe.var);
pe.relvar = pe.var ./ pe.env;

% figure(1); 
% ax1(1) = subplot(2,1,1);
% plot([start:bins], pe.trace(start:bins,:), '-');
% title(['Raw traces from file: ' fname], 'interpreter','none'); 
% ylabel('amplitude')
% ax1(2) = subplot(2,1,2);
% plot([start:bins],pe.var(start:bins), '.m-');
% title(['Normalized variability as function of bin']); 
% xlabel('bin position')
% ylabel('variability')
% 
% linkaxes(ax1,'x');
% 
% figure(2); 
% ax2(1) = subplot(2,1,1);
% plot([start:bins], pe.trace(start:bins,:), '-');
% title(['Raw traces from file: ' fname], 'interpreter','none'); 
% ylabel('amplitude')
% ax2(2) = subplot(2,1,2);
% semilogy([start:bins],pe.maxabs(start:bins), 'r', [start:bins],pe.maxdiff(start:bins), 'g', [start:bins],pe.var(start:bins), 'm');
% title('variability sources')
% xlabel('bin position')
% ylabel('variability')
% legend('max amplitude','gradient','variability','location','southeast')
% linkaxes(ax2,'x');

figure; 
ax3(1) = subplot(2,1,1);
plt = plot([start:bins], pe.trace(start:bins,:), '-');
plt = recolor(plt,[1:profs]);
title(['Raw traces from file: ' fname], 'interpreter','none'); 
ylabel('amplitude')
ax3(2) = subplot(2,1,2);
plot([start:bins], pe.relvar(start:bins), 'k.')
title('renormalized variability')
xlabel('bin position')
ylabel('variability')
linkaxes(ax3,'x');
