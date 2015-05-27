    function am = airmass_mol(el)
        % am = airmass_mol(el) from sunae
        %  elevation given in degrees */
        zr = (pi./180) .* (90.0 - el);
        am =  1.0./(cos(zr) + 0.50572.*(6.07995 + el).^-1.6364);
        am(el<0) = -1;
 return
