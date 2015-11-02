// These are functions to calculate 'collective expertise' prior to decision-making tasks

//=================================================
// pevCollective: semi-supremum of multiple 2d-poss-dists,
//  given by different experts in differernt scale  
// IN:    poss3d[qRowsPerExpert*qXmax*qExperts]
// OUT: their semi-supremum sup2d[qRowsPerExpert*qXmax]
//=================================================
function sup2d = pevCollective(poss3d)
    [qRowsPerExpert qXmax qExperts] = size(poss3d);
    longRows2d = zeros(qExperts, qXmax*qRowsPerExpert);
    for i=1:qRowsPerExpert
        longRows2d(:, (i-1)*qXmax+1 : i*qXmax) = matrix(poss3d(i, :, :), qXmax, qExperts)';
    end;
    
    longSup1d = ptSupStack(longRows2d);
    
    sup2d = zeros(qRowsPerExpert, qXmax);
    for i=1:qRowsPerExpert
        sup2d(i,:) = longSup1d((i-1)*qXmax+1 : i*qXmax);  
    end
endfunction

//=================================================
// pevCollectiveF: same as pevCollective, but works with files:
//  one input file and one output file, formatted for pevSelectF.
// IN:  sFileIn: qExperts file(names) with data 
//          poss[qRowsPerExpert*qXmax] in each file 
//      sFileOut: file(name) with their semi-supremum 
//              sup2d[qRowsPerExpert*qXmax]
// OUT: void  
// COMMENT: the headers (sCustomData, see io.sce) will be taken
//          from the first file(name) in sFileIn1d
//=================================================
function pevCollectiveF(sFileIn1d, sFileOut)
    
    qExperts = max(size(sFileIn1d)); // cannot use length() here
    [poss3d(:,:,1) sCustomData] = ptLoadPoss(sFileIn1d(1));
    for i=2:qExperts
        poss3d(:,:,i) = ptLoadPoss(sFileIn1d(i));
    end
    
    sup2d = pevCollective( poss3d );
    ptSavePoss(sFileOut, sup2d, sCustomData);
        
endfunction





 
