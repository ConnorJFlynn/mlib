% Hydrogen sensing, raman scattering

rl = anclink;

vars = fieldnames(rl.vars);


%%
for v = 1:length(vars)
   if (any(strcmp(rl.vars.(vars{v}).dims,'high_bins')))||~isempty(findstr(vars{v},'high'))||~isempty(findstr(vars{v},'temp'))
      rl.vars = rmfield(rl.vars, vars{v});
   end
end
%
vars2 = fieldnames(rl.vars);

%%
rl = ancloadvardata(rl);
%%
r.bg = [1:370];
range = 7.5.*([1:1500]-380)';
%%
tind = 2000;
figure; 

semilogy(range,double(rl.vars.nitrogen_counts_low.data(:,tind)-mean(rl.vars.nitrogen_counts_low.data([1:370],tind))),'b-'); zoom('on')
xlabel('range (m)')
ylabel('raw N2 counts')
%%

tind = 2000;
figure; 
s(1) = subplot(2,1,1);
semilogy(range,double(rl.vars.nitrogen_analog_low.data(:,tind)-mean(rl.vars.nitrogen_analog_low.data([1:370],tind))),'b-',...
   range,double(rl.vars.water_analog_low.data(:,tind)-mean(rl.vars.water_analog_low.data([1:370],tind))),'r-'); zoom('on')
s(2) = subplot(2,1,2);
plot(range,double(rl.vars.water_analog_low.data(:,tind)-mean(rl.vars.water_analog_low.data([1:370],tind)))./...
   double(rl.vars.nitrogen_analog_low.data(:,tind)-mean(rl.vars.nitrogen_analog_low.data([1:370],tind))),'k-'); zoom('on');
linkaxes(s,'x')
%%
figure; 
s(1) = subplot(2,1,1);
semilogy(range,(range.^2) .*double(rl.vars.nitrogen_counts_low.data(:,tind)-mean(rl.vars.nitrogen_counts_low.data([1:370],tind))),'b-',...
   range,(range.^2) .*double(rl.vars.water_counts_low.data(:,tind)-mean(rl.vars.water_counts_low.data([1:370],tind))),'r-'); zoom('on')
s(2) = subplot(2,1,2);
semilogy(range,(range.^2) .*double(rl.vars.nitrogen_analog_low.data(:,tind)-mean(rl.vars.nitrogen_analog_low.data([1:370],tind))),'b-',...
   range,(range.^2) .*double(rl.vars.water_analog_low.data(:,tind)-mean(rl.vars.water_analog_low.data([1:370],tind))),'r-'); zoom('on');
linkaxes(s,'x')
%%
figure; plot(serial2Hh(rl.time), mean(rl.vars.nitrogen_analog_low.data(r.bg,:),1),'-o')
%%