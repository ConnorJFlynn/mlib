% Add height field to twpmplC1 low-res 
hires = ancload('F:\case_studies\fix_mpl_heigth\hires\twpmplC1.a1.19990810.071628.cdf');
%%
height = hires.vars.height; 
height.atts = rmfield(height.atts,'resolution');
height.atts = rmfield(height.atts,'precision');
height.atts = rmfield(height.atts,'accuracy');
height.atts = rmfield(height.atts,'accuracy_comment');
height.atts = rmfield(height.atts,'comment');
height.atts = rmfield(height.atts,'qc_methods');
height.atts = rmfield(height.atts,'equation_postfix');
height.data = single(([1:200]-.5).*.3)';
in_dir = ['F:\case_studies\fix_mpl_heigth\'];
out_dir = ['F:\case_studies\fix_mpl_heigth\fixed\'];
%%
files = dir([in_dir, 'twpmplC1.*.cdf']);
for m = length(files):-1:1
   disp(['Processing file #',num2str(m), ' :',files(m).name]);
   in = ancload([in_dir,files(m).name]);
   in.vars.height = height;
   in.vars.alt = hires.vars.alt;
  
   in.fname =[out_dir,files(m).name];
   in.clobber = true;
   in.quiet = true;
   if isfield(in.vars,'voltage_5__space__')
      in.vars.voltage_5 = in.vars.voltage_5__space__;
      in.vars = rmfield(in.vars,'voltage_5__space__');
   end
   status = ancsave(in);
   if status ~= 1
      disp('Something wrong?');
   end
   
end
   
    
    
    
    

%%