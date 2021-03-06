
function infected = POI_BinaryCR_EVAL(params, makePlots)

T_0 = 10^(4);
I_0 = 0;
L_0 = 0;
V_0 = params.V_0;

%delay = -2 * (60 * 60);
%delay = params.T_VD;
delay = 0;
%C_G0 = (1 * 10^(7));
C_G0 = 0;
%V_0 = (1 * 10^(4)); %Virions / ml, Katz lectures XXXXXXXXXX
%V_0 = (1 * 10^(4));
%filename = 'POI_LongTerm.csv';

%%%%%% PARAMETERS %%%%%%

%%%VIRAL DYNAMICS
dt = 0.01/(24*3600); %s^(-1) death rate of target cells XXXXXXXXXX
%dt = 0.02/(24*3600);
lambda = dt*T_0;
%lambda = 10^(4)/(24*3600); %cells/mL/s production rate of target cells
%lambda = 100/(24*3600); %cells/ml/day
%rho = 1.5*10^(3)/(24*3600); %s^(-1) production rate of V from I
%rho = 850/(24*3600); 
rho = params.rho;
%rho = 1800/(24*3600); %XXXXXXXXX
%rho = 1*10^(3)/(24*3600); %s^(-1) production rate of V from I
%rho = 0;
%del = 0.5/(24*3600); %s^(-1) death rate of I.
%del = 0.80/(24*3600);
del = 0.39/(24*3600);  %s^(-1) death rate of I. XXXXXXXXXXXX
%beta = params.beta; 
%beta = (3.6*10^(-7))/(24*3600);
%beta = (6.5*10^(-7))/(24*3600); %XXXXXXXXXXXXX
%beta = 4*10^(-5)/(24*4600); %previously (6.5*10^(-7))/(24*3600);
%beta = 1/(24*4600);
%w = 10^(-3)/(24*3600); %s^(-1) per infected cell. Viral transmission
%(cell-cell) XXXXXXXXXX
w = 0;

%%%Latent cells:
%eta = 0.1; %fraction of infections that result in latency
%eta = 10^(-6);
eta = 0;
dl = 0.004/(24*3600); %death rate of latently infected cells
lambdal = 0.0045/(24*3600); %%NOT BEING USED RIGHT NOW
%a = 0.05/(24*3600); %transition rate of latent cells to productive infected cells.
%a = 10^(-3)/(24*3600);
a = 0;

%%%VIRAL TRANSPORT
%D_G = 1.27*10^(-8); %XXXXXXXX
D_G = 1.27*10^(-8);
%D_G = 6*10^(-6);
%D_E = 3*10^(-10); %previously 9x10^(-10)XXXXXXXXX
D_E = 7*10^(-11);
%D_E = 9*10^(-10);
%D_S = 2*10^(-9); %previously 2x10^(-9)XXXXXXXXXX
D_S = 5*10^(-9);
%D_S = params.D_vS;
%D_S = 4*10^(-7);
k_D = 0.28/3600;
%k_D = 1.22/3600; %XXXXXXXXXX
%k_D = 0.551/3600;
%k_b = 3/(24*3600);
k_b = params.k_B;
%k_b = 10/(24*3600); %previously 15
%k_b = 15/(24*3600); %XXXXXXXXXX
c = k_b; %s^(-1) elimination/clearance in tissue
%Partition coefficient V_T/V_G
%phiGE = 1;
%phiGE = ((1.49*10^(4))/(4*10^(6))); %Carias, Hope et al. 2013;
phiGE = 0.3; %Hope et al, 2015. In Macaques, and Humans
phiES = 1;

%%%TFV TRANSPORT
Dd_G = 6*10^(-6);
%D_G = 3.72*10^(-6);
%D_E = 5.73*10^(-8);
%D_E = 5*10^(-8);
Dd_E = 7*10^(-8);
%D_S = 5.73*10^(-9);
%D_S = 3.31*10^(-7); %Diffusion coefficient in stroma, from Chapter 5.
%D_S = 5*10^(-8);
Dd_S = 4*10^(-7);%
phid_GE = 0.75; 
phid_ES = 1;
%k_b = 0;
kd_D = 1.22/3600;
kd_B = 0.119/3600;
%kd_B = 100/3600;
kd_L = 1.41/3600;
Vb = 75*1000;
 
%%%TTF-DP PRODUCTION:
Kon = log(2)/3600;
Koff = log(2)/(7*24*3600);
r = 0.1;
%These are volume fractions, not partition coefficients:
phiDP_E = 0.95;
phiDP_S = 0.1;

