function [ict_data ict_meta] = rd_ict(infile)
%[ict_data ict_meta] = rd_ict(infile)
while ~exist('infile','var')||~exist(infile,'file')
    infile = getfullname('*.ict','icart','Select ICARTT file');
end
fid  = fopen(infile);
line = fgetl(fid);
line = textscan(line,'%d %d', 'delimiter',',');
ict_meta.header_rows = line{1};
ict_meta.icartt_version = line{2};
ict_meta.PI = fgetl(fid);
ict_meta.affiliation = fgetl(fid);
ict_meta.data_source_description = fgetl(fid);
ict_meta.mission = fgetl(fid);
line = fgetl(fid); 
line = textscan(line,'%d %d', 'delimiter',',');
ict.file_N(1) = line{1}; ict.file_N(2) = line{2};
V = textscan(fgetl(fid),'%f','delimiter',',');
V = V{:}';
ict_meta.date_taken = V(1:3);
ict_meta.date_submitted = V(4:6);
ict_meta.interval = sscanf(fgetl(fid),'%d');
line = fgetl(fid); line = textscan(line,'%s %s','delimiter',',');
ict_meta.rec_var = line{1};
ict_meta.N_vars = sscanf(fgetl(fid),'%d');
fmt_str = ['%f',repmat(',%f',[1,ict_meta.N_vars])];
ict_meta.scale_factors = sscanf(fgetl(fid),fmt_str);
ict_meta.missing = sscanf(fgetl(fid),fmt_str);
for v = 1:ict_meta.N_vars
    line = fgetl(fid);
    v_str = textscan(line, '%s %s %s', 'delimiter',',');
    ict_meta.vars.(legalize_fieldname(char(v_str{1}))).units = char(v_str{2});
    if ~isempty(v_str{3})
        ict_meta.vars.(legalize_fieldname(char(v_str{1}))).long_name = char(v_str{3});
    end
end
ict_meta.special_comments = sscanf(fgetl(fid),'%d');
for c = 1:ict_meta.special_comments
    ict_meta.special_comment(c) = {fgetl(fid)};
end
ict_meta.comments = sscanf(fgetl(fid),'%d');
for c = 1:ict_meta.comments-1
    ict_meta.comment(c) = {fgetl(fid)};
end
line = fgetl(fid);
ict_meta.header_row = textscan(line,'%s','delimiter',',');
ict_meta.header_row = ict_meta.header_row{:};
fmt_str = ['%f ', repmat('%f ',[1,ict_meta.N_vars])];
raw = textscan(fid,fmt_str,'delimiter',',');
fclose(fid);
ict_data.time = datenum(ict_meta.date_taken)+raw{1}./(24*60*60);
for N = 1:ict_meta.N_vars+1
    ict_data.(legalize_fieldname(ict_meta.header_row{N})) = raw{N};
end
return