function hsrl = rd_gvhsrl(in_file)

if ~isavar('in_file')||~isafile(in_file)
   in_file = getfullname('*GVHSRL*.nc','GVHSRL');
end
hsrl = anc_load(in_file);

hsrl.time = datenum(sscanf(hsrl.vatts.time.units,'seconds since %s'),'yyyy-mm-ddTHH:MM:SSZ') + double(hsrl.vdata.time)./(24*60*60);


end