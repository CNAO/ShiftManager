%%

%% user options
employeeName="manzini";
masterExcelShifts="P:\Turni Macchina\turni dicembre-giugno 2025_ver1.xlsx";

%% parsing original excel
masterShifts=ParseMasterFile(masterExcelShifts);

%% crunch comments
% fprintf("checking that FM is never shift leader...\n")
% find(contains(lower(masterShifts.(8)),"recupero"))
if (isstring(employeeName))
    if (strcmpi(employeeName,"all") | strcmpi(employeeName,"tutti") )
        employeeNames=unique(lower(string(masterShifts{:,2:7})));
        employeeNames=employeeNames(strlength(employeeNames)>0);
    else
        employeeNames=[employeeName];
    end
else
    employeeNames=employeeName;
end

%% process
for ii=1:length(employeeNames)
    % - build table of employee
    employeeShifts=BuildEmployeeTable(masterShifts,employeeNames(ii));
    % - write csv file
    oFileName=sprintf("%s.csv",employeeNames(ii));
    writeGoogleCalendarCSV(employeeShifts,oFileName);
end

%% functions
function masterShifts=ParseMasterFile(masterExcelShifts)
    shiftNames=["morning shift","afternoon shift","night shift"];
    %
    fprintf("parsing master file %s ...\n",masterExcelShifts);
    masterShifts=readtable(masterExcelShifts);
    fprintf("...done: acquired %d lines and %d columns;\n",size(masterShifts,1),size(masterShifts,2));
    %
    fprintf("checking that FM is never shift leader...\n")
    for iCol=2:2:6
        indices=find(strcmpi(masterShifts.(iCol),"FM"));
        if (~isempty(indices))
            fprintf("...found it in %s %d times!\n",shiftNames(iCol/2),length(indices));
            [masterShifts.(iCol)(indices),masterShifts.(iCol+1)(indices)]=deal(masterShifts.(iCol+1)(indices),masterShifts.(iCol)(indices));
        end
    end
    fprintf("...done;");
end

function oNames=CapitalizeNames(iNames)
    oNames=lower(iNames);
    iFMs=strcmp(oNames,"fm");
    oNames(iFMs)="FM";
    oNames(~iFMs)=compose("%s%s",upper(extractBetween(oNames(~iFMs),1,1)),extractBetween(oNames(~iFMs),2,strlength(oNames(~iFMs))));
end

function employeeShifts=BuildEmployeeTable(masterShifts,employeeName)
    % preamble
    shiftHours=["06:00","14:00","14:00","22:00","22:00","06:00"];
    shiftDays=zeros(1,6); shiftDays(5:6)=1;
    shiftRoles=["shift leader","addetto sicurezza"];
    % do the job
    fprintf("looking for shifts of %s...\n",employeeName);
    employeeShifts=table();
    for iCol=2:7
        iTurni=strcmpi(employeeName,masterShifts.(iCol));
        nTurni=sum(iTurni);
        if (nTurni>0)
            % prepare info to store
            currDates=masterShifts.(1);
            currLen=size(employeeShifts,1);
            otherShifters=masterShifts.(iCol+(-1)^mod(iCol,2)); otherShifters=CapitalizeNames(string(otherShifters(iTurni)));
            % - subject
            employeeShifts.subjects(currLen+1:currLen+nTurni)=sprintf("Turno %s",shiftRoles(mod(iCol,2)+1));
            % - start dates and times:
            employeeShifts.startDates(currLen+1:currLen+nTurni)=currDates(iTurni);
            employeeShifts.startTimes(currLen+1:currLen+nTurni)=shiftHours(2*floor(iCol/2)-1);
            % - end dates and times:
            if (2*floor(iCol/2)==length(shiftHours))
                % shift ends the following day
                currEndDates=datenum(currDates(iTurni));
                for ii=1:length(currEndDates)
                    currEndDates(ii)=addtodate(currEndDates(ii),shiftDays(iCol-1),"day");
                end
                employeeShifts.endDates(currLen+1:currLen+nTurni)=datetime(currEndDates,"ConvertFrom","datenum");
            else
                employeeShifts.endDates(currLen+1:currLen+nTurni)=currDates(iTurni);
            end
            employeeShifts.endTimes(currLen+1:currLen+nTurni)=shiftHours(2*floor(iCol/2));
            % - descriptions
            employeeShifts.descriptions(currLen+1:currLen+nTurni)=compose("%s: %s",shiftRoles(mod(iCol-1,2)+1),otherShifters);
        end
    end
    % - sorting
    [~,IDs]=sort(employeeShifts.startDates);
    employeeShifts=employeeShifts(IDs,:);
    %
    fprintf("...found %d shifts!\n",size(employeeShifts,1));
end

function writeGoogleCalendarCSV(employeeShifts,oFileName)
    % - formatting
    employeeShifts.startDates.Format='yyyy-MM-dd';
    employeeShifts.endDates.Format='yyyy-MM-dd';
    headers=["Start Date","Start Time","End Date","End Time","Subject","Description"];
    % - do the actual job
    fprintf("preparing %s file for import into google calendar...\n",oFileName);
    nDataRows=size(employeeShifts,1);
    employTable=strings(nDataRows+1,length(headers));
    employTable(1,:)=headers;
    for ii=1:length(headers)
        switch headers(ii)
            case "Start Date"
                employTable(2:end,ii)=string(employeeShifts.startDates);
            case "Start Time"
                employTable(2:end,ii)=employeeShifts.startTimes;
            case "End Date"
                employTable(2:end,ii)=string(employeeShifts.endDates);
            case "End Time"
                employTable(2:end,ii)=employeeShifts.endTimes;
            case "Subject"
                employTable(2:end,ii)=employeeShifts.subjects;
            case "Description"
                employTable(2:end,ii)=employeeShifts.descriptions;
            otherwise
                error("Unknown header: %s",headers(ii));
        end
    end
    writematrix(employTable,oFileName);
    fprintf("...done;\n");
end