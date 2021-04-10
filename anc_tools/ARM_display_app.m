function ARM_display_app(anc)
if isempty(who('anc'))
  [~] = ARM_display;
else
  [~] = ARM_display(anc);
end


return