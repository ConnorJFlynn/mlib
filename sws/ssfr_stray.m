function [vis, nir] = ssfr_stray

vis = rd_SAS_raw;
nir = rd_SAS_raw([vis.pname, strrep(vis.fname{:},'vis','nir')]);
darks = find(nir.Shutter_open_TF==0);
darks = darks(2:end-1);
dark_vis = mean(vis.spec(darks,:));dark_nir = mean(nir.spec(darks,:));
vis.sig = vis.spec-ones(size(nir.time))*dark_vis;
nir.sig = nir.spec-ones(size(nir.time))*dark_nir;

figure;
subplot(2,1,1); these = plot(vis.lambda, vis.sig,'-');
recolor(these,serial2hs(nir.time));
subplot(2,1,2); these = plot(nir.lambda, nir.sig,'-');
recolor(these, serial2hs(nir.time));

for t = length(vis.time):-1:1
    vis.totsig(t) = trapz(vis.lambda(100:150),vis.sig(t,100:150));
    nir.totsig(t) = trapz(nir.lambda(110:160),nir.sig(t,110:160));
end
vis.totsig = vis.totsig'; nir.totsig = nir.totsig';
figure;
ss(1) = subplot(2,1,1);
plot(serial2hs(vis.time), vis.totsig,'o');
legend('vis');
ss(2) = subplot(2,1,2);
plot(serial2hs(vis.time), nir.totsig,'ro');
legend('nir');
linkaxes(ss,'x');
done = false; shaded_vis = false(size(vis.time))
while ~done
    ok = menu('Select shaded VIS points to use','Add these','Done');
    if ok==1
        v = axis;
        shaded_vis = shaded_vis | (serial2hs(vis.time)>v(1) & serial2hs(vis.time)<v(2)...
            & vis.totsig>v(3) & vis.totsig<v(4));
    else
        done = true;
    end
end
done = false; shaded_nir = false(size(vis.time))
while ~done
    ok = menu('Select shaded NIR points to use','Add these','OK');
    if ok==1
        v = axis;
        shaded_nir = shaded_nir |(serial2hs(nir.time)>v(1) & serial2hs(nir.time)<v(2)...
            & nir.totsig>v(3) & nir.totsig<v(4));
    else
        done = true;
        
    end
end
shaded = shaded_vis & shaded_nir;
done = false; unshaded_vis = false(size(vis.time))
while ~done
    ok = menu('Select unshaded VIS points to use','Add these','Done');
    if ok==1
        v = axis;
        unshaded_vis = unshaded_vis | (serial2hs(vis.time)>v(1) & serial2hs(vis.time)<v(2)...
            & vis.totsig>v(3) & vis.totsig<v(4));
    else
        done = true;
    end
end
done = false; unshaded_nir = false(size(vis.time))
while ~done
    ok = menu('Select unshaded NIR points to use','Add these','OK');
    if ok==1
        v = axis;
        unshaded_nir = unshaded_nir |(serial2hs(nir.time)>v(1) & serial2hs(nir.time)<v(2)...
            & nir.totsig>v(3) & nir.totsig<v(4));
    else
        done = true;
        
    end
end
unshaded = unshaded_vis & unshaded_nir;

figure; plot(vis.lambda, 100.*(mean(vis.sig(unshaded,:))-mean(vis.sig(shaded,:)))./mean(vis.sig(shaded,:)),'r-',...
   nir.lambda, 100.*(mean(nir.sig(unshaded,:))-mean(nir.sig(shaded,:)))./mean(nir.sig(shaded,:)),'k-' )

return