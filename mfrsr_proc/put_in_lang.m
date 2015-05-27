function [Langley, lang_out] = put_in_lang(mfr, lang_out, pts, L, Langley);
% [Langley, lang_out] = put_in_lang(mfr, lang_out, pts);
% Carries out Langley for selected points in pts for each mfr channel
% Places results in lang_out ancstruct as well as in running Langley structure

for ch = {'broadband', 'filter1', 'filter2', 'filter3', ...
      'filter4', 'filter5', 'filter6'}
   V = mfr.vars.(['cordirnorm_',char(ch)]).data .* mfr.vars.r_au.data.^2;
   nulls = find((mfr.vars.(['cordirnorm_',char(ch)]).data<=0)|(mfr.vars.zen_angle.data>=90));
   V(nulls) = NaN;
   [P,S] = polyfit(mfr.vars.airmass.data(pts), real(log(V(pts))), 1);
   [Yo,DELTA] = polyval(P,0,S);
   Vo = exp(Yo);
   error_fraction = ((exp(Yo+DELTA))-(exp(Yo-DELTA)))/Vo;
   tau = -P(1);
   lang_out.vars.(['tau_',char(ch)]).data(L) = tau;
   lang_out.vars.(['Vo_',char(ch)]).data(L) = Vo;
   lang_out.vars.(['error_fit_',char(ch)]).data(L) = error_fraction;
   lang_out.vars.(['number_pts_',char(ch)]).data(L) = length(pts);
   if findstr(char(ch),'filter2')
      Langley.time(L) = mean(mfr.time(pts));
      Langley.Vo(L) = Vo;
      Langley.tau(L) = tau;
      Langley.error_fraction(L) = error_fraction;
      Langley.PolyCoefs(L,:) = P;
      Langley.ErrorStats(L) = S;
      Langley.nSamples(L) = length(pts);
   end
end
lang_out.time(L) = mean(mfr.time(pts));
%lang_out.vars.angstrom_exponent_870_500 = lang_out.vars.barnard_angstrom_exponent;
%lang_out.vars.angstrom_exponent_fit = lang_out.vars.barnard_angstrom_exponent;

%             Langley.time(L) = mean(mfr.time(AM2));
%             Langley.Vo2(L) = Vo2;
%             Langley.error_fraction2(L) = error_fraction2;
%             Langley.PolyCoefs2(L,:) = P2;
%             Langley.ErrorStats2(L) = S2;
%             Langley.nSamples2(L) = length(AM2);



