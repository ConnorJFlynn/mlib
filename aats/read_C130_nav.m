[hh,mm,ss,GALT,GLAT,GLON,PITCH,ROLL,SOLAZ,SOLEL,THDG] = textread('c:\beat\data\boulder\test flight 1 pitchroll.txt','%2d:%2d:%2d%f%f%f%f%f%f%f%f','headerlines',1);
UT=hh+mm/60+ss/3600;

figure
plot(UT,PITCH,UT,ROLL)
axis([17.6 17.8  -30 30])
legend('pitch','roll')
grid on