%Spatial and time constraints
h_G = 0.04; %cm
%h_E = 0.02; %cm
h_E = params.h_E;
h_S = 0.28; %cm

W = 3.35;
L = 13;
%V = 4;

numx = 1000;

indG  = ceil((h_G/(h_G+h_E+h_S))*numx);
indE  = ceil(((h_G + h_E) / (h_G + h_E + h_S)) * numx) - ...
       (ceil((h_G / (h_G + h_E + h_S) * numx)));
indS  = numx-(indG+indE);

realx = [linspace(0,h_G,indG), linspace(h_G+(h_E/indE), h_G+h_E,indE) ...
         linspace(h_G+h_E+(h_S/indS), h_G+h_E+h_S, indS)];

%Virus: Gel, Epi, Stro, 
%Target cells: Stro, 
%Latent cells: Stro,
%Infected cells: Stro
%TFV: Gel, Epi, Stro
%TFV-DP: Epi, Stro

totLength = h_G+h_E+h_S;

x = [realx,totLength+realx,2*totLength+realx(indG+1:indG+indE+indS)-realx(indG)];

S = calcsparsity(x,numx,indG,indE,indS);
S = sparse(S);

opts1 = odeset('JPattern',S);

finalT = 300*24*60*60; %100 days
numT = 5000;
%tau_0 = 13*24*60*60; %intracellular delay
tau_0 = 0;

if (C_G0 == 0)
    
    t = linspace(0,finalT,numT);
    tspan = [min(t),max(t)];
    
    IC = [V_0.*ones(1,indG) 0.*ones(1,indE) 0.*ones(1,indS)... %virions
        C_G0.*ones(1,indG) 0.*ones(1,indE) 0.*ones(1,indS)... %TFV ng/ml
        0.*ones(1,indE) 0.*ones(1,indS),... %TFV-DP
        T_0 L_0 I_0]; %cells (target, latent, infected)

    
    %tic
    [t,V] = ode15s(@(t,V) dvdt(t,V,x,realx,h_G,h_E,h_S,indG,indE,indS,numx,W,L,... %Geometry
            D_G,D_E,D_S,k_D,k_b,phiGE,phiES,... %Viral Transport
            lambda,dt,rho,c,del,w,eta,lambdal,dl,a,T_0,... %Viral Dynamics
            Dd_G,Dd_E,Dd_S,phid_GE,phid_ES,kd_D,kd_B,kd_L,Vb,... %TFV Transport
            Kon, Koff,r, phiDP_E,phiDP_S,tau_0), t, IC,opts1); %TFV-DP production
    
    %toc
    
    V = V';
    
elseif (delay == 0 && C_G0 ~=0)


    h_G1 = 2*h_G; 
    C_G01 = C_G0/2;
    V_01 = V_0/2;
%     h_G1 = h_G;
%     C_G01 = C_G0;
%     V_01 = V_0;
    
    IC = [V_01.*ones(1,indG) 0.*ones(1,indE) 0.*ones(1,indS)... %virions
        C_G01.*ones(1,indG) 0.*ones(1,indE) 0.*ones(1,indS)... %TFV ng/ml
        0.*ones(1,indE) 0.*ones(1,indS),... %TFV-DP
        T_0 L_0 I_0]; %cells (target, latent, infected)
    t = linspace(delay,finalT,numT);
    tspan = [min(t),max(t)];

    %tic
    [t,V] = ode15s(@(t,V) dvdt(t,V,x,realx,h_G1,h_E,h_S,indG,indE,indS,numx,W,L,... %Geometry
            D_G,D_E,D_S,k_D,k_b,phiGE,phiES,... %Viral Transport
            lambda,dt,rho,c,del,w,eta,lambdal,dl,a,T_0,... %Viral Dynamics
            Dd_G,Dd_E,Dd_S,phid_GE,phid_ES,kd_D,kd_B,kd_L,Vb,... %TFV Transport
            Kon, Koff,r, phiDP_E,phiDP_S,tau_0), t, IC,opts1); %TFV-DP production
    %toc
    
    V = V';

