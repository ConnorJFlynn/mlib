function pas = pass_siftdown(pass)
% Identify "bad" values based on instrument QC and set to Bab, Bsp to NaN
fields = fieldnames(pass.vdata);


% Identify contiguous "blocks" or normal operation
samp_flag = pass.vdata.sample_measurement_flag;

block_start = findstr(samp_flag,int32([repmat([1],[1,15]),repmat([0],[1,59])]));

blk = length(block_start);
[pas_, pass] = anc_sift(pass,[(block_start(blk):block_start(blk)+73)]);
pas_ = anc_sift(pas_,pas_.vdata.sample_measurement_flag==0);
pas = anc_downsample_nomiss(pas_,length(pas_.time));

for blk = length(block_start)-1:-1:1
[pas_, pass] = anc_sift(pass,[(block_start(blk):block_start(blk)+73)]);
pas_ = anc_sift(pas_,pas_.vdata.sample_measurement_flag==0);
pas = anc_cat(anc_downsample_nomiss(pas_,length(pas_.time)),pas);
disp(blk)
end


end