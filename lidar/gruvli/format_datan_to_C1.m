
function [status] = format_datan_to_C1(in_filenm, out_filenm);
% This procedure requires as input an input file name and an output file name.
% The input file (of data_n level) is formatted to C1b

[old_cdfid] = ncmex('OPEN', in_filenm, 'NC_NOWRITE');
%disp(['old_fid =' num2str(old_cdfid)]);
[new_cdfid] = ncmex('CREATE', out_filenm, 'NC_CLOBBER');
%disp(['new_fid =' num2str(new_cdfid)]);
if (old_cdfid)
    if (new_cdfid)
        disp(['Re-formatting to C1...']);
% C1 is for Crystal data up to 2002-07-10
%         status = data_format_C1(old_cdfid, new_cdfid);
%         status = C1_corrs(old_cdfid, new_cdfid);
% C1a is for Crystal data on 2002-7-11 with 2000 bins
       status = data_format_C1a(old_cdfid, new_cdfid);
       status = C1a_corrs(old_cdfid, new_cdfid);
% C1b_corrs is for Crystal data on 2002-7-11 with 4000 bins
%        status = data_format_C1a(old_cdfid, new_cdfid);
%        status = C1b_corrs(old_cdfid, new_cdfid);
        [status] = ncmex('close',new_cdfid);
%        disp(['Closing new file.']);
    else
        disp(['There was a problem opening the output file in define mode.']);
    end;
%    disp(['Closing existing file.']);
    [status] = ncmex('close',old_cdfid);
else
    disp(['There was a problem opening the input file.']);
end;