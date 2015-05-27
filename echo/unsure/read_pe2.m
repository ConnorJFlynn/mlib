function pe = read_pe;
% Reads a pulse-echo binary data file, 2048 bins as 8-byte "double"
[fid,fname,pname] = getfile('*.bin','echo');
bins = 2048;
pe.bins = [1:bins];
status = fseek(fid,0,1);
profs = ftell(fid)/(8*bins);
status = fseek(fid,0,-1);
pe.raw = fread(fid,[bins,profs],'double');
fclose(fid);

% Find relative shifts in the traces at some discrete points.  Start with
% the relative maxima between 365 and 375.
% First find all points from the adjacent trace
r = [387:397]';
for t = profs:-1:1
   [P,S,MU] = polyfit(r,pe.raw(r,t),2);
%    pe.shift(t) = MU(1)+roots([2*P(1),P(2)]);
   pe.shift(t) = MU(1)+MU(2)*roots([2*P(1),P(2)]);
end
pe.shift = pe.shift - mean(pe.shift);
pe.x = (([0:2047]'*(ones([1,profs]))-ones([bins,1])*pe.shift));
% figure(3); 
% ax(1) = subplot(2,1,1); 
% plots=plot([1:bins],pe.raw(:,1:10));
% plots = recolor(plots,pe.shift(1:10)); 
% ax(2) = subplot(2,1,2); plots = plot(pe.x(:,1:10), pe.raw(:,1:10));
% plots = recolor(plots,pe.shift(1:10)); 
% 
% linkaxes(ax,'xy')
windowSize = 20;
pe.trace = zeros(size(pe.raw));
for p = profs:-1:1
   pe.trace(351:bins,p) = interp1(pe.x(351:end,p), pe.raw(351:end,p), [351:bins],'linear');
end


windowSize = 20;
pe.maxabs = max(abs(pe.trace),[],2);
noco_abs = mean(pe.maxabs(1800:bins));
pe.maxabs = pe.maxabs ./ mean(pe.maxabs(1800:bins));
pe.maxdiff = max(abs(diff2(pe.trace)),[],2);
pe.maxdiff = pe.maxdiff ./ mean(pe.maxdiff(1800:bins));
pe.env = (pe.maxabs .* pe.maxdiff);
pe.var = var(pe.trace')';
nans = isNaN(pe.var);
% pe.var(nans)= 0;
pe.var = pe.var ./ mean(pe.var(1800:2000));
start = find(pe.var>0,1,'first');

pe.env = filter(ones(1,windowSize)/windowSize,1,pe.env);
pe.var = filter(ones(1,windowSize)/windowSize,1,pe.var);
pe.env = filter(ones(1,windowSize)/windowSize,1,pe.env);
pe.var = filter(ones(1,windowSize)/windowSize,1,pe.var);
pe.relvar = pe.var ./ pe.env;

% figure(4); 
% ax(1) = subplot(2,1,1); plot([start:bins], pe.trace(start:bins,:), '-',[start:bins], pe.env(start:bins).*noco_abs, 'r')
% ax(2) = subplot(2,1,2); plot([start:bins], pe.relvar(start:bins), 'k.');
% linkaxes(ax,'x');
figure; 
ax3(1) = subplot(2,1,1);
plot([start:bins], pe.trace(start:bins,:), '-');
title(['Raw traces from file: ' fname], 'interpreter','none'); 
ylabel('amplitude')
ax3(2) = subplot(2,1,2);
plot([start:bins], pe.relvar(start:bins), 'k.')
title('renormalized variability')
xlabel('bin position')
ylabel('variability')
linkaxes(ax3,'x');