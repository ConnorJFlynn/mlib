function MHz = prescale_generic_dtc(MHz);

dtc_fac = max(MHz(:))/14.5; % The value of 14.5 is about the max supported by the generic deadtime correction
MHz = (dtc_fac.*apply_generic_dtc(MHz./dtc_fac));