function pyr= rdpyrnet(infile)

if ~isavar('infile')||~isafile(infile)
   infile = getfullname('*pyrnet*nc','s2vsr','Select S2VSR nc file');
end

pyr = anc_load(infile);

pyr.time = datenum(sscanf(pyr.vatts.time.units, 'seconds since %s'),'yyyy-mm-dd')+double(pyr.vdata.time./(60*60*24));

figure; plot(pyr.time, pyr.vdata.ghi,'.'); dynamicDateTicks

end


