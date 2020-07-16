clear
clc

B_POI = readtable('B_POI.xlsx');

numInfected = sum(B_POI.infected);

POI = numInfected/size(B_POI,1)*100
