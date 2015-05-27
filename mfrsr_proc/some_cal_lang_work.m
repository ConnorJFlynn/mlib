% % First manually identify a good Langley like 2005-07-29.
% 
% %For simplicity, use the AM airmass since it doesn't extend across 00:00 UTC.
% 
% 1. Read in file.
% 2. Select AM criteria
% 3. Multiply dn by r_au.^2
% 4. Take log of dn_r
% 5. Polyfit 
% 6. exponential of intercept of polyfit is Vo.
% 
% To use this Vo.
% 1. Multiply dn by r_au.^2
% 2. Divide by Vo.
% 3. V/Vo = exp(-tau * airmass)
%     ==> tau = (log(Vo) - Log(V))/airmass
%             = (log(Vo)-log(V)) * cos_sza
% 4. Use this tau in Alexandrov's cloud screen
% 5. 
if exist('loc','var')
   in_lang = loc.in_lang;
   in_mfrsr = loc.in_mfrsr;
   swanal = loc.swanal;
   out_lang = loc.out_lang;
else
    in_lang.pname = ['D:\case_studies\sgpmfrsrC1\b1\'];
    in_lang.fname = ['sgpmfrsrC1.b1.20050729.000000.nc'];
    in_mfrsr.pname = ['D:\case_studies\sgpmfrsrC1\b1\'];
    in_mfrsr.fmask = ['sgpmfrsrC1.b1.*.nc'];
    swanal.pname = ['D:\case_studies\sgp1swfanal\'];
    swanal.fmask = ['sgp1swfanal*'];
    out_lang.Vodir = '';
    out_lang.langplot ='';
    out_lang.goodpng = ['D:\case_studies\sgpmfrsrC1\Langleys\'];
    out_lang.badpng = ['D:\case_studies\sgpmfrsrC1\Langleys\bad\'];
end

mfr = ancload([in_lang.pname, in_lang.fname]);
disp(['Initial Langley: ', datestr(mfr.time(1), 'YYYY-mm-DD')]);
%
nulls = find(mfr.vars.cordn_filter2.data<=0);
AM = find((mfr.vars.az_angle.data < 180)&(mfr.vars.airmass.data>2)&(mfr.vars.airmass.data<5));
V = mfr.vars.cordn_filter2.data .* mfr.vars.r_au.data.^2;
V(nulls) = NaN;
[P,S] = polyfit(mfr.vars.airmass.data(AM), real(log10(V(AM))), 1);
[Y,DELTA] = polyval(P,0,S);
Vo = 10^Y;
disp(['Vo = ',num2str(Vo), ' +/- ', num2str(100*((10^(Y+DELTA))-(10^(Y-DELTA)))/Vo),'%'])
disp('.')
% figure(1); semilogy(mfr.vars.airmass.data(AM), V(AM), 'go', [0:5], 10.^ polyval(P,[0:5]));
% ylabel('log(V)')
% title('Initial hand-selected Langley')

%%
L = 0;
% disp('Select next day to check.')
% in_mfrsr.pname = ['D:\case_studies\sgpmfrsrC1\b1\'];
% in_mfrsr.fmask = ['sgpmfrsrC1.b1.*.nc'];
file_list = dir([in_mfrsr.pname, in_mfrsr.fmask]);
for f =1:length(file_list)
    clear mfr
    disp(['Processing file #', num2str(f), ' of ', num2str(length(file_list)), ' : ', file_list(f).name]);
    mfr = ancload([pname, file_list(f).name]);
    %%
    nulls = find(mfr.vars.cordn_filter2.data<=0);
    V = mfr.vars.cordn_filter2.data .* mfr.vars.r_au.data.^2;
    V(nulls) = NaN;
    tau = (log(Vo) - log(V)) .* mfr.vars.cza.data;
    [aero, eps] = alex_screen(mfr.time, tau);

    sw_file = dir([swanal.pname, swanal.fmask,datestr(mfr.time(1),'YYYYmmDD'), '*.cdf']);
    if length(sw_file)>0
        swanal = ancload([sw_dir, sw_file(1).name]);
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

    AM = find((mfr.vars.az_angle.data < 180)&(mfr.vars.airmass.data>2)&(mfr.vars.airmass.data<5));
    if length(AM) < 20
        disp(['   BAD LANGLEY: Less than 20 raw samples'])
    end
    AM2 = find((mfr.vars.az_angle.data < 180)&(mfr.vars.airmass.data>2)&(mfr.vars.airmass.data<5)&(aero));
    if length(AM2) < 20
        disp(['   BAD LANGLEY: Less than 20 cloud-free samples'])
    end
    AM3 = find((mfr.vars.az_angle.data < 180)&(mfr.vars.airmass.data>2)&(mfr.vars.airmass.data<5)&(clr));
    if length(AM3) < 20
        disp(['   BAD LANGLEY: Less than 20 clearsky samples'])
    end
    AM4 = find((mfr.vars.az_angle.data < 180)&(mfr.vars.airmass.data>2)&(mfr.vars.airmass.data<5)&aero&(clr));
    if length(AM4) < 20
        disp(['   BAD LANGLEY: Less than 20 samples flagged both clearsky and cloudfree'])
    end

    % if length(AM>2)
    %     %figure(101); plot(serial2Hh(mfr.time), tau, 'r.', serial2Hh(mfr.time(AM)), tau(AM), 'g.')
    %     %ylabel('tau');
    %     %title('Tau with Airmass from 2 to 5');
    %     [P,S] = polyfit(mfr.vars.airmass.data(AM), real(log10(V(AM))), 1);
    %     figure(1011); semilogy(mfr.vars.airmass.data(AM), V(AM), 'go', [0:5], 10.^ polyval(P,[0:5]));
    %     ylabel('log(V)')
    %     title('Initial AM Langley');
    %     [Y,DELTA] = polyval(P,0,S);
    %     Vo_new = 10^Y;
    %     disp(['Vo_new = ',num2str(Vo_new), ' +/- ', num2str(100*((10^(Y+DELTA))-(10^(Y-DELTA)))/Vo_new),'%'])
    %     length(AM)
    % end
    % if length(AM2>2)
    %     figure(102); plot(serial2Hh(mfr.time(AM)), tau(AM), 'ro', serial2Hh(mfr.time(AM2)), tau(AM2), 'g.' )
    %     title('Cloud screened TAU');
    %     ylabel('log(V)')
    %     [P2,S2] = polyfit(mfr.vars.airmass.data(AM2), real(log10(V(AM2))), 1);
    %     figure(1021); semilogy(mfr.vars.airmass.data(AM), V(AM), 'r.',mfr.vars.airmass.data(AM2), V(AM2), 'go', [0:5], 10.^ polyval(P2,[0:5]));
    %     ylabel('log(V)')
    %     title('Langley with cloud screening');
    %     [Y,DELTA] = polyval(P2,0,S2);
    %     Vo_new = 10^Y;
    %     disp(['Vo_cloud_screened = ',num2str(Vo_new), ' +/- ', num2str(100*((10^(Y+DELTA))-(10^(Y-DELTA)))/Vo_new),'%'])
    %     length(AM2)
    % end
    %

    % if length(AM3)>2
    %     figure(103); plot(serial2Hh(mfr.time(AM)), tau(AM), 'ro', serial2Hh(mfr.time(AM2)), tau(AM2), 'g.', ...
    %         serial2Hh(mfr.time(AM3)), tau(AM3),  'bx' );
    %     title('Clearsky TAU');
    %     ylabel('log(V)')
    %
    %     [P3,S3] = polyfit(mfr.vars.airmass.data(AM3), real(log10(V(AM3))), 1);
    %     figure(1031); semilogy(mfr.vars.airmass.data(AM), V(AM), 'r.',mfr.vars.airmass.data(AM3), V(AM3), 'go', [0:5], 10.^ polyval(P2,[0:5]));
    %     ylabel('log(V)')
    %     title('Langley with clearsky flag');
    %
    %     [Y,DELTA] = polyval(P3,0,S3);
    %     Vo_new = 10^Y;
    %     disp(['Vo_clearsky = ',num2str(Vo_new), ' +/- ', num2str(100*((10^(Y+DELTA))-(10^(Y-DELTA)))/Vo_new),'%'])
    %     length(AM3)
    %
    % end
    %

    % if length(AM4)>2
    %     figure(104); plot(serial2Hh(mfr.time(AM)), tau(AM), 'b.', serial2Hh(mfr.time(AM2)), tau(AM2), 'g+', ...
    %         serial2Hh(mfr.time(AM3)), tau(AM3),  'bx', ...
    %         serial2Hh(mfr.time(AM4)), tau(AM4),  'ro');
    %     title('Tau screened for clouds and clearsky');
    %     ylabel('log(V)')
    %
    %     [P4,S4] = polyfit(mfr.vars.airmass.data(AM4), real(log10(V(AM4))), 1)
    %     figure(1041); semilogy(mfr.vars.airmass.data(AM), V(AM), 'r.',mfr.vars.airmass.data(AM3), V(AM3), 'go', [0:5], 10.^ polyval(P2,[0:5]));
    %     ylabel('log(V)')
    %     title('Langley with cloud-screened clearsky points');
    %
    % end
    %
    if ((length(AM2)>20)&(length(AM3)>20)&(length(AM4)>20))
        %         [P,S] = polyfit(mfr.vars.airmass.data(AM), real(log10(V(AM))), 1);
        %         [P2,S2] = polyfit(mfr.vars.airmass.data(AM2), real(log10(V(AM2))), 1);
        %         [P3,S3] = polyfit(mfr.vars.airmass.data(AM3), real(log10(V(AM3))), 1);
        [P4,S4] = polyfit(mfr.vars.airmass.data(AM4), real(log10(V(AM4))), 1);

        %         figure(1051); plot(serial2Hh(mfr.time(AM)), tau(AM), 'b.', serial2Hh(mfr.time(AM2)), tau(AM2), 'r+', ...
        %             serial2Hh(mfr.time(AM3)), tau(AM3),  'gx', ...
        %             serial2Hh(mfr.time(AM4)), tau(AM4),  'k.');
        %         title(['Tau screened for clouds and clearsky: ', datestr(mfr.time(1), 'YYYY-mm-DD')]);
        %         ylabel('tau');
        %         xlabel('time (UTC)');
        %         v = axis; axis([v(1), v(2), 0, .5]);
        %
        %         figure(105); semilogy(mfr.vars.airmass.data(AM), V(AM), 'b.', ...
        %             mfr.vars.airmass.data(AM2), V(AM2), 'r+', [0:5], 10.^ polyval(P2,[0:5]), 'r', ...
        %             mfr.vars.airmass.data(AM3), V(AM3), 'gx', [0:5], 10.^ polyval(P3,[0:5]), 'g', ...
        %             mfr.vars.airmass.data(AM4), V(AM4), 'k.', [0:5], 10.^ polyval(P4,[0:5]), 'b');
        %         title(['All Langley screening options:', datestr(mfr.time(1), 'YYYY-mm-DD')]);
        %         ylabel('log(V)');
        %         xlabel('airmass');
        %         pause(1)
        [Y,DELTA] = polyval(P4,0,S4);
        Vo_new = 10^Y;
        error_fraction = ((10^(Y+DELTA))-(10^(Y-DELTA)))/Vo_new;
        
        if ( (error_fraction < .02)&(S4.normr<.04))
            L = L + 1;
            disp(['   Good Langley #', num2str(L), ': ',datestr(mfr.time(1), 'YYYY-mm-DD') ]);
            disp(['   Vo_cloud-screened clearsky = ',num2str(Vo_new), ' +/- ', num2str(100*error_fraction),'%'])
            
            Langley.time(L) = mean(mfr.time(AM4));
            Langley.Vo(L) = Vo_new;
            Langley.error_fraction(L) = error_fraction;
            Langley.PolyCoefs(L,:) = P4;
            Langley.ErrorStats(L) = S4;
            Langley.nSamples(L) = length(AM4);
            disp(['   normed residuals: ', num2str(S4.normr)]);
            disp(['   number of samples: ', num2str(length(AM4))]);
            %Plot the good Langley and save to file
            figure(5); semilogy(mfr.vars.airmass.data(AM), V(AM), 'b.', ...
            mfr.vars.airmass.data(AM4), V(AM4), 'ko', [0:5], 10.^ polyval(P4,[0:5]), 'r');
            title(['Good Langley:', datestr(mfr.time(1), 'YYYY-mm-DD'), ' Vo = ',num2str(Vo_new), ' +/- ', num2str(100*error_fraction),'%']);
            ylabel('log(V)');
            xlabel('airmass');
            
            gfile = ['sgpmfrsrC1.',datestr(mfr.time(1),'YYYYmmDD'),'.langplot.png'];
            print('-dpng', [out_lang.goodpng,gfile])
        else
            if (error_fraction >= .02)
                disp(['   BAD LANGLEY: error_fraction greater than 2%'])
            end
            if (S4.normr >= .04)
                disp(['   BAD LANGLEY: residual greater than 0.04'])
            end
        end
        clear P4
        %status = saveLangleyPlot;
        %Vos = collectLangleyVos;
        
    else
        disp(['   BAD LANGLEY DAY: ',datestr(mfr.time(1), 'YYYY-mm-DD')]);
        if ~isempty(AM)
            [P,S] = polyfit(mfr.vars.airmass.data(AM), real(log10(V(AM))), 1);
            figure(5); semilogy(mfr.vars.airmass.data(AM), V(AM), 'b.', ...
                [0:5], 10.^ polyval(P,[0:5]), 'r');
            title(['Bad Langley:', datestr(mfr.time(1), 'YYYY-mm-DD')]);
            ylabel('log(V)');
            xlabel('airmass');
            out_lang.badpng = ['D:\case_studies\sgpmfrsrC1\Langleys\bad\'];
            gfile = ['sgpmfrsrC1.',datestr(mfr.time(1),'YYYYmmDD'),'.langplot.png'];
            print('-dpng', [out_lang.badpng,gfile])

            %plot the bad Langley and save to file
        end
    end
    disp('.');
end
%





%%
