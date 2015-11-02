// Procedures for general data input and output (from files etc.)

//=================================================
// ptLoadPoss: Function to load possibility distributions (aka poss-dist) from file
// COMMENT: Each line of poss-dist data in the file represents one distribution p(x) with discreet x=1:qXmax. That means, 'qXmax' is the quantity of p()-values per line and it's value is determined from file formatting. The total count of poss-dists 'qLinesOfData' is also determined from file formatting.
// IN: filename (string)
// OUT: poss2d: qLinesOfData*qXmax matrix of real numbers normally in range [0, 1] 
//      sCustomData: the lines of text at file beginning before delimiter 
//=================================================
function [poss2d, sCustomData] = ptLoadPoss( sFilename );
    fileID = mopen(sFilename, 'rt');
    sCustomData = [];
    sLine = "This is a buffer";
    while part(sLine,1) ~= '*'
        sLine = mgetl(fileID, 1);
        sCustomData = [sCustomData; sLine];
    end;
    mclose(fileID);
    poss2d = fscanfMat(sFilename);
endfunction

//=================================================
// ptLoadPoss3d: same as ptLoadPoss (see  above), but poss-dist data is reshaped into blocks 
// COMMENT: the block size lqLinesPerBlock is read from first line of file stored in sCustomData; the number of blocks qBlocks=qLinesOfData/qLinesPerBlock 
// IN: filename (string)
// OUT: qLinesPerBlock*qXmax*qBlocks array of real numbers normally in range [0, 1] 
//      sCustomData: the lines of text at file beginning before delimiter  
//=================================================
function [poss3d, sCustomData] = ptLoadPoss3d( sFilename );
    [poss2d, sCustomData] = ptLoadPoss( sFilename );
    qLinesPerBlock = msscanf(sCustomData(1), "%*s %i");
    qBlocks = size(poss2d,1)/qLinesPerBlock;
    qXmax = size(poss2d,2);
    poss3d = [];
    for i=1:qBlocks
        poss3d(:,:,i) = poss2d(qLinesPerBlock*(i-1)+1:qLinesPerBlock*i,:);
    end;
endfunction

//=================================================
// ptSavePoss: reverse to ptLoadPoss - writes data to file
// IN:  sFilename: file for output
//      poss2d: qLinesOfData*qXmax matrix of real numbers normally in range [0, 1] 
//      sCustomData: the lines of text at file beginning before delimiter 
// OUT: void  
//=================================================
function ptSavePoss(sFilename,poss2d,sCustomData)
   fprintfMat(sFilename, poss2d, "%lf", sCustomData);
   // awesome! there is a built-in func for that.
endfunction
