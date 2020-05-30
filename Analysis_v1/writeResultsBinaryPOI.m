function writeResultsBinaryPOI(params,infected,filenameResults,overwrite)

results = [params, table(infected,'VariableNames',{'infected'})];

if overwrite == 1
    writetable(results,filenameResults,'WriteMode','overwritesheet',...
    'WriteRowNames',true)
else
    writetable(results,filenameResults,'WriteMode','Append',...
    'WriteVariableNames',false,'WriteRowNames',true) 
end

end
