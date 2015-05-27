function aux = auxcat;
%%

aux_path = ['C:\case_studies\dust\nimaosauxM1.a1\'];
aux_dir = dir([aux_path,'*.cdf.v0']);
for a = 1:length(aux_dir)
   disp(aux_dir(a).name);
   if ~exist('aux','var')
      aux = ancload([aux_path, aux_dir(a).name]);
   else
      aux = anccat(aux,ancload([aux_path, aux_dir(a).name]));
   end
end
%%
aux.fname = ['C:\case_studies\dust\nimaosauxM1.a1\nimaux.cdf'];
ancsave(aux);