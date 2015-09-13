function [p,iis] = load_p( file )
%LOAD_P Summary of this function goes here
%   Detailed explanation goes here

    fileID = fopen(file, 'r');
    
        I = fscanf(fileID, 'I[Techn.count]=%i\r\n');
        J = fscanf(fileID, 'J[Crit.count]=%i\r\n');
        R = fscanf(fileID, 'R[Val.count]=%i\r\n');
        
        p=ones(J,R,I)*(-2);
        iis=zeros(I,1);
        
        for i =1:I
            fscanf(fileID, '\r\n');
            if( feof(fileID) )
                break;
            end
            ii = fscanf(fileID, 'Technology #%ui\r\n');
if(ii==0) 
    error('smth wrong with techn index==0');
end
            iis(ii)=1;
            % ii <= 1..I: some techn may be not listed
            % I is the maximum amount of techn in a given case
            for j=1:J
                p(j,:,ii)=fscanf(fileID, '%f ', R);
                fscanf(fileID, '\r\n');
            end
        end
    
    fclose(fileID);

end

