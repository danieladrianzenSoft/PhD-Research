
clear
clc

N=40;
overwrite = 1; 
tictocStep = 10;
runSims = 0;

%%testing this thing out

filenameParams = 'parameters.xlsx';
filenameResults = 'B_POI.xlsx';

if runSims == 1
    
    newparams = samplingNormalPOI_BinaryCR(filenameParams,N,overwrite);
    %params = readtable(filenameParams);

    infected = zeros(size(newparams,1),1);
    indexTicToc = 0;
    tictocTime = zeros(floor(size(newparams,1)/tictocStep)+1,1);
    
    for i = 1:size(newparams,1)
        if mod(i,tictocStep) == 0 || i == 1
            tic
        else

        end

        infected(i) = POI_BinaryCR_integrated(newparams(i,:), 0);

        if mod(i,tictocStep) == 0 || i == 1
            indexTicToc = indexTicToc + 1;
            tictocTime(indexTicToc) = toc;
            percentageDone = i/size(newparams,1)*100;
            totalTime = size(newparams,1)*mean(nonzeros(tictocTime));
            remainingTime = totalTime-i*mean(nonzeros(tictocTime));
            fprintf(' %.2f mins estimated total run time \n %.2fs per simulation \n %.2f%% done \n %.2f mins remaining \n\n',totalTime/60,mean(nonzeros(tictocTime)),percentageDone,remainingTime/60)
        else

        end
        
    end   
    
    totalSimTime = tictocTime*N;
    
    plotparamhist(newparams,'New Parameters')
    writeResultsBinaryPOI(newparams,infected,filenameResults,overwrite) 

end

params = readtable(filenameParams);
plotparamhist(params,'Complete Parameters')

resultsComplete = readtable(filenameResults);

positiveInfection = find(resultsComplete.infected==1);

% if ~isempty(positiveInfection)
%     paramsEVAL = params(positiveInfection(1),:);
%     makePlots = 1;
%     infected = POI_BinaryCR_integrated(paramsEVAL, makePlots)
% else
%     fprintf('\n No Infections \n')
% end

% if ~isempty(positiveInfection)
%     paramsEVAL = params(positiveInfection(1),:);
%     makePlots = 1;
%     infected = POI_BinaryCR_EVAL(paramsEVAL, makePlots)
% else
%     fprintf('\n No Infections \n')
% end

    V_0 = 5*10^4;
    h_E = 0.02;
    rho = 1400/(24*3600);
    k_B = 3/(24*3600);
    %beta = (0.65*10^(-6))/(24*3600);
    T_VD = 0;
    paramsEVAL = table(V_0,h_E,rho,k_B,T_VD);
    %paramsEVAL = table(V_0,h_E,beta,rho,k_B,T_VD);
    makePlots = 1;
    tic
    infected = POI_BinaryCR_integrated(paramsEVAL, makePlots)
    %infected = POI_BinaryCR_CollTest(paramsEVAL)
    toc

