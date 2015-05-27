
%  	public static double ScatteringAngle90(double BandAngleDegrees, double solarZenithDegrees)
%         {
%             double val = BandAngle90(BandAngleDegrees, solarZenithDegrees);
%            return val - 180;
%         }
% 
%         public static double BandAngle90(double scatteringAngleDegrees, double solarZenithDegrees)
%         {
%             double solarZenithRadians = DegreesToRadians(solarZenithDegrees);
%             double tanB = .391 / 8.0;
% 
%             double val = (Math.Sin(2.0 * solarZenithRadians) / 2.0) + tanB;
%             val = Math.Asin(val);
%             val = radiansToDegrees(val);
% 
%             return 90.0 - val + scatteringAngleDegrees;
%         }
% Test scat ang code
%%
sza = 80;
scat_ang = 0;
band_angle = bandang90(scat_ang,sza)

%%


function band_angle = bandang90(scat_angle, sza)
tanb = 0.391./8;
val = sin(2.*sza)./2 + tanb;
val = asin(val);
band_angle = 90- val + scat_ang;
return

function scat_ang = scatang90(band_angle, sza);
val = bandang90(band_angle, sza);
scat_ang = val - 180;
return
