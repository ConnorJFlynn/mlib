% simulated tau for testing lang, uwlang, reflang, uwreflng, tlang, uwtlang, reftlang uwreftlang
% Let wl = 500 nm, this defines tau_ray
Io = 2;
am = 1.5:.1:6;
tau_g = rayleigh_ht(500./1000);
tau_raya = linspace(tau_g.*.99, tau_g.*1.01,length(am));
tau_rayd = linspace(tau_g.*1.01, tau_g.*.99,length(am));

aod_k = .4.*ones(size(am)); 
r =  .02.*randn(size(am)); r = 0;
aod_a = linspace(.35, .45, length(am));
aod_d = linspace(.45, .35, length(am));

I = Io.*exp(-(aod_k+tau_g+r).*am);
Ia = Io.*exp(-(aod_a+tau_g+r).*am);
Id = Io.*exp(-(aod_d+tau_g+r).*am);
Ir = Io.*exp(-(aod_k+r).*am);
Ira = Io.*exp(-(aod_a+r).*am);
Ird = Io.*exp(-(aod_d+r).*am);
figure; plot(am, I,'o',am, Ia,'o',am, Id,'o',am, Ir,'x',am, Ira,'x',am, Ird,'x'); logy

I = Io.*exp(-(aod_k+tau_g+r).*am); P_I = polyfit(am, log(I),1); P_Io = exp(P_I(2));
Ia = Io.*exp(-(aod_a+tau_g+r).*am); P_Ia = polyfit(am, log(Ia),1); P_Iao = exp(P_Ia(2)); 
Id = Io.*exp(-(aod_d+tau_g+r).*am); P_Id = polyfit(am, log(Id),1); P_Ido = exp(P_Id(2)); 
% When tau_g is known "perfectly" there is no difference between standard and refined
Ir = Io.*exp(-(aod_k+r).*am); P_Ir = polyfit(am, log(Ir),1); P_Iro = exp(P_Ir(2));
Ira = Io.*exp(-(aod_a+r).*am); P_Ira = polyfit(am, log(Ira),1); P_Irao = exp(P_Ira(2));
Ird = Io.*exp(-(aod_d+r).*am); P_Ird = polyfit(am, log(Ird),1); P_Irdo = exp(P_Ird(2));

figure; plot([1:length(am)],-log(I./P_Io)./am - tau_g,'o',[1:length(am)],-log(Ia./P_Iao)./am - tau_g,'o',...
   [1:length(am)],-log(Id./P_Ido)./am - tau_g,'o')

% Now, try the tau_lang by substituting am*tau for am
yk = aod_k+tau_g;
 P_It = polyfit(am.*yk, log(I),1); P_Ito = exp(P_It(2));
ya = aod_a +tau_g;
 P_Ita = polyfit(am.*ya, log(Ia),1); P_Itao = exp(P_Ita(2)); 
yd = aod_d+tau_g;
P_Itd = polyfit(am.*yd, log(Id),1); P_Itdo = exp(P_Itd(2)); 


% Combo 
ya = aod_a;
 P_Ita = polyfit(am.*ya, log(Ia)+tau_g.*am,1); P_Itao = exp(P_Ita(2)); 
yd = aod_d;
P_Itd = polyfit(am.*yd, log(Id)+tau_g.*am,1); P_Itdo = exp(P_Itd(2)); 


[Vo,tau,Vo_, tau_, good] = dbl_lang(am.*(aod_a),Ia.*exp(tau_g.*am),[],[],1,1);
[Vo,tau,Vo_, tau_, good] = dbl_lang(am.*(aod_d),Id.*exp(tau_g.*am),[],[],1,1);
% I can use dbl_lang for std, refined, and uw langs.  
% To use for refined, divide the "Y" (I) quantity by T_gas or equivalently multiply by exp(tau_gas * m)
% To use for tau_lang, multiply the "X" (am) quantity by tod (or aod while adding tau_g.*am to log(Y)