elseif (delay < 0 && C_G0 ~=0)
    
    h_G1 = h_G; 
    C_G01 = C_G0;
    
    t1 = linspace(0,-1*delay,numT);
    tspan1 = [min(t1),max(t1)];

    IC1 = [0.*ones(1,indG) 0.*ones(1,indE) 0.*ones(1,indS)... %virions
        C_G01.*ones(1,indG) 0.*ones(1,indE) 0.*ones(1,indS)... %TFV ng/ml
        0.*ones(1,indE) 0.*ones(1,indS),... %TFV-DP
        T_0 L_0 I_0]; %cells (target, latent, infected)
    
    [t1,V1] = ode15s(@(t1,V1) dvdt(t1,V1,x,realx,h_G1,h_E,h_S,indG,indE,indS,numx,W,L,... %Geometry
        D_G,D_E,D_S,k_D,k_b,phiGE,phiES,... %Viral Transport
        lambda,dt,rho,c,del,w,eta,lambdal,dl,a,T_0,... %Viral Dynamics
        Dd_G,Dd_E,Dd_S,phid_GE,phid_ES,kd_D,kd_B,kd_L,Vb,... %TFV Transport
        Kon, Koff,r, phiDP_E,phiDP_S,tau_0), t1, IC1,opts1); %TFV-DP production
    
    %Later, semen deposition, so h_G to 0.08cm, and 1:1 dilution -> C_G/2, V_0/2
    V_01 = V_0/2;
    h_G1 = 2*h_G; 
%     V_01 = V_0;
%     h_G1 = h_G;

    IC = [V_01.*ones(1,indG) 0.*ones(1,indE) 0.*ones(1,indS)... %virions
        V1(end,numx+1:numx+indG) V1(end,numx+indG+1:numx+indG+indE+indS)... %TFV ng/ml
        V1(end,numx+indG+indE+indS+1:numx+indG+indE+indS+indE+indS),... %TFV-DP
        T_0 L_0 I_0]; %cells (target, latent, infected)
    
    %t2 = linspace(-1*delay,finalT,numT/2);
    t2 = linspace(0,finalT,numT);

    tspan = [min(t2),max(t2)];

    %tic
    [t2,V] = ode15s(@(t2,V) dvdt(t2,V,x,realx,h_G1,h_E,h_S,indG,indE,indS,numx,W,L,... %Geometry
             D_G,D_E,D_S,k_D,k_b,phiGE,phiES,... %Viral Transport
             lambda,dt,rho,c,del,w,eta,lambdal,dl,a,T_0,... %Viral Dynamics
             Dd_G,Dd_E,Dd_S,phid_GE,phid_ES,kd_D,kd_B,kd_L,Vb,... %TFV Transport
             Kon, Koff,r, phiDP_E,phiDP_S,tau_0), t2, IC,opts1); %TFV-DP production
    %toc
    
    %V = [V1;V]';
    %t = [t1;t2];
    V = V';
    t = t2;

elseif (delay > 0 && C_G0 ~= 0)
    
    h_G1 = h_G; 
    V_01 = V_0;
    
    ratio = 1/10;
    
    t1 = linspace(0,delay,numT*ratio);
    %numT*ratio
    %(1-ratio)*numT
    tspan1 = [min(t1),max(t1)];
    
    IC1 = [V_01.*ones(1,indG) 0.*ones(1,indE) 0.*ones(1,indS)... %virions
        0.*ones(1,indG) 0.*ones(1,indE) 0.*ones(1,indS)... %TFV ng/ml
        0.*ones(1,indE) 0.*ones(1,indS),... %TFV-DP
        T_0 L_0 I_0]; %cells (target, latent, infected)

    [t1,V1] = ode15s(@(t1,V1) dvdt(t1,V1,x,realx,h_G1,h_E,h_S,indG,indE,indS,numx,W,L,... %Geometry
        D_G,D_E,D_S,k_D,k_b,phiGE,phiES,... %Viral Transport
        lambda,dt,rho,c,del,w,eta,lambdal,dl,a,T_0,... %Viral Dynamics
        Dd_G,Dd_E,Dd_S,phid_GE,phid_ES,kd_D,kd_B,kd_L,Vb,... %TFV Transport
        Kon, Koff,r, phiDP_E,phiDP_S,tau_0), t1, IC1,opts1); %TFV-DP production
    C_G01 = C_G0/2;
    h_G1 = h_G*2; 
%     h_G1 = h_G;
%     C_G01 = C_G0;
    
    IC = [V1(end,1:indG) V1(end,indG+1:numx)... %virions
        C_G01.*ones(1,indG) 0.*ones(1,indE) 0.*ones(1,indS)... %TFV ng/ml
        0.*ones(1,indE) 0.*ones(1,indS),... %TFV-DP
        T_0 L_0 I_0]; %cells (target, latent, infected)
    
    t2 = linspace(delay,finalT,(1-ratio)*numT);
    tspan2 = [min(t2),max(t2)];

    %tic
    [t2,V] = ode15s(@(t2,V) dvdt(t2,V,x,realx,h_G1,h_E,h_S,indG,indE,indS,numx,W,L,... %Geometry
            D_G,D_E,D_S,k_D,k_b,phiGE,phiES,... %Viral Transport
            lambda,dt,rho,c,del,w,eta,lambdal,dl,a,T_0,... %Viral Dynamics
            Dd_G,Dd_E,Dd_S,phid_GE,phid_ES,kd_D,kd_B,kd_L,Vb,... %TFV Transport
            Kon, Koff,r, phiDP_E,phiDP_S,tau_0), t2, IC,opts1); %TFV-DP production
    %toc
    
    V = [V1;V]';
    t = [t1;t2];
    
