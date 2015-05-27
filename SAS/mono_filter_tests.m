% mono plus blocking filters mono 425

mono  = SAS_read_Albert_csv;
mono.darks = mean(mono.spec(mono.Shuttered_0==0,:)); 
mono.lights = mean(mono.spec(mono.Shuttered_0==1,:));
mono.sig = mono.lights - mono.darks; 
mono.max = max(mono.sig);
mono.nsig = mono.sig ./ max(mono.sig);

if sum(mono.Shuttered_0==0)>0&&sum(mono.Shuttered_0==1)>0
figure; 
 these = semilogy(mono.nm, mono.nsig, 'b-');
 legend('mono');
end


LP_below  = SAS_read_Albert_csv;
LP_below.darks = mean(LP_below.spec(LP_below.Shuttered_0==0,:)); 
LP_below.lights = mean(LP_below.spec(LP_below.Shuttered_0==1,:));
LP_below.sig = LP_below.lights - LP_below.darks;
LP_below.max = max(LP_below.sig);
LP_below.nsig = (LP_below.sig ./LP_below.max);
if sum(LP_below.Shuttered_0==0)>0&&sum(LP_below.Shuttered_0==1)>0
figure; 
 these = semilogy(LP_below.nm, LP_below.nsig, 'b-');
 legend('LP 395 nm (below)');
end

LP_filter = LP_below.max./mono.max;

LP_above  = SAS_read_Albert_csv;
LP_above.darks = mean(LP_above.spec(LP_above.Shuttered_0==0,:)); 
LP_above.lights = mean(LP_above.spec(LP_above.Shuttered_0==1,:));
LP_above.sig = LP_above.lights - LP_above.darks;
LP_above.nsig = (LP_above.sig./LP_below.max);
if sum(LP_above.Shuttered_0==0)>0&&sum(LP_above.Shuttered_0==1)>0
figure; 
 these = semilogy(LP_above.nm, LP_above.nsig, 'b-');
 legend('LP 455 nm (above)');
end

figure; 
 these = semilogy(mono.nm, mono.nsig - LP_below.nsig, '-', mono.nm, mono.nsig - LP_above.nsig, '-');
 legend('below 395', 'above 455');
 
 %%
 % mono plus blocking filters mono 425

mono  = SAS_read_Albert_csv;
mono.darks = mean(mono.spec(mono.Shuttered_0==0,:)); 
mono.lights = mean(mono.spec(mono.Shuttered_0==1,:));
mono.sig = mono.lights - mono.darks; 
mono.max = max(mono.sig);
mono.nsig = mono.sig ./ max(mono.sig);

if sum(mono.Shuttered_0==0)>0&&sum(mono.Shuttered_0==1)>0
figure; 
 these = semilogy(mono.nm, mono.nsig, 'b-');
 legend('mono 475');
end


LP_below  = SAS_read_Albert_csv;
LP_below.darks = mean(LP_below.spec(LP_below.Shuttered_0==0,:)); 
LP_below.lights = mean(LP_below.spec(LP_below.Shuttered_0==1,:));
LP_below.sig = LP_below.lights - LP_below.darks;
LP_below.max = max(LP_below.sig);
LP_below.nsig = (LP_below.sig ./LP_below.max);
if sum(LP_below.Shuttered_0==0)>0&&sum(LP_below.Shuttered_0==1)>0
figure; 
 these = semilogy(LP_below.nm, LP_below.nsig, 'b-');
 legend('LP 455 nm (below)');
end

LP_filter = LP_below.max./mono.max;

LP_above  = SAS_read_Albert_csv;
LP_above.darks = mean(LP_above.spec(LP_above.Shuttered_0==0,:)); 
LP_above.lights = mean(LP_above.spec(LP_above.Shuttered_0==1,:));
LP_above.sig = LP_above.lights - LP_above.darks;
LP_above.nsig = (LP_above.sig./LP_below.max);
if sum(LP_above.Shuttered_0==0)>0&&sum(LP_above.Shuttered_0==1)>0
figure; 
 these = semilogy(LP_above.nm, LP_above.nsig, 'b-');
 legend('LP 495 nm (above)');
end

figure; 
 these = semilogy(mono.nm, mono.nsig - LP_below.nsig, '-', mono.nm, mono.nsig - LP_above.nsig, '-');
 legend('below 455', 'above 495');

 
 
