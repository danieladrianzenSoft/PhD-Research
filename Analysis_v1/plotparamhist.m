function plotparamhist(params,title) 

figure()
sgtitle(title)
subplot(2,2,1)
histogram(params.V_0)
ylabel('V_0')
subplot(2,2,2)
histogram(params.h_E)
ylabel('h_E')
% subplot(3,2,3)
% histogram(params.beta*24*3600)
% ylabel('beta')
subplot(2,2,3)
histogram(params.rho*24*3600)
ylabel('rho')
subplot(2,2,4)
histogram(params.k_B*24*3600)
ylabel('k_B')