end

%CALCULATING MICROBICIDE EFFICACY Q

%Original data from 
TFVDPPotency = load('TFVDP_Potency.txt');
smoothTFVDPPotency = smooth(TFVDPPotency(:,1),TFVDPPotency(:,2),200,'rloess');
ConcX = log10(10.^(TFVDPPotency(:,1))*(10^(6)/180)); %4.9917*10^3 10^6cells / mL tissue  = 4.9917 10^6cells / mg tissue. 
                                               %Assuming: density tissue = 1000mg/mL. Conversion from Schwartz et al.
                                               %fmol/10^6 cells to fmol/mg tissue
ConcX = log10(10.^(TFVDPPotency(:,1))*(T_0/(10^(6))));
%ConcX = log10(10.^(TFVDPPotency(:,1))*4.9917*10^(-2));
                     
f = fit(ConcX,smoothTFVDPPotency,'fourier8');
fvals = f.a0 + f.a1*cos(ConcX*f.w) + f.b1*sin(ConcX*f.w) + ... %Fit for concentration in units of log10 fmol/mg tissue
        f.a2*cos(2*ConcX*f.w) + f.b2*sin(2*ConcX*f.w) + ...
        f.a3*cos(3*ConcX*f.w) + f.b3*sin(3*ConcX*f.w) + ...
        f.a4*cos(4*ConcX*f.w) + f.b4*sin(4*ConcX*f.w) + ...
        f.a5*cos(5*ConcX*f.w) + f.b5*sin(5*ConcX*f.w) + ...
        f.a6*cos(6*ConcX*f.w) + f.b6*sin(6*ConcX*f.w) + ...
        f.a7*cos(7*ConcX*f.w) + f.b7*sin(7*ConcX*f.w) + ...
        f.a8*cos(8*ConcX*f.w) + f.b8*sin(8*ConcX*f.w);
maxPotf = min(fvals);
minPotf = max(fvals);
maxConcf = max(ConcX);
minConcf = min(ConcX);

%[qtemp,Pottemp] = PotCalc(ConcX,f,maxPotf,minPotf,maxConcf,minConcf);

%Drug
%CTFV = V(1:ng+ne+ns,:);
%CTFVDP = [zeros(ng,length(t2));C(ng+ne+ns+1:ng+ne+ne+ns+ns,:)];
Cg = V(numx:numx+indG,:);
Ce = V(numx+indG+1:numx+indG+indE,:);
Cs = V(numx+indG+indE+1:numx+indG+indE+indS,:);
Cdpe = V(numx+indG+indE+indS+1:numx+indG+indE+indS+indE,:);
Cdps = V(numx+indG+indE+indS+indE+1:numx+indG+indE+indS+indE+indS,:);
Cdps_FM = (Cdps/447.173)*10^(3);
%Ct = C(ng+1:ng+ne+ns,:);
CG_avg = trapz(Cg)/(indG-1);
CE_avg = trapz(Ce)/(indE-1);
CS_avg = trapz(Cs)/(indS-1);
CDP_Eavg = trapz(Cdpe)/(indE-1);
CDP_Savg = trapz(Cdps)/(indS-1);
CDP_SavgFM = (CDP_Savg/447.173)*10^(3); %from ng/ml to fmol/mg
CDP_Tavg = (CDP_Eavg*h_E+CDP_Savg*h_S)/(h_E+h_S);
CT_avg = (CE_avg*h_E+CS_avg*h_S)/(h_E+h_S);

[q,P] = PotCalc(log10(Cdps_FM),f,maxPotf,minPotf,maxConcf,minConcf);

%Virions & Cells
%Virions & Cells
vir = V(1:numx,:);
tar = V((numx+indG+indE+indS)+indE+indS+1,:);
%size(q)
%size(V(numx+1:numx+indS,:))
tarDr = (1-q).*V((numx+indG+indE+indS)+indE+indS+1,:);
lat = V((numx+indG+indE+indS)+indE+indS+2,:);
inf = V((numx+indG+indE+indS)+indE+indS+3,:); 
Vg = V(1:indG,:);
Ve = V(indG+1:indG+indE,:);
Vs = V(indG+indE+1:numx,:);
Vt = V(indG+1:indG+indE+indS,:);

TT_avg = tar';
LT_avg = lat';
IT_avg = inf';

% collisionsVC_t= 0.03*4*pi*W*L*(Rc+Rv)*D_S*collisionsVCIntX;
% collisionsVC_cum = 0.03*4*pi*W*L*(Rc+Rv)*D_S*cumtrapz(t,collisionsVCIntX);
% collisionsMC_t = 4*pi*W*L*(Rc+Rm)*Dd_S*collisionsMCIntX;
% collisionsMC_cum = 4*pi*W*L*(Rc+Rm)*Dd_S*cumtrapz(t,collisionsMCIntX);

%collisionsTest2 = cumtrapz(t,collisionsX);
%A = 4*pi*W*L*(Rc+Rv)*D_S
%At = 4*pi*(Rc+Rv)*D_S
VG_avg = (trapz(Vg,1)/(indG-1))';
VE_avg = (trapz(Ve,1)/(indE-1))';
VS_avg = (trapz(Vs,1)/(indS-1))';
VT_avg = (VE_avg*h_E+VS_avg*h_S)/(h_E+h_S);

if makePlots == 1
    realxTissue = realx(indG+1:indG+indE+indS)-0.04;
    TFVdpTissue = V(numx+indG+indE+indS+1:numx+indG+indE+indS+indE+indS,:);
    TFVTissue = V(numx+indG+1:numx+indG+indE+indS,:);
    HIVTissue = V(indG+1:indG+indE+indS,:)+10^(-12);
    cellsTissue = [TT_avg,LT_avg,IT_avg];
    createLinePlots(t/3600,realxTissue,TFVTissue,TFVdpTissue,HIVTissue,cellsTissue,indE,indS,h_E,h_S);
    createHeatmap(t/3600,realxTissue,TFVdpTissue,HIVTissue,h_E,h_S)
end

grad = gradient(VT_avg,t);

%VT_avg(end) <= 0.1

    %if (grad(end) <= 10^10 && VT_avg(end) <= 0.005*max(VT_avg))
    if (grad(end) <= 10^(-10) && VS_avg(end)<=1)
        infected = 0;
    else
        infected = 1;
    end


end

function DVDT = dvdt(t,V,x,realx,h_G,h_E,h_S,indG,indE,indS,numx,W,L,... %Geometry
        D_G,D_E,D_S,k_D,k_b,phiGE,phiES,... %Viral Transport
        lambda,dt,rho,c,del,w,eta,lambdal,dl,a,T_0,... %Viral Dynamics
        Dd_G,Dd_E,Dd_S,phid_GE,phid_ES,kd_D,kd_B,kd_L,Vb,... %TFV Transport
        Kon, Koff,r, phiDP_E,phiDP_S,tau_0) %TFV-DP production

%NOTE: TO UNDERSTAND THESE EQUATIONS, LOOK UP FOR DIFFERENCE EQUATIONS: CENTRAL, BACKWARD
%AND FORWARD.

m = 1;

dxG = x(2)-x(1);
dxE = x(indG+3)-x(indG+2);
dxS = x(indG+indE+3)-x(indG+indE+2);

%HIV INTERFACE
V_intf1a = (D_G.*V(indG)+(D_E.*V(indG+1)))./((D_E.*phiGE)+D_G); %C at gel/tissue interface
V_intf1b = (D_G.*V(indG)+(D_E.*V(indG+1)))./((D_G./phiGE)+D_E);
V_intf2a = (D_E.*V(indG+indE)+(D_S.*V(indG+indE+1)))./((D_S.*phiES)+D_E); %C at gel/tissue interface
V_intf2b = (D_E.*V(indG+indE)+(D_S.*V(indG+indE+1)))./((D_E./phiES)+D_S);

%DRUG INTERFACE
C_intf_GEa = (Dd_G.*V(numx+indG)+(Dd_E.*V(numx+indG+1)))./((Dd_E.*phid_GE)+Dd_G); %Right before interface
C_intf_GEb = (Dd_G.*V(numx+indG)+(Dd_E.*V(numx+indG+1)))./((Dd_G./phid_GE)+Dd_E); %Right after interface
C_intf_ESa = (Dd_E.*V(numx+indG+indE)+(Dd_S.*V(numx+indG+indE+1)))./((Dd_S.*phid_ES)+Dd_E); %Right before interface
C_intf_ESb = (Dd_E.*V(numx+indG+indE)+(Dd_S.*V(numx+indG+indE+1)))./((Dd_E./phid_ES)+Dd_S); %Right after interface

dVdt = zeros(length(t),length(x));
dVdx = zeros(1,length(x));
d2Vdx2 = zeros(1,length(x));

%cellInfections = [1,2,3,4,5];

%% VIRUS

for i = 1 %y direction BC zero flux (dcdx=0)
    dVdt(:,i) = 2*D_G.*(V(i+1,:)-V(i,:))./(dxG.^2);
    %dVdt(i) = 2*D_G.*(V(i+1)-V(i))./(dx.^2);
end
for i = 2:indG-1 %in gel
    dVdx(i) = (V(i+1,:)-V(i,:))./dxG;
    d2Vdx2(i) = (V(i+1,:)-2.*V(i,:)+V(i-1,:))./(dxG.^2);
    dVdt(:,i) = D_G.*d2Vdx2(i)-(k_D.*V(i,:));
end
for i = indG %right before interface - gel
    dVdx(i) = (V_intf1a - V(i,:))./dxG;
    d2Vdx2(i) = (V(i-1,:)-2.*V(i,:)+V_intf1a)./(dxG.^2);
    dVdt(:,i) = D_G.*d2Vdx2(i)-(k_D.*V(i,:));
end
for i = (indG+1) %right after interface -in epithelium
    dVdx(i) = (V(i+1,:)-V(i,:))./dxE;
    d2Vdx2(i) = ((V_intf1b)-2.*V(i,:)+V(i+1,:))./(dxE.^2);
    dVdt(:,i) = D_E.*d2Vdx2(i);

end
for i = (indG+2):(indG+indE)-1 %in epithelium
    dVdx(i) = (V(i+1,:)-V(i,:))./dxE;
    d2Vdx2(i) = (V(i+1,:)-2.*V(i,:)+V(i-1,:))./(dxE.^2);
    dVdt(:,i) = D_E.*d2Vdx2(i);
end  
for i = indG+indE %right before interface - epithelium,stroma
    dVdx(i) = (V_intf2a-V(i,:))./dxE;
    d2Vdx2(i) = (V(i-1,:)-2.*V(i,:)+V_intf2a)./(dxE.^2);
    dVdt(:,i) = D_E.*d2Vdx2(i);
end  
for i = (indG+indE+1) %right after interface -in stroma
    dVdx(i) = (V(i+1,:)-V(i,:))./dxS;
    d2Vdx2(i) = ((V_intf2b)-2.*V(i,:)+V(i+1,:))./(dxS.^2);
    dVdt(:,i) = D_S.*d2Vdx2(i) - k_b.*V(i,:) + rho*V((numx+indG+indE+indS)+indE+indS+3,:)/(W*L*h_S);
    %dVdt(i) = D_S.*d2Vdx2(i) - k_b.*V(i);

end
for i = (indG+indE+2):numx-1 %in stroma
    dVdx(i) = (V(i+1,:)-V(i,:))./dxS;
    d2Vdx2(i) = (V(i+1,:)-2.*V(i,:)+V(i-1,:))./(dxS.^2);
    dVdt(:,i) = D_S.*d2Vdx2(i) - k_b.*V(i,:) + rho*V((numx+indG+indE+indS)+indE+indS+3,:)/(W*L*h_S);
    %dVdt(i) = D_S.*d2Vdx2(i) - k_b.*V(i);

end  
for i = numx%end of tissue
    %dCdt(i) = D_T.*(C(i)-2.*C(i-1))./(dx.^2) - k_b.*C(i); %BC zero conc
    %dCdt(i) = D_T.*(-2*C(i)+C(i-1))./(dx.^2) - k_b.*C(i); %BC zero conc CORRECT
    %dVdt(i) = 2*D_T*(V(i-1)-V(i))./(dx.^2) - k_b.*V(i); %BC zero flux
    %dVdt(:,i) = 2*D_S*(V(i-1,:)-V(i,:))./(dxS.^2) - k_b.*V(i,:) + rho*V((numx+indG+indE+indS)+indE+indS+3,:)/indS; %BC zero flux
    dVdt(:,i) = 2*D_S*(V(i-1,:)-V(i,:))./(dxS.^2); %BC zero flux
    %dVdt(i) = 2*D_S*(V(i-1)-V(i))./(dx.^2) - k_b.*V(i); %BC zero flux
