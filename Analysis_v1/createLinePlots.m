function createLinePlots(t,x,TFVTissue,TFVdpTissue,HIVTissue,cellsTissue,indE,indS,h_E,h_S) 

    %% PLOTTING VIRAL LOAD VS. TIME
    figure()
    VE_avg = trapz(HIVTissue(1:indE,:))/(indE-1)';
    VS_avg = trapz(HIVTissue(indE+1:end,:),1)/(indS-1)';
    VT_avg = (VE_avg*h_E+VS_avg*h_S)/(h_E+h_S);

    %plot(t,VT_avg*10^(-3),'LineWidth',2); %conversion virions/ml to virions/mg
    %hold on
    plot(t/24,VS_avg/(1.088*10^(3)),'LineWidth',2)
    %xlim([0,end])
    %axis([0 max(t)/3600 10^(-1) max(C(1,:))])
    %set(gca,'YScale','log');
    %axis([0 40 10^(0) 10^(7)])
    %legend('Tissue')
    title('Viral Load in Stroma vs. Time','FontSize',22,'FontWeight','Bold')
    xlabel('Time (days)','FontSize',20,'FontWeight','Bold')
    ylabel('Viral Load (virions/mg)','FontSize',20,'FontWeight','Bold')
    set(gca,'FontSize',18)
    ylim([0,max(VS_avg)/(1.088*10^(3))])
    %legend('Total in Tissue','Stroma')
    
    
    %% PLOTTING CELLS VS. TIME
    TT_avg = cellsTissue(:,1);
    LT_avg = cellsTissue(:,2);
    IT_avg = cellsTissue(:,3);
    figure()
    plot(t/24,[TT_avg,LT_avg,IT_avg],'LineWidth',2)
    ylim([0,max(max([TT_avg;LT_avg;IT_avg]))])
    %set(gca,'YScale','log');
    legend('Target','Latent', 'Infected')
    xlabel('Time (days)','FontSize',20,'FontWeight','Bold')
    ylabel('Cells (mg^{-1})','FontSize',20,'FontWeight','Bold')
    title('Cell density vs. time','FontSize',22,'FontWeight','Bold')
    set(gca,'FontSize',18)
    
end

