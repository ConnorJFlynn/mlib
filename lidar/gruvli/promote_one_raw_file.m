
function [status] = promote_one_raw_file(in_filenm, out_filenm);
% This procedure requires as input a raw input file name and an output file name.
% The input 'raw' file is promoted by addition of data_level, history, rearranging,
% and so on using subsequent internal functions raw_to_data0, data_0_to_1, data_1_to_3

[old_cdfid] = ncmex('OPEN', in_filenm, 'NC_NOWRITE');
[new_cdfid] = ncmex('CREATE', out_filenm, 'NC_CLOBBER');
if (old_cdfid)
    if (new_cdfid)
        disp(['Adding data_level, history, and copying structure of input file.']);
        status = raw_to_data0(old_cdfid, new_cdfid);
        disp('Rearranging...');
        status = data_0_to_1(new_cdfid);
        disp('Converting to counts per second.');
        status = data_1_to_3(new_cdfid);
        disp('Apply deadtime correction based on max detected counts.');
        det_A_dt = 2.04e-8;
        det_B_dt = 2.14e-8;
        status = grli_dtc_maxcts(new_cdfid, det_A_dt, det_B_dt);
        disp('Apply base corrections, derivative products.');
        status = grli_base_corr(new_cdfid, 1);
%        disp('Apply range-shape corrections.');
%        status = grli_range_shape(new_cdfid);

        [status] = ncmex('close',new_cdfid);
    else
        disp(['There was a problem opening the output file in define mode.']);
    end;
    [status] = ncmex('close',old_cdfid);
else
    disp(['There was a problem opening the input file.']);
end;