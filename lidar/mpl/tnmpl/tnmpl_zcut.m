function mpl = tnmpl_zcut(mpl);
% mpl = tnmpl_zcut(mpl);
% This function reduces the range of saved tnmpl data to only 20 km.
mpl = rmfield(mpl, 'rawcts');
mpl.range = mpl.range(mpl.r.lte_20);
mpl.prof = mpl.prof(mpl.r.lte_20,:);
mpl.noise_MHz = mpl.noise_MHz(mpl.r.lte_20,:);
mpl.statics.maxAltitude = 20;

r.lte_5 = find((mpl.range>=0)&(mpl.range<=5));
r.lte_10 = find((mpl.range>=0)&(mpl.range<=10));
r.lte_15 = find((mpl.range>=0)&(mpl.range<=15));
r.lte_20 = find((mpl.range>=0)&(mpl.range<=20));
mpl.r = r;