% Deine Mie-Daten ohne Header !
cd c:\beat\mie\King_Vax\results
%load miewisc145.dat
%a=miewisc145;clear miewisc

load king145.dat
a=king145;clear king145

tic
qext=[];
qscat=[];m=1.45;
st=1;nr=length(a)
for i=st:1:nr;
        disp([num2str(i),'-',num2str(nr)])
        N=mie_test(a(i,1));
        if isnan(N)
                N=40;
        end
        N=N+10;
        [Q_ext,Q_scat]=mie(a(i,1),m,N);
        qext=[qext;Q_ext];
        qscat=[qscat;Q_scat];
end
toc

figure(1)
subplot(3,1,1)
plot(a(st:nr,1),a(st:nr,2))
subplot(3,1,2)
plot(a(st:nr,1),qext)
subplot(3,1,3)
plot(a(st:nr,1),a(st:nr,2)-qext,'.')  % Differenz
