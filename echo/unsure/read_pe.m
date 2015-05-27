function pe = read_pe;
% Reads a pulse-echo binary data file, 2048 bins as 8-byte "double"
[fid,fname,pname] = getfile('*.bin','echo');
status = fseek(fid,0,1);
profs = ftell(fid)/(8*2048);
status = fseek(fid,0,-1);
pe.raw = fread(fid,[2048,profs],'double');
fclose(fid);

% Find relative shifts in the traces at some discrete points.  Start with
% the relative maxima between 365 and 375.
% First find all points from the adjacent trace
r = [387:397]';
for t = 1:profs
   [P,S,MU] = polyfit(r,pe.raw(r,t),2);
   pe.shift(t) = MU(1)+MU(2)*roots([2*P(1),P(2)])
%       [P,S] = polyfit(r,pe.raw(r,t),2);
%    pe.shift(t) = roots([2*P(1),P(2)])
end
pe.shift = pe.shift - mean(pe.shift);
pe.x = (([0:2047]'*(ones([1,profs]))-ones([2048,1])*pe.shift));
figure(1); 
ax(1) = subplot(2,1,1); 
plots=plot([1:2048],pe.raw(:,1:10));
plots = recolor(plots,pe.shift(1:10)); 
ax(2) = subplot(2,1,2); plots = plot(pe.x(:,1:10), pe.raw(:,1:10));
plots = recolor(plots,pe.shift(1:10)); 

linkaxes(ax,'xy')
windowSize = 20;
for p = profs:-1:1
   pe.shifted(351:2048,p) = interp1(pe.x(351:end,p), pe.raw(351:end,p), [351:2048],'linear');
   pe.absshifted(351:2048,p)=filter(ones(1,windowSize)/windowSize,1,abs(pe.shifted(351:end,p)));
   pe.winabs(351:2048,p) = filter(ones(1,windowSize)/windowSize,1,abs(pe.shifted(351:2048,p)));
%    figure(2); plot([351:2048],pe.shifted(351:2048,p),'b',[351:2048],abs(pe.shifted(351:end,p)),'g',[351:2048],pe.winabs(351:2048,p),'r')
%    tst = fft(pe.raw(351:(351+255),1));
end
pe.varshifted = var(pe.shifted')';
pe.varwin = var(pe.winabs')';

pe.relvar = pe.varshifted ./ mean(pe.winabs,2);
pe.relwin = pe.varwin ./ mean(pe.winabs,2);
[pe.all_x, inds] = sort(pe.x(:));
pe.I = pe.raw(inds);

clear ax2;
figure(2); 
ax2(1) = subplot(3,1,1);
plot([351:2048], pe.shifted(351:end,:), '-', [351:2048], mean(pe.winabs([351:2048],:),2),'k.')
ax2(2) = subplot(3,1,2);
plot([351:2048], pe.varshifted(351:end),'r-', [351:2048], (1/50)*pe.relvar(351:end),'b-');
ax2(3) = subplot(3,1,3); 
plot([351:2048], pe.varwin(351:end),'r-', [351:2048], (1/50)*pe.relwin(351:end),'b-');

linkaxes(ax2,'x')