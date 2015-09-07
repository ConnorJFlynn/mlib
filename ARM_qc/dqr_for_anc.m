function [dqr_] = dqr_for_anc(anc, dqr)

all_flds = fieldnames(dqr.all);
for n = length(dqr.all.id):-1:1
   if sum(anc.time>dqr.all.start_time(n)&anc.time<dqr.all.end_time(n))==0
      for f = 1:length(all_flds)
         fld = all_flds{f};
         dqr.all.(fld)(n) = [];
      end

   end
end
dqr_.all = dqr.all;
dqr_.vars = dqr.vars;
vars = fieldnames(dqr_.vars);
for v = 1:length(vars)
   var = vars{v};
   [ids,ij] = intersect(dqr_.all.id, dqr_.vars.(var).id);
      dqr_.ids_by_var.(var) = ij;
      if isempty(ij)
         dqr_.vars = rmfield(dqr_.vars, var);
         dqr_.ids_by_var = rmfield(dqr_.ids_by_var,var);
      end
end



return