end
%% TFV
for i = numx+1 %TFV at x = 0, zero flux B.C.
    %dVdt(i) = 2*Dd_G.*(V(i+1,:)-V(i,:))./(dxG.^2)-(kd_D.*V(i,:));
    %dVdt(i) = 2*Dd_G.*(V(i+1,:)-V(i,:))./(dxG.^2)-(kd_D.*V(i,:));
    dVdt(i) = 2*Dd_G.*(V(i+1,:)-V(i,:))./(dxG.^2);
end
for i = numx+2:numx+indG-1 %TFV in gel
    dVdx(i) = (V(i+1,:)-V(i,:))./dxG;
    d2Vdx2(i) = (V(i+1,:)-2.*V(i,:)+V(i-1,:))./(dxG.^2);
    dVdt(:,i) = Dd_G.*d2Vdx2(i)-(kd_D.*V(i,:));
end
for i = numx+indG %right before interface - gel/epithelium
    dVdx(i) = (C_intf_GEa - V(i,:))./dxG;
    d2Vdx2(i) = (V(i-1,:)-2.*V(i,:)+C_intf_GEa)./(dxG.^2);
    dVdt(:,i) = Dd_G.*d2Vdx2(i)-(kd_D.*V(i,:));
end

for i = (numx+indG+1) %right after interface - gel/epithelium
    dVdx(i) = (V(i+1,:)-V(i,:))./dxE;
    d2Vdx2(i) = ((C_intf_GEb)-2.*V(i,:)+V(i+1,:))./(dxE.^2);
    dVdt(:,i) = Dd_E.*d2Vdx2(i);
end
for i = (numx+indG+2):(numx+indG+indE-1) %in epithelium
    dVdx(i) = (V(i+1,:)-V(i,:))./dxE;
    d2Vdx2(i) = (V(i+1,:)-2.*V(i,:)+V(i-1,:))./(dxE.^2);
    dVdt(:,i) = Dd_E.*d2Vdx2(i);
end  
for i = numx+indG+indE %right before interface - epithelium/stroma
    dVdx(i) = (C_intf_ESa - V(i,:))./dxS;
    d2Vdx2(i) = (V(i-1,:)-2.*V(i,:)+C_intf_ESa)./(dxS.^2);
    dVdt(:,i) = Dd_E.*d2Vdx2(i);
end
for i = numx+indG+indE+1 %right after interface - epithelium/stroma
    dVdx(i) = (V(i+1,:)-V(i,:))./dxS;
    d2Vdx2(i) = ((C_intf_ESb)-2.*V(i,:)+V(i+1,:))./(dxS.^2);
    dVdt(:,i) = Dd_S.*d2Vdx2(i)- kd_B.*V(i,:);
end
for i = numx+indG+indE+2:numx+indG+indE+indS-1 %in stroma
    dVdx(i) = (V(i+1,:)-V(i,:))./dxS;
    d2Vdx2(i) = (V(i+1,:)-2.*V(i,:)+V(i-1,:))./(dxS.^2);  
    dVdt(:,i) = Dd_S.*d2Vdx2(i)- kd_B.*V(i,:);
end  
for i = (numx+indG+indE+indS)%end of stroma
    %dCdt(i) = D_S.*(C(i)-2.*C(i-1))./(dx_S.^2) - k_B.*C(i); %BC zero conc
    %dCdt(i) = D_S.*(-2*C(i)+C(i-1))./(dx.^2) - k_B.*C(i); %BC zero conc CORRECT
    %dVdt(:,i) = 2*Dd_S*(V(i-1,:)-V(i,:))./(dxS.^2) - kd_B.*V(i,:); %BC zero flux
    dVdt(:,i) = 2*Dd_S*(V(i-1,:)-V(i,:))./(dxS.^2); %BC zero flux
end

%% TFV-DP

for i = (numx+indG+indE+indS)+1:(numx+indG+indE+indS)+indE %in epithelium
    bracks = (V(i-indE-indS,:)*phiDP_E-V(i,:)/r);
    if bracks < 0
        bracks = 0;
    end
    dVdt(:,i) = Kon*bracks-Koff*V(i,:);
    
end
for i = (numx+indG+indE+indS)+indE+1:(numx+indG+indE+indS)+indE+indS %in stroma
    bracks = (V(i-indE-indS,:)*phiDP_S-V(i,:)/r);
    if bracks < 0
        bracks = 0;
    end
    dVdt(:,i) = Kon*bracks-Koff*V(i,:);
end

%%%%TENOFOVIR CORRECTION DUE TO TENOFOVIR DIPHOSPHATE CONVERSION

