function delta_f_ = delta_f(delta_a, delta_s, g)

% # filter optical depth
% # delta_f = (F_a0 *delta_a + F_s *delta_s )* F_f
    result_F_a = F_a0(delta_a, g);          %# calibration function for ssa=0
    result_F_s = F_s(delta_s, g);     %      # calibration function for ssa=1
    result_F_f = F_f(delta_a, delta_s, g); %# cross term
    if(~isnan(result_F_a) && ~isnan(result_F_s) && ~isnan(result_F_f))
        delta_f_ = (result_F_a.*delta_a+result_F_s.*delta_s).*result_F_f;
        status = 1;
    else
        delta_f_ = NaN;
        status =0;
    end

return