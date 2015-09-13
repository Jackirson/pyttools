function save_p( file, p, iis )
%SAVE_P Summary of this function goes here
%   Detailed explanation goes here
        [J,R,I] = size(p);
        
        fileID = fopen(file,'w');
        fprintf(fileID, 'I[Techn.count]=%i\r\n', I);
        fprintf(fileID, 'J[Crit.count]=%i\r\n', J);
        fprintf(fileID, 'R[Val.count]=%i\r\n', R);
        
        for i =1:I
            if any( iis == i )
             fprintf(fileID, '\r\n');
             fprintf(fileID, 'Technology #%03i\r\n', i);
                for j=1:J
                    fprintf(fileID, '%f ', p(j,:,i));
                    fprintf(fileID, '\r\n');
                end
            end
        end
        
        fclose(fileID);

end

