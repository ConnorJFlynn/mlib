
function [file_name]=display_moments_data(file,alt)
radar_dir = ['E:\twpice\raw_archive\radar\'];
dir_list = dir(radar_dir);
for d = 28:length(radar_dir)
    if dir_list(d).isdir
        pname = [radar_dir, dir_list(d).name, '\'];

        file_list=dir([pname, 'parsl.moments.*.dat']);
        alt = 16000;
        if(isempty(file_list))
            disp(['No file(s) found.'])
            return
        else
            for f = 1:length(file_list)
                file_name = [pname, char(file_list(f).name)];
                disp(['File ', datestr(f), ' of ', datestr(length(file_list)), ' : ',file_name]);
                directory = pname;
                %[directory,fname,ext] = fileparts(file_name);
                if ~exist([directory,'images'],'dir')
                    mkdir(directory, 'images');
                end
                gdir = ['E:\twpice\proc_data\radar\images\'];

                %         if(length(a(:))>1)
                %             disp('More than one moment file located ... plotting most recent');
                %
                %             files=sortrows(files);
                %         end
                %
                %         s=findstr(file,'/');
                %         directory=file(1:s(end))

                disp('loading moments data ...');
                [power_time,mean_I,mean_Q,mean_I2,mean_Q2,velocity,width,elevation,azimuth,n_gates,start_date]=read_radar_moments_file(file_name);

                disp('estimating noise floor ...');
                [power,noise_power,DC_I,DC_Q,I_to_Q_balance]=get_power_from_mean_IQ(mean_I,mean_Q,mean_I2,mean_Q2);
                clear mean_I mean_Q mean_I2 mean_Q2 noise_power DC_I DC_Q I_to_Q_balance

                % need to fix this one day
                range=((1:4096)-20)*6+1;

                disp('applying range correction ...')
                % /* put range factor in dBZ */
                power2=zeros(size(power));
                for i=1:length(range)
                    power2(i,:)=power(i,:)*(range(i)^2);
                end

                magic_constant = 10^-13.0687;

                % get date
                T=findstr(file_name,'.moments.');
                d=file_name(T+9:T+16);
                time = (datenum(d,'yyyyMMdd')+power_time/24);

                figure(1)
                imagesc(serial2Hh(time),range,10*log10(power2*magic_constant))
                c=caxis;
                axis('xy')
                caxis([-60 20]);
                a=axis;
                axis([a(1) a(2) 0 alt])
                colorbar
                title('Approx. Reflectivity, dBZe (mm^6/m^3)','Fontsize',14);
                xlabel(['Time ' d ', UTC'],'Fontsize',14);
                ylabel('Appoximate Range, m','Fontsize',14);


                gfile= ['parslradar.dBZe.',datestr(time(1), 'YYYYmmDD_HHMMSS'),'.png'];
                % cd r:\;
                print('-dpng', [gdir,gfile]);
                % axis([power_time(1) power_time(0.5*end) 0 10000])

                figure(2)
                imagesc(serial2Hh(time),range,velocity)
                axis('xy')
                axis([a(1) a(2) 0 alt])
                caxis([-2 2])
                colorbar
                title('Mean Doppler Velocity, m/s','Fontsize',14);
                xlabel(['Time ' d ', UTC'],'Fontsize',14)
                ylabel('Appoximate Range, m','Fontsize',14)
                gfile= ['parslradar.doppler_velocity.',datestr(time(1), 'YYYYmmDD_HHMMSS'),'.png'];
                % cd r:\;
                print('-dpng', [gdir,gfile]);

                figure(3)
                imagesc(serial2Hh(time),range,width)
                axis('xy')
                axis([a(1) a(2) 0 alt])
                caxis([0 2])
                colorbar
                title('Doppler Width, m/s','Fontsize',14);
                xlabel(['Time ' d ', UTC'],'Fontsize',14);
                ylabel('Appoximate Range, m','Fontsize',14);
                gfile= ['parslradar.doppler_width.',datestr(time(1), 'YYYYmmDD_HHMMSS'),'.png'];
                % cd r:\;
                print('-dpng', [gdir,gfile]);
                clear power noise_power DC_I DC_Q I_to_Q_balance
                clear power_time mean_I mean_Q mean_I2 mean_Q2 velocity
                clear width elevation azimuth n_gates start_date power2

            end
        end

    end
end
%     cd C:/roj/matlab_codes;

return
