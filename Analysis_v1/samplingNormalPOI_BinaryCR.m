function newparams = samplingNormalPOI_BinaryCR(filename,N,C0,DVdelay,overwrite)

%Viral Load (V_0)

mu = 1.5*10^(4);
sigma = 2*10^(4);

pd = makedist('Normal',mu,sigma);
t=truncate(pd,400,inf);
V_0 = random(t,N,1);

%Epithelium Thickness (h_E)

mu = 0.02; %cm
sigma = 0.01;

pd = makedist('Normal',mu,sigma);
t=truncate(pd,0.005,inf);
h_E = random(t,N,1);

%Infectivity (beta = k)

% mu = ((0.65*10^(-6))/(24*3600))/10; %cm^3 virion / s
% sigma = (1.4*10^(-6)/(24*3600))/5;
% 
% pd = makedist('Normal',mu,sigma);
% t=truncate(pd,0.1*10^(-6)/(24*3600),5*10^(-6)/(24*3600));
% beta = random(t,N,1);

%Production rate of V from I (rho = pi)

mu = (850/(24*3600)); %virion / s
sigma = (2000/(24*3600));

pd = makedist('Normal',mu,sigma);
t=truncate(pd,20/(24*3600),inf);
rho = random(t,N,1);

%clearance rate (k_B = c)

mu = 26/(24*3600); 
sigma = 10/(24*3600);

pd = makedist('Normal',mu,sigma);
t=truncate(pd,3/(24*3600),36/(24*3600));
k_B = random(t,N,1);

% %HIV Diffusion coefficient D_vS 
% 
% mu = 5*10^(-9); 
% sigma = 3*10^(-9);
% 
% pd = makedist('Normal',mu,sigma);
% t=truncate(pd,1*10^(-10),inf);
% D_vS = random(t,N,1);

%Initial Drug Concentration

C_G0 = C0*ones(N,1);

%Drug application vs HIV exposure delay T_VD 

T_VD = DVdelay*ones(N,1);


newparams = table(V_0,h_E,rho,k_B,C_G0,T_VD);

if overwrite == 1
    writetable(newparams,filename,'WriteMode','overwritesheet',...
    'WriteRowNames',true)
else
    writetable(newparams,filename,'WriteMode','Append',...
    'WriteVariableNames',false,'WriteRowNames',true) 
end

