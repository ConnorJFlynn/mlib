function [langs, mfrsr] = new_langleys(arg);
% [langs, mfrsr] = new_langleys(arg);
% optional argument arg has following optional elements:
% arg.mfrsr.fname
% arg.airmass
% arg.Vo
% arg.swanal.pname
% arg.swanal.fmask
% arg.out_lang.Vodir
% arg.out_lang.langplot
% arg.out_lang.goodpng
% arg.out_lang.badpng
% arg.out_lang.gstem
%This will iterate over ch with new_lang, old_lang, and rat_lang to return langley
%regression values

if exist('arg','var')
   if isfield(arg, 'mfrsr')
      if ~isstruct(arg.mfr)
         mfr = ancload(mfr);
      else
         mfr = ancload(mfr.fname);
      end
   else
      mfr = ancload;
   end
   if isfield(arg, 'swanal')
      swanal = arg.swanal;
   else
      swanal = [];
   end
   if isfield(arg, 'airmass')
      airmass = arg.airmass;
   else
      airmass = [2,6];
   end
   if isfield(arg, 'Vo')
      Vo = arg.Vo;
   else
      Vo = NaN;
   end
else
   mfr = ancload;
   swanal = [];
   airmass = [2,6];
   Vo = NaN;
end

nulls = find(mfr.vars.cordirnorm_filter2.data<=0);
V = mfr.vars.cordirnorm_filter2.data .* mfr.vars.r_au.data.^2;
V(nulls) = NaN;
if ~isNaN(Vo)
   tau = (log(Vo) - log(V)) .* mfr.vars.cos_zen.data;
   [aero, eps] = alex_screen(mfr.time, tau);
else
   aero = ones(size(mfr.time));
   eps = zeros(size(mfr.time));
