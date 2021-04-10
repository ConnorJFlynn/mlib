%%

% take listing of all *.mat files
% From each, read the head_id and logger_id fields, concat to make unique

mats = dir('F:\case_studies\mfrsr_ids\*.mat');

mfr = load([mats(1).folder, filesep,mats(1).name]); 
field = fieldnames(mfr);
head_id = unique(mfr.(char(field)).vdata.head_id);   
logger_id = unique(mfr.(char(field)).vdata.logger_id); 

for m = 2:length(mats)
    mfr = load([mats(m).folder, filesep,mats(m).name]);
    field = fieldnames(mfr);
    head_id = unique([head_id, mfr.(char(field)).vdata.head_id]);
    logger_id = unique([logger_id, mfr.(char(field)).vdata.logger_id]);
    disp(['Done with ',num2str(m)])
end

head_id(head_id<=0) = [];
logger_id(logger_id<=0) = [];

dec2hex(head_id)
dec2hex(logger_id)