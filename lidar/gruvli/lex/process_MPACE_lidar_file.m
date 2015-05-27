
function [status] = process_MPACE_lidar_file(in_filenm, out_filenm);
% This procedure requires as input an input file name and an output file name.

[old_cdfid] = ncmex('OPEN', in_filenm, 'NC_NOWRITE');
%disp(['old_fid =' num2str(old_cdfid)]);
[new_cdfid] = ncmex('CREATE', out_filenm, 'NC_CLOBBER');
%disp(['new_fid =' num2str(new_cdfid)]);
if (old_cdfid)
    if (new_cdfid)
        disp(['Processing...']);
       status = mpace_reformat(old_cdfid, new_cdfid, in_filenm);
       status = ncmex('sync', new_cdfid);
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