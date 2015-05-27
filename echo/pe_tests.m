% First run this small code block to read in a profile known to have a zero
% bed depth.  Populate the arguments used as input to the next function.
pe = read_pe_raw;
ins.no_bed = mean(pe.trace,2);
ins.slab_win = 30;
pe_no_bed = mean(pe.trace,2);
save pe_no_bed.mat pe_no_bed

%%
% This function "proc_pe_slab2" (stands for Process PulseEcho Slab ver 2)
% prompts for another pulse-echo data file and does all the preprocessing
% and analysis to determine bed depth.

pe2 = proc_pe_slab2;
%%