end
if ~isempty(swanal)
   sw_file = dir([swanal.pname, swanal.fmask,datestr(mfr.time(1),'YYYYmmDD'), '*.cdf']);
   if length(sw_file)>0
      swanal = ancload([swanal.pname, sw_file(1).name]);
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
end
% 
%    langs(t)
%    .Aero
%    .OldLang
%    .Vo(ch)
%    .tau(ch)
%    .chi(ch)
%    .etc(ch)
%    .NewLang
%    .Vo(ch)
%    .tau(ch)
%    .chi(ch)
%    .etc(ch)
%    .Clrsky
%    .OldLang
%    .Vo(ch)
%    .tau(ch)
%    .chi(ch)
%    .etc(ch)
%    .NewLang
%    .Vo(ch)
%    .tau(ch)
%    .chi(ch)
%    .etc(ch)
%    .Both
%    .OldLang
%    .Vo(ch)
%    .tau(ch)
%    .chi(ch)
%    .etc(ch)
%    .NewLang
%    .Vo(ch)
%    .tau(ch)
%    .chi(ch)
%    .etc(ch)
%    .Either
%    .OldLang
%    .Vo(ch)
%    .tau(ch)
%    .chi(ch)
%    .etc(ch)
%    .NewLang
%    .Vo(ch)
%    .tau(ch)
%    .chi(ch)
%    .etc(ch)
% 
   %
   % nulls = find(mfr.vars.cordirnorm_filter2.data<=0);
   % AM = find((mfr.vars.az_angle.data < 180)&(mfr.vars.airmass.data>=min(airmass))&(mfr.vars.airmass.data<=max(airmass)));
   % PM = find((mfr.vars.az_angle.data > 180)&(mfr.vars.airmass.data>=min(airmass))&(mfr.vars.airmass.data<=max(airmass)));
   % V = mfr.vars.cordirnorm_filter2.data .* mfr.vars.r_au.data.^2;
   % V(nulls) = NaN;
   % [P,S] = polyfit(mfr.vars.airmass.data(AM), real(log(V(AM))), 1);
   % [Y,DELTA] = polyval(P,0,S);
   % Vo = exp(Y);
   % disp(['Vo = ',num2str(Vo), ' +/- ', num2str(100*((exp(Y+DELTA))-(exp(Y-DELTA)))/Vo),'%, tau = ',num2str(-P(1))])
   % disp('.')
   % figure; plot(mfr.vars.airmass.data(AM), real(log(V(AM))),'ro');
   % title('Old Langley'); xlabel('airmass'); ylabel('log(I)');

   % alt.ind = 1./mfr.vars.airmass.data(AM);
   % alt.dep = real(log(V(AM)))./mfr.vars.airmass.data(AM);
   % [alt.P, alt.S] = polyfit(alt.ind, alt.dep, 1);
   % alt.Vo = exp(alt.P(1));
   % alt.tau = -polyval(alt.P, 0, alt.S);
   %
   % subplot(2,1,1); plot(mfr.vars.airmass.data(AM), real(log(V(AM))),'ro');
   % title('Old Langley'); xlabel('airmass'); ylabel('log(I)');
   % subplot(2,1,2); plot(1-1./mfr.vars.airmass.data(AM), real(log(V(AM)))./mfr.vars.airmass.data(AM),'bx');
   % title('New Langley'); xlabel('1-1/airmass'); ylabel('log(I)/airmass');

   %%
   % file_list = dir([in_mfrsr.pname, in_mfrsr.fmask]);
   % for f =1:length(file_list)
   %    clear mfr
   %    disp(['Processing file #', num2str(f), ' of ', num2str(length(file_list)), ' : ', file_list(f).name]);
   mfr = ancload([in_mfrsr.filename]);
   %%
   nulls = find(mfr.vars.cordirnorm_filter2.data<=0);
   V = mfr.vars.cordirnorm_filter2.data .* mfr.vars.r_au.data.^2;
   V(nulls) = NaN;
   tau = (log(Vo) - log(V)) .* mfr.vars.cos_zen.data;
   [aero, eps] = alex_screen(mfr.time, tau);


   % For each airmass leg (AM and PM) compute  Langley for aero, clr,
   % aero & clr

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
            alt.ind = 1./mfr.vars.airmass.data(AM);
            alt.dep = real(log(V(AM)))./mfr.vars.airmass.data(AM);
            [alt.P, alt.S] = polyfit(alt.ind, alt.dep, 1);
            alt.Vo = exp(alt.P(1));
            alt.tau = -polyval(alt.P, 0, alt.S);
            figure(5);
            subplot(2,1,1); plot(mfr.vars.airmass.data(AM), real(log(V(AM))), 'r.', ...
               [airmass(1):airmass(2)], polyval(P,[airmass(1):airmass(2)]), 'k');
            title(['Bad Langley:', datestr(mfr.time(1), 'YYYY-mm-DD'), ' cloud-free < 20']);
            xlabel('airmass'); ylabel('log(V)');
            subplot(2,1,2); plot(1-1./mfr.vars.airmass.data(AM), real(log(V(AM)))./mfr.vars.airmass.data(AM),'bx');
            title('New Langley'); xlabel('1-1/airmass'); ylabel('log(I)/airmass');
            v = axis; axis([v(1), .8, v(3), v(4)]);

            %             figure(5); semilogy(mfr.vars.airmass.data(AM), V(AM), 'r.', ...
            %                [airmass(1):airmass(2)], 10.^ polyval(P,[airmass(1):airmass(2)]), 'k');
            %             title(['Bad Langley:', datestr(mfr.time(1), 'YYYY-mm-DD'), ' cloud-free < 20']);
            %             ylabel('log(V)');
            %             xlabel('airmass');
            %             %             out_lang.badpng = ['D:\case_studies\sgpmfrsrC1\Langleys\bad\'];
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
         alt.ind = 1./mfr.vars.airmass.data(AM2);
         alt.dep = real(log(V(AM2)))./mfr.vars.airmass.data(AM2);
         [alt.P, alt.S] = polyfit(alt.ind, alt.dep, 1);
         alt.Vo = exp(alt.P(1));
         alt.tau = -polyval(alt.P, 0, alt.S);
         figure;
         subplot(2,1,1); plot(mfr.vars.airmass.data(AM2), real(log(V(AM2))),'ro');
         title('Old Langley'); xlabel('airmass'); ylabel('log(I)');
         subplot(2,1,2); plot(1-1./mfr.vars.airmass.data(AM2), real(log(V(AM2)))./mfr.vars.airmass.data(AM2),'bx');
         title('New Langley'); xlabel('1-1/airmass'); ylabel('log(I)/airmass');
         v = axis; axis([v(1), .8, v(3), v(4)]);

         %       if ((length(AM2)>20)&(error_fraction2 < .025)&(S2.normr<.1))
         if ((length(AM2)>20)&(error_fraction < .025))
            %Good Langley!
            L = L + 1;
            [Langley, lang_out] = put_in_lang(mfr, lang_out, AM2,L,Langley);
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
                  [Langley, lang_out] = put_in_lang(mfr, lang_out, AM4,L,Langley);
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

            output_langplot(mfr, Langley, AM, AMx, arg.out_lang);

         else
            if (error_fraction >= .03)
               disp(['   BAD LANGLEY: error_fraction = ', num2str(error_fraction)])
            end
            %          if (normr >= .1)
            %             disp(['   BAD LANGLEY: residual greater than 0.1'])
            %          end
            figure(5); semilogy(mfr.vars.airmass.data(AM), V(AM), 'r.', ...
               mfr.vars.airmass.data(AMx), V(AMx), 'ko', [airmass(1):airmass(2)], exp(polyval(Px,[airmass(1):airmass(2)])), 'r');
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

disp('allmost all done');
lang_out.vars.angstrom_exponent_fit.data = NaN(size(lang_out.time));
lang_out.vars.angstrom_exponent_870_500.data = NaN(size(lang_out.time));
%lang_out = ancsetepoch(lang_out);
lang_out = timesync(lang_out);
lang_out = anccheck(lang_out);
lang_out.fname = [arg.out_lang.Vodir, arg.out_lang.gstem,'Vo_series.',datestr(lang_out.time(1),'YYYYmmDD'),'.nc']
lang_out.clobber = true;
save lang_out
status = ancsave(lang_out);
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
         lang_out.vars.(['tau_',char(ch)]) = lang_out.vars.(['barnard_optical_depth_',char(ch)]);
         lang_out.vars.(['Vo_',char(ch)]) = lang_out.vars.(['barnard_solar_constant_sdist_',char(ch)]);
         lang_out.vars.(['error_fit_',char(ch)]) = lang_out.vars.(['barnard_error_fit_',char(ch)]);
         lang_out.vars.(['number_pts_',char(ch)]) = lang_out.vars.(['barnard_number_points_',char(ch)]);

         for pis = {'barnard', 'michalsky'}
            lang_out.vars.([char(pis),'_optical_depth_',char(ch)]).keep = false;
            lang_out.vars.([char(pis),'_solar_constant_sdist_',char(ch)]).keep = false;
            lang_out.vars.([char(pis),'_number_points_',char(ch)]).keep = false;
            lang_out.vars.([char(pis),'_good_fraction_',char(ch)]).keep = false;
            lang_out.vars.([char(pis),'_badflag_',char(ch)]).keep = false;
         end
         lang_out.vars.(['barnard_error_fit_',char(ch)]).keep = false;
         lang_out.vars.(['barnard_error_slope_',char(ch)]).keep = false;
         lang_out.vars.(['michalsky_solar_constant_',char(ch)]).keep = false;
         lang_out.vars.(['michalsky_standard_deviation_',char(ch)]).keep = false;
      end
      lang_out.vars.barnard_angstrom_exponent.keep = false;
      lang_out.vars.michalsky_angstrom_exponent.keep = false;
   end
      %%
      function output_langplot(mfr, Langley, AM, AMx,out_lang);
         %output_langplot(mfr, lang_out, AMx);
         V = mfr.vars.cordirnorm_filter2.data .* mfr.vars.r_au.data.^2;
         Po = Langley.PolyCoefs(end,:);
         Vo = Langley.Vo(end);
         error_fraction = Langley.error_fraction(end);
         tau = Langley.tau(end)

         figure(5); semilogy(mfr.vars.airmass.data(AM), V(AM), 'b.', ...
            mfr.vars.airmass.data(AMx), V(AMx), 'ko', ...
            [0:7], exp(polyval(Po,[0:7])), 'r');
         title({['Good Langley: ', datestr(Langley.time(end),'YYYY-mm-DD')], [' Vo = ',num2str(Vo), ' +/- ', num2str(100*error_fraction),'%, tau = ', num2str(tau)]});
         ylabel('log(V)');
         xlabel('airmass');

         gfile = [out_lang.gstem,datestr(mfr.time(1),'YYYYmmDD'),'.langplot.png'];
         print('-dpng', [out_lang.goodpng,gfile])
      end

         %%

         %%
            %%
            function [Vo, tau, P,S] = old_lang(airmass, V);
               [P,S] = polyfit(airmass, real(log(V)), 1);
               [Y,DELTA] = polyval(P,0,S);
               Vo_new = exp(Y);
               tau = -P(1);
            end
            
            function [Vo,tau,P,S] = new_lang(inv_airmass, V_by_am)
                  [P,S] = polyfit(inv_airmass, real(log(V_by_am)), 1);
                  Vo = exp(P(1));
                  y_int = polyval(P, 0, S);
                  tau = exp(-y_int);
            end
                  function arg = set_arg;

            in_lang.pname = ['D:\case_studies\new_xmfrx_proc\sgpmfrsrC1\b1\solarday\'];
            in_lang.fname = ['sgpmfrsrC1.b2.20050729.000000.nc'];
            in_mfrsr.pname = ['D:\case_studies\new_xmfrx_proc\sgpmfrsrC1\b1\solarday\'];
            in_mfrsr.fmask = ['sgpmfrsrC1.b2.*.nc'];
            in_swanal.pname = ['D:\case_studies\new_xmfrx_proc\sgp1swfanal\'];
            in_swanal.fmask = ['sgp1swfanal*'];
            out_lang.Vodir = [in_mfrsr.pname, '..\..\Langleys\'];
            out_lang.langplot =[in_mfrsr.pname, '..\..\Langleys\'];
            out_lang.goodpng = [in_mfrsr.pname, '..\..\Langleys\good\'];
            out_lang.badpng = [in_mfrsr.pname, '..\..\Langleys\bad\'];
            out_lang.badpng = [in_mfrsr.pname, '..\..\Langleys\bad\'];
            out_lang.template = [in_mfrsr.pname, '..\..\Langleys\template\sgpmfrsrlangleyC1.c1.template.cdf'];
            out_lang.gstem = ['sgpmfrsrC1.'];
            airmass = [2,5];

            argC1.in_lang = in_lang;
            argC1.in_mfrsr = in_mfrsr;
            argC1.in_swanal = in_swanal;
            argC1.out_lang = out_lang;
            argC1.airmass = airmass;
            clear in_lang in_mfrsr in_swanal out_lang airmass

            in_lang.pname = ['D:\case_studies\new_xmfrx_proc\sgpmfrsrE13\b1\solarday\'];
            in_lang.fname = ['sgpmfrsrE13.b2.20050729.063000.nc'];
            in_mfrsr.pname = ['D:\case_studies\new_xmfrx_proc\sgpmfrsrE13\b1\solarday\'];
            in_mfrsr.fmask = ['sgpmfrsrE13.b2.*.nc'];
            in_swanal.pname = ['D:\case_studies\new_xmfrx_proc\sgp1swfanal\'];
            in_swanal.fmask = ['sgp1swfanal*'];
            out_lang.Vodir = [in_mfrsr.pname, '..\..\Langleys\'];
            out_lang.langplot =[in_mfrsr.pname, '..\..\Langleys\'];
            out_lang.goodpng = [in_mfrsr.pname, '..\..\Langleys\good\'];
            out_lang.badpng = [in_mfrsr.pname, '..\..\Langleys\bad\'];
            out_lang.template = [in_mfrsr.pname, '..\..\Langleys\template\sgpmfrsrlangleyE13.c1.template.cdf'];
            out_lang.gstem = ['sgpmfrsrE13.'];
            airmass = [2,5];

            argE13.in_lang = in_lang;
            argE13.in_mfrsr = in_mfrsr;
            argE13.in_swanal = in_swanal;
            argE13.out_lang = out_lang;
            argE13.airmass = airmass;
            clear in_lang in_mfrsr in_swanal out_lang airmass
         end
