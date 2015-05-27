% Deine Mie-Daten ohne Header !
cd d:\beat\mie\King_VAX\results
%load miewisc145.dat
%a=miewisc145;clear miewisc

load king145.dat
a=king145;clear king145

tic
m=1.45;
st=10
N=mie_test(a(st:end,1));
[Q_ext,Q_scat]=mie2(a(st:end,1),m,N);
toc

figure(1)
subplot(3,1,1)
plot(a(st:end,1),a(st:end,2))
subplot(3,1,2)
plot(a(st:end,1),Q_ext)
subplot(3,1,3)
plot(a(st:end,1),a(st:end,2)-Q_ext,'.')  % Differenz
