figure; ax(1) = subplot(2,1,1); plot(ttau.time_LST(ttau.nm>410&ttau.nm<420), ttau.airmass(ttau.nm>410&ttau.nm<420),'.',...
   all_legs.time_LST, all_legs.airmass, 'r.'); legend('airmass'); dynamicDateTicks
nn = find(all_legs2.wl>412 & all_legs2.wl<416);
ax(2) = subplot(2,1,2); plot(ttau.time_LST(ttau.nm>410&ttau.nm<420), ttau.aod(ttau.nm>410&ttau.nm<420),'.',...
   ttau.time_LST(ttau.nm>430&ttau.nm<450), ttau.aod(ttau.nm>430&ttau.nm<450),'.',...
   all_legs2.time_LST, all_legs2.aod_fit(:,nn),'r.'); legend('aod 415', 'aod 440'); dynamicDateTicks; linkaxes(ax,'x');

all_legs2 = load('D:\AGU_prep\all_legs2.mat');

nt = (ttau.nm>412&ttau.nm<416);
fields = fieldnames(ttau);
for f = 1:length(fields)
   field = fields{f};
   if length(ttau.(field))>3
   ttau_415.(field) = ttau.(field)(nt)
   else
      ttau_415.(field) = ttau.(field);
   end
end

save(['D:\AGU_prep\ttau_415.mat'],'-struct', 'ttau_415');
[aint, tina] = nearest(all_legs2.time_LST, ttau_415.time_LST);

figure;  plot(ttau_415.time_LST(tina), ttau_415.aod(tina),'.',...
   all_legs2.time_LST(aint), all_legs2.aod_fit(aint,nn),'r.');  dynamicDateTicks; 
lg = legend('ttau_415', 'all_legs'); set(lg,'interp','none')

good_i = find(abs(ttau_415.aod(tina) -all_legs2.aod_fit(aint,nn))<.01);
% 95% within 0.02
% 75% within 0.01
length(unique(floor(all_legs2.time_LST(aint(good_i)))))
length(unique(floor(all_legs2.time_LST)))

% Of those good points (good days), how many have aod_415 and sza yielding low error
% according to LUT?

% Another crucial check would be to assess how well modeled and measured zenrad
% agree for one of those days.