dVdt(:,(numx+indG+1):(numx+indG+indE)) = dVdt(:,numx+indG+1:numx+indG+indE) - dVdt(:,(numx+indG+indE+indS)+1:(numx+indG+indE+indS)+indE); %in epithelium
dVdt(:,(numx+indG+indE+1):(numx+indG+indE+indS)) = dVdt(:,numx+indG+indE+1:numx+indG+indE+indS) - dVdt(:,(numx+indG+indE+indS)+indE+1:(numx+indG+indE+indS)+indE+indS); %in stroma
%dCdt(1:ng) = 0;

Rc = 10*10^(-4)/2; %diameter = 10um
Rv = 100*10^(-7)/2; %diameter = 100nm
perCollisionsInfection = 1/8;

Vs = V(indG+indE+1:numx,:);
tar = V((numx+indG+indE+indS)+indE+indS+1,:);
inf = V((numx+indG+indE+indS)+indE+indS+3,:);

collisionsVCIntX = tar*(trapz(Vs,1))/(indS-1)';
%collisionsVCIntX = tar*(trapz(realx(indG+indE+1:end),Vs))';
collisionsVC_t= 4*pi*(Rc+Rv)*(D_S)*collisionsVCIntX;
cellInfections = perCollisionsInfection*collisionsVC_t;
%collisionsCC_t = 4*pi*W*L*(Rc+Rc)*(10^-5)*tar*inf;


for i = (numx+indG+indE+indS)+indE+indS+1 %target cells
    
    %dVdt(:,i) = lambda-dt*V(i,:)-beta*V(i,:).*V(i-indS,:);
    %dVdt(:,i) = lambda-dt*V(i,:)-cellInfections-collisionsCC_t;
    dVdt(:,i) = lambda-dt*V(i,:)-cellInfections;

end
for i = (numx+indG+indE+indS)+indE+indS+2 %latent cells
    
    %dVdt(:,i) = eta*beta*V(i-indS,:).*V(i-indS-indS,:)-dl*V(i,:)-a*V(i,:);
    dVdt(:,i) = eta*cellInfections-dl*V(i,:)-a*V(i,:);

end
for i = (numx+indG+indE+indS)+indE+indS+3 %infected cells
    %dVdt(i) = beta*V(i-ind2-ind2).*V(i-ind2-ind2-ind2)-del*V(i);
    %if t<tau_0
        %dVdt(:, i) = (1-eta)*beta*V(i-indS-indS,:).*V(i-indS-indS-indS,:)-del*V(i,:)+a*V(i-indS,:);
        %dVdt(:, i) = (1-eta)*cellInfections+collisionsCC_t-del*V(i,:)+a*V(i-1,:);
    dVdt(:, i) = (1-eta)*cellInfections-del*V(i,:)+a*V(i-1,:);

    %else
     %   dVdt(:, i) = (1-eta)*cellInfections-del*V(i,:)+a*V(i-1,:);
        %dVdt(:, i) = (1-eta)*beta*V(i-indS-indS,:).*V(i-indS-indS-indS,find(t>=t-tau_0,1)).*exp(-m*tau_0)-del*V(i,:)+a*V(i-indS,:);
    %end
end

DVDT = dVdt';

end

function [q,pot] = PotCalc(C,fnxn,maxpot,minpot,maxconc,minconc)

temppot = fnxn.a0 + fnxn.a1*cos(C*fnxn.w) + fnxn.b1*sin(C*fnxn.w) + ...
          fnxn.a2*cos(2*C*fnxn.w) + fnxn.b2*sin(2*C*fnxn.w) + ...
          fnxn.a3*cos(3*C*fnxn.w) + fnxn.b3*sin(3*C*fnxn.w) + ...
          fnxn.a4*cos(4*C*fnxn.w) + fnxn.b4*sin(4*C*fnxn.w) + ...
          fnxn.a5*cos(5*C*fnxn.w) + fnxn.b5*sin(5*C*fnxn.w) + ...
          fnxn.a6*cos(6*C*fnxn.w) + fnxn.b6*sin(6*C*fnxn.w) + ...
          fnxn.a7*cos(7*C*fnxn.w) + fnxn.b7*sin(7*C*fnxn.w) + ...
          fnxn.a8*cos(8*C*fnxn.w) + fnxn.b8*sin(8*C*fnxn.w);
  
      pot = minpot*(C<=minconc)+maxpot*(C>=maxconc)+temppot.*(C>minconc & C<maxconc);
      pot(C<=0) = minpot;

      q = 1-((pot-maxpot)/(minpot-maxpot));

end


function S = calcsparsity(x,numx,indG,indE,indS)

%totalSize = (2*numx)+(indS*4)+indE;
totalSize = 2*numx+indE+indS+3;
B = ones(totalSize,totalSize);
S = ones(totalSize,totalSize);

end
