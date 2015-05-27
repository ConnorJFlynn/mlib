function Langley = langleys(arg);
% Langley = Langleys(arg);
% Cycle through mfrsr data files to compute a robust set of Langleys
% and corresponding Vo values.
% optional argument arg has following required elements:
% % arg.in_lang.pname
% % arg.in_lang.fname
% % arg.in_mfrsr.pname
% % arg.in_mfrsr.fmask
% % arg.swanal.pname
% % arg.swanal.fmask
% % arg.out_lang.Vodir
% % arg.out_lang.langplot
% % arg.out_lang.goodpng
% % arg.out_lang.badpng
% % arg.out_lang.gstem

if exist('arg','var')
   in_lang = arg.in_lang;
   in_mfrsr = arg.in_mfrsr;
   in_swanal = arg.in_swanal;
   out_lang = arg.out_lang;
   airmass = arg.airmass;
else
   in_lang.pname = ['D:\case_studies\sgpmfrsrC1\b1\'];
   in_lang.fname = ['sgpmfrsrC1.b1.20050729.000000.nc'];
   in_mfrsr.pname = ['D:\case_studies\sgpmfrsrC1\b1\'];
   in_mfrsr.fmask = ['sgpmfrsrC1.b1.*.nc'];
   in_swanal.pname = ['D:\case_studies\sgp1swfanal\'];
   in_swanal.fmask = ['sgp1swfanal*'];
   out_lang.Vodir = '';
   out_lang.langplot ='';
   out_lang.goodpng = ['D:\case_studies\sgpmfrsrC1\Langleys\'];
   out_lang.badpng = ['D:\case_studies\sgpmfrsrC1\Langleys\bad\'];
   out_lang.gstem = ['sgpmfrsrC1.'];
   AM_bounds = [2,5];
end

mfr = ancload([in_lang.pname, in_lang.fname]);
disp(['Initial Langley: ', datestr(mfr.time(1), 'YYYY-mm-DD')]);
lang_out = anclink(arg.out_lang.template);
lang_out = cleanup_lang_out(lang_out);

%
nulls = find(mfr.vars.cordn_filter2.data<=0);
AM = find((mfr.vars.az_angle.data < 180)&(mfr.vars.airmass.data>=airmass(1))&(mfr.vars.airmass.data<=airmass(2)));
V = mfr.vars.cordn_filter2.data .* mfr.vars.r_au.data.^2;
V(nulls) = NaN;
[P,S] = polyfit(mfr.vars.airmass.data(AM), real(log(V(AM))), 1);
[Y,DELTA] = polyval(P,0,S);
Vo = exp(Y);
disp(['Vo = ',num2str(Vo), ' +/- ', num2str(100*((exp(Y+DELTA))-(exp(Y-DELTA)))/Vo),'%, tau = ',num2str(-P(1))])
disp('.')

%%
L = 0;
file_list = dir([in_mfrsr.pname, in_mfrsr.fmask]);
for f =1:length(file_list)
   clear mfr
   disp(['Processing file #', num2str(f), ' of ', num2str(length(file_list)), ' : ', file_list(f).name]);
   mfr = ancload([in_mfrsr.pname, file_list(f).name]);
   %%
   nulls = find(mfr.vars.cordn_filter2.data<=0);
   V = mfr.vars.cordn_filter2.data .* mfr.vars.r_au.data.^2;
   V(nulls) = NaN;
   tau = (log(Vo) - log(V)) .* mfr.vars.cza.data;
   [aero, eps] = alex_screen(mfr.time, tau);

   sw_file = dir([in_swanal.pname, in_swanal.fmask,datestr(mfr.time(1),'YYYYmmDD'), '*.cdf']);
   if length(sw_file)>0
      swanal = ancload([in_swanal.pname, sw_file(1).name]);
      [mfr.vars.clear_sky] = swanal.vars.flag_clearsky_detection;
      mfr.vars.clear_sky.data = flagor(swanal.time, swanal.vars.flag_clearsky_detection.data, mfr.time);
      clr = mfr.vars.clear_sky.data > .5;
   else
      disp(['   No swfwanal file found for ', datestr(mfr.time(1),'YYYY-mm-DD')]);
      disp(['   Proceeding as though clear.']);
      clr = true;
   end
   %Set clr to true if NaN
   NaNs = isnan(clr);
   clr(NaNs) = true;

   AM = find((mfr.vars.az_angle.data < 180)&(mfr.vars.airmass.data>airmass(1))...
      &(mfr.vars.airmass.data<airmass(2)));
   if length(AM) < 20
      disp(['   BAD LANGLEY: Less than 20 raw samples'])
      disp(['   BAD LANGLEY DAY: ',datestr(mfr.time(1), 'YYYY-mm-DD')]);
      figure(5);
      title(['Bad Langley:', datestr(mfr.time(1), 'YYYY-mm-DD'), 'too few samples']);
      ylabel('log(V)');
      xlabel('airmass');
      %       out_lang.badpng = ['D:\case_studies\sgpmfrsrC1\Langleys\bad\'];
      gfile = [out_lang.gstem,datestr(mfr.time(1),'YYYYmmDD'),'.langplot.png'];
      print('-dpng', [out_lang.badpng,gfile])
   else
      AM2 = find((mfr.vars.az_angle.data < 180)&(mfr.vars.airmass.data>airmass(1))...
         &(mfr.vars.airmass.data<airmass(2))&(aero));
      if isempty(AM2)
         span = 0;
      else
         span = abs(mfr.vars.airmass.data(AM2(end))-mfr.vars.airmass.data(AM2(1)));
      end
      if (length(AM2) < 20)|(span<1.5)
         disp(['   BAD LANGLEY: Less than 20 cloud-free samples'])
         disp(['   BAD LANGLEY DAY: ',datestr(mfr.time(1), 'YYYY-mm-DD')]);
         if ~isempty(AM)
            [P,S] = polyfit(mfr.vars.airmass.data(AM), real(log10(V(AM))), 1);
            figure(5); semilogy(mfr.vars.airmass.data(AM), V(AM), 'r.', ...
               [airmass(1):airmass(2)], 10.^ polyval(P,[airmass(1):airmass(2)]), 'k');
            title(['Bad Langley:', datestr(mfr.time(1), 'YYYY-mm-DD'), ' cloud-free < 20']);
            ylabel('log(V)');
            xlabel('airmass');
            %             out_lang.badpng = ['D:\case_studies\sgpmfrsrC1\Langleys\bad\'];
            gfile = [out_lang.gstem,datestr(mfr.time(1),'YYYYmmDD'),'.langplot.png'];
            print('-dpng', [out_lang.badpng,gfile])
            %plot the bad Langley and save to file
         else
            [P,S] = polyfit(mfr.vars.airmass.data(AM), real(log10(V(AM))), 1);
            figure(5);
            title(['Bad Langley:', datestr(mfr.time(1), 'YYYY-mm-DD'), ' cloud-free < 20']);
            ylabel('log(V)');
            xlabel('airmass');

            %             out_lang.badpng = ['D:\case_studies\sgpmfrsrC1\Langleys\bad\'];
            gfile = [out_lang.gstem,datestr(mfr.time(1),'YYYYmmDD'),'.langplot.png'];
            print('-dpng', [out_lang.badpng,gfile])
         end
      else
         [P,S] = polyfit(mfr.vars.airmass.data(AM2), real(log(V(AM2))), 1);
         [Y,DELTA] = polyval(P,0,S);
         Vo_new = exp(Y);
         error_fraction = ((exp(Y+DELTA))-(exp(Y-DELTA)))/Vo_new;
         error_fractionx = error_fraction;
         Px = P;
         AMx = AM2;
         tau = -Px(1);
         normr = S.normr;
         %       if ((length(AM2)>20)&(error_fraction2 < .025)&(S2.normr<.1))
         if ((length(AM2)>20)&(error_fraction < .025))
            %Good Langley!
            L = L + 1;
            [Langley, lang_out] = put_in_lang(mfr, lang_out, AM2);
            % some stuff with Langley structure moved into put_in_lang

            disp(['   Good Langley #', num2str(L), ': ',datestr(mfr.time(1), 'YYYY-mm-DD') ]);
            disp(['   Vo_cloud-screened clearsky = ',num2str(Vo_new), ' +/- ', num2str(100*error_fraction),'%, tau = ',num2str(tau)])
            disp(['   normed residuals: ', num2str(S.normr)]);
            disp(['   number of samples: ', num2str(length(AM2))]);
            %This is a good Langley, but see if clearsky flag improves it
            AM4 = find((mfr.vars.az_angle.data < 180)&(mfr.vars.airmass.data>airmass(1))&(mfr.vars.airmass.data<airmass(2))&aero&(clr));
            clear P4 S4 Y4 DELTA4 Vo4 error_fraction4
            if length(AM4)>20
               [P4,S4] = polyfit(mfr.vars.airmass.data(AM4), real(log(V(AM4))), 1);
               [Y4,DELTA4] = polyval(P4,0,S4);
               Vo4 = exp(Y4);
               error_fraction4 = ((exp(Y4+DELTA4))-(exp(Y4-DELTA4)))/Vo4;
               Langley.Vo4(L) = Vo4;
               Langley.error_fraction4(L) = error_fraction4;
               Langley.PolyCoefs4(L,:) = P4;
               %          Langley.ErrorStats4(L) = S4;
               Langley.nSamples4(L) = length(AM4);
               disp(['   Vo_cloud-screened clearsky = ',num2str(Vo4), ' +/- ', num2str(100*error_fraction4),'%, tau = ',num2str(-P4(1))])
               disp(['   normed residuals: ', num2str(S4.normr)]);
               disp(['   number of samples: ', num2str(length(AM4))]);
               %             if ((error_fraction4<=error_fraction)&(S4.normr<=S2.normr))
               if ((error_fraction4<=error_fraction))
                  disp('Clearsky flag improved the fit.')
                  Vo_new = Vo4;
                  AMx = AM4;
                  error_fraction = error_fraction4;
                  Po = P4;
                  tau = -Po(1);
                  [Langley, lang_out] = put_in_lang(mfr, lang_out, AM4);
               end

            else
               disp(['Clearsky flag decimated the sample'])
               %                Langley.Vo4(L) = NaN;
               %                Langley.error_fraction4(L) = NaN;
               %                Langley.PolyCoefs4(L,:) = NaN([1,2]);
               %                %          Langley.ErrorStats4(L) = NaN;
               %                Langley.nSamples4(L) = length(AM4);
            end
            %Plot the good Langley and save to file

            status = output_langplot(mfr, lang_out, AM, AMx, arg.out_lang);

         else
            if (error_fraction >= .03)
               disp(['   BAD LANGLEY: error_fraction = ', num2str(error_fraction)])
            end
            %          if (normr >= .1)
            %             disp(['   BAD LANGLEY: residual greater than 0.1'])
            %          end
            figure(5); semilogy(mfr.vars.airmass.data(AM), V(AM), 'r.', ...
               mfr.vars.airmass.data(AMx), V(AMx), 'ko', [airmass(1):airmass(2)], exp(polyval(Po,[airmass(1):airmass(2)])), 'r');
            title(['Bad Langley:', datestr(mfr.time(1), 'YYYY-mm-DD'), ' Error = ', num2str(error_fraction)]);
            ylabel('log(V)');
            xlabel('airmass');
            %             out_lang.badpng = ['D:\case_studies\sgpmfrsrC1\Langleys\bad\'];
            gfile = [out_lang.gstem,datestr(mfr.time(1),'YYYYmmDD'),'.langplot.png'];
            print('-dpng', [out_lang.badpng,gfile])
         end
      end
      disp('.');
   end;
end
%

%%
   function lang_out = cleanup_lang_out(lang_out);
      %lang_out = cleanup_lang_out(lang_out);
      %define new fields, remove old fields...

      lang_out.vars.angstrom_exponent_870_500 = lang_out.vars.barnard_angstrom_exponent;
      lang_out.vars.angstrom_exponent_fit = lang_out.vars.barnard_angstrom_exponent;
      for ch = {'broadband', 'filter1', 'filter2', 'filter3', ...
            'filter4', 'filter5', 'filter6'}
         lang_out.vars.(['tau_',ch]) = lang_out.vars.(['barnard_optical_depth_',ch]);
         lang_out.vars.(['Vo_',ch]) = lang_out.vars.(['barnard_solar_constant_sdist_',ch]);
         lang_out.vars.(['error_fit_',ch]) = lang_out.vars.(['barnard_error_fit_',ch]);
         lang_out.vars.(['number_pts_',ch]) = lang_out.vars.(['barnard_number_points_',ch]);

         for pis = {'barnard', 'michalsky'}
            lang_out.vars.([pi,'_optical_depth_',ch]).keep = false;
            lang_out.vars.([pi,'_solar_constant_sdist_',ch]).keep = false;
            lang_out.vars.([pi,'_number_points_',ch]).keep = false;
            lang_out.vars.([pi,'_good_fraction_',ch]).keep = false;
            lang_out.vars.([pi,'_bad_flag_',ch]).keep = false;
         end
         lang_out.vars.(['barnard_error_fit_',ch]).keep = false;
         lang_out.vars.(['barnard_error_slope_',ch]).keep = false;
         lang_out.vars.(['michalsky_solar_constant_',ch]).keep = false;
         lang_out.vars.(['michalsky_standard_deviation_',ch]).keep = false;
      end
      lang_out.vars.barnard_angstrom_exponent.keep = false;
      lang_out.vars.michalsky_angstrom_exponent.keep = false;

      %%
      function output_langplot(mfr, lang_out, AM, AMx,out_lang);
         %output_langplot(mfr, lang_out, AMx);
         figure(5); semilogy(mfr.vars.airmass.data(AM), V(AM), 'b.', ...
            mfr.vars.airmass.data(AMx), V(AMx), 'ko', [0:airmass(2)+1], exp(polyval(Po,[0:airmass(2)+1])), 'r');
         title({['Good Langley: ', file_list(f).name], [' Vo = ',num2str(Vo_new), ' +/- ', num2str(100*error_fraction),'%, tau = ', num2str(tau)]});
         ylabel('log(V)');
         xlabel('airmass');

         gfile = [out_lang.gstem,datestr(mfr.time(1),'YYYYmmDD'),'.langplot.png'];
         print('-dpng', [out_lang.goodpng,gfile])

         %%

         %%
         function arg = set_arg;

            in_lang.pname = ['D:\case_studies\new_xmfrx_proc\sgpmfrsrC1\b1\'];
            in_lang.fname = ['sgpmfrsrC1.b1.20050729.000000.nc'];
            in_mfrsr.pname = ['D:\case_studies\new_xmfrx_proc\sgpmfrsrC1\b1\'];
            in_mfrsr.fmask = ['sgpmfrsrC1.b1.*.nc'];
            in_swanal.pname = ['D:\case_studies\new_xmfrx_proc\sgp1swfanal\'];
            in_swanal.fmask = ['sgp1swfanal*'];
            out_lang.Vodir = '';
            out_lang.langplot ='';
            out_lang.goodpng = ['D:\case_studies\new_xmfrx_proc\sgpmfrsrC1\Langleys\good\'];
            out_lang.badpng = ['D:\case_studies\new_xmfrx_proc\sgpmfrsrC1\Langleys\bad\'];
            out_lang.template = [in_mfrsr.pname, '..\Langleys\template\sgpmfrsrlangleyC1.c1.template.cdf'];

            out_lang.gstem = ['sgpmfrsrC1.'];
            airmass = [2,5];

            argC1.in_lang = in_lang;
            argC1.in_mfrsr = in_mfrsr;
            argC1.in_swanal = in_swanal;
            argC1.out_lang = out_lang;
            argC1.airmass = airmass;
            clear in_lang in_mfrsr in_swanal out_lang airmass

            in_lang.pname = ['D:\case_studies\new_xmfrx_proc\sgpmfrsrE13\b1\'];
            in_lang.fname = ['sgpmfrsrE13.b1.20050729.000000.nc'];
            in_mfrsr.pname = ['D:\case_studies\new_xmfrx_proc\sgpmfrsrE13\b1\'];
            in_mfrsr.fmask = ['sgpmfrsrE13.b1.*.nc'];
            in_swanal.pname = ['D:\case_studies\new_xmfrx_proc\sgp1swfanal\'];
            in_swanal.fmask = ['sgp1swfanal*'];
            out_lang.Vodir = '';
            out_lang.langplot ='';
            out_lang.goodpng = [in_mfrsr.pname, '..\Langleys\good\'];
            out_lang.badpng = [in_mfrsr.pname, '..\Langleys\bad\'];
            out_lang.template = [in_mfrsr.pname, '..\Langleys\template\sgpmfrsrlangleyE13.c1.template.cdf'];
            out_lang.gstem = ['sgpmfrsrE13.'];
            airmass = [2,5];

            argE13.in_lang = in_lang;
            argE13.in_mfrsr = in_mfrsr;
            argE13.in_swanal = in_swanal;
            argE13.out_lang = out_lang;
            argE13.airmass = airmass;
            clear in_lang in_mfrsr in_swanal out_lang airmass
            %%


            %%
