function pe = read_pe3;
% Reads a pulse-echo binary data file, 2048 bins as 8-byte "double"
bins = 2048;
pe.bin = [1:bins];

[fid,fname,pname] = getfile('*.bin','echo');
status = fseek(fid,0,1);
profs = ftell(fid)/(8*bins);
status = fseek(fid,0,-1);

pe.raw = fread(fid,[bins,profs],'double');
fclose(fid);
% pe.t_ns = 40*([1:bins]-1); % 40 ns bins.

diffraw = diff(pe.raw);
peaks = length(find((diffraw(1:end-1,1)>0 & diffraw(2:end,1)<0) |(diffraw(1:end-1,1)<0 & diffraw(2:end,1)>0)));
% For each profile, find zero-crossing points.
zc = length(find((pe.raw(1:end-1,1)>0 & pe.raw(2:end,1)<0) |(pe.raw(1:end-1,1)<0 & pe.raw(2:end,1)>0)));
pe.zc = zeros([zc,profs]);
pe.avgarea = zeros([zc,profs]);
for p = 1:profs
   binsum = 0;
   n = 0;
   found = 0;
   first = true;
   b = 1;
   while (found<zc) && (b<bins)
      b = b+1;
      n = n+1;
      binsum = binsum + pe.raw(b,p);
      if ((pe.raw(b-1,p)>0 & pe.raw(b,p)<0) |(pe.raw(b-1,p)<0 & pe.raw(b,p)>0))
         
         if first
            first=false;
            binsum = 0;
         else
            found = found+1;
            %use these two points to define a line and compute zero crossing
            x1 = b-1; x2 = b; y1 = pe.raw(b-1,p); y2 = pe.raw(b,p);
            %          y1-y0 / x1-x0 = (y2-y1)./(x2-x1);
            %          (y1).*(x2-x1)./(y2-y1) = x1 -x0;
            x0 = x1 - (y1).*(x2-x1)./(y2-y1);
            pe.zc(found,p) = x0;
            pe.n(found,p) = n;
            pe.avgarea(found,p) = binsum./n;
            n = 0;
            binsum = 0;
         end
      end
      
   end %at last bin, done with this profile
end % end of profs loop

zc = find((pe.raw(1:end-1,1)>0 & pe.raw(2:end,1)<0) |(pe.raw(1:end-1,1)<0 & pe.raw(2:end,1)>0));
mp = floor((zc(1:end-1)+zc(2:end))./2);

figure; plot(pe.bin, pe.raw(:,1), 'r-', pe.bin(zc), pe.raw(zc,1), 'b.', pe.bin(mp), pe.raw(mp,1), 'go');
for t = profs:-1:1
   [P,S,MU] = polyfit(r,pe.raw(r,t),2);
   pe.shift(t) = MU(1)+roots([2*P(1),P(2)]);
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
figure(3); 
ax2(1) = subplot(3,1,1);
plot([351:2048], pe.shifted(351:end,:), '-', [351:2048], mean(pe.winabs([351:2048],:),2),'k.')
ax2(2) = subplot(3,1,2);
plot([351:2048], pe.varshifted(351:end),'r-', [351:2048], (1/50)*pe.relvar(351:end),'b-');
ax2(3) = subplot(3,1,3); 
plot([351:2048], pe.varwin(351:end),'r-', [351:2048], (1/50)*pe.relwin(351:end),'b-');

linkaxes(ax2,'x')