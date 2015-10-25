// The procedures below implement order (predecessor, successor) on poss-dists
// TODO: develop pipeline statrting with raw data, the first qPossPerExpert poss-dist lines corresponding to the 1-st expert's opition and so on.

//=================================================
// ptSupStack: supremum of several poss-dists (recursively)  
// 	by now supremum is calculated pairwise
// IN:    poss2d[qRows*qXmax]: poss-dists as qRows rows of qXmax poss-points each 
// OUT: their supremum
//=================================================
function poss_sup = ptSupStack(poss2d);
   qRows =  size(poss2d, 1);
   if(  qRows == 2 ) // only 2 rows 
	poss_sup = ptSup( poss2d(1,:), poss2d(2,:) );
   else
        poss2d(2,:) = ptSup( poss2d(1,:), poss2d(2,:) );  // supremum of the first 2 rows   
        poss_sup    = ptSupStack( poss2d(2:qRows, :) ); 
   end; 
endfunction

//=================================================
// ptSup: supremum of two poss-dists in general case 
// IN: 2 poss-dist vectors
// OUT: their supremum
//=================================================
function poss_sup = ptSup(poss1, poss2);
    // Check that the distributions have the same sizes
    if length(poss1) ~= length(poss2) or length(poss1) ~= length(poss1(:)) then
        error("Given distributions must be vectors of the same size.");
    end

    // Check that the distributions have the same supports
    supp1 = poss1 > 0;
    supp2 = poss2 > 0;
   
    if isequal(supp1, supp2) then
        poss_sup = ptSupB(poss1, poss2);
    else
        
	S1minusS2 = supp1 & ~supp2;
	S2minusS1 = supp2 & ~supp1;
  /// print(%io(2), S1minusS2, S2minusS1); poss_sup = 0; return;    
	if( sum(S1minusS2) == 0 ) then
        // S1 is inside S2; lemm2 infects poss1
        poss1 = lsupLemm2(poss1, poss2, supp1, supp2);
        poss_sup = ptSupB(poss1, poss2);
	else
        if( sum(S2minusS1) == 0 ) then
            // S2 is inside poss_sup = ptSupB(poss1, poss2);e S1; lemm2 infects poss2
            poss2 = lsupLemm2(poss2, poss1, supp2, supp1);
            poss_sup = ptSupB(poss1, poss2);
        else 
            // both S1minusS2 and S2minusS1 are non-empty; lemm3
            [poss1, poss2] = lsupLemm3(poss1, poss2, supp1, supp2);
            poss_sup = ptSupB(poss1, poss2);
        end;   
    end;
    end;//if case D
endfunction    

//=================================================
// ptSupB: supremum of two poss-dists when supp p1 = supp p2 (case B) 
// IN: 2 poss-dist vectors
// OUT: their supremum
//=================================================
function poss_sup = ptSupB(poss1, poss2);
    // Check that the distributions have the same sizes
    if length(poss1) ~= length(poss2) or length(poss1) ~= length(poss1(:)) then
        error("Given distributions must be vectors of the same size.");
    end

    // Check that the distributions have the same supports
    supp1 = poss1 > 0;
    supp2 = poss2 > 0;
    if ~isequal(supp1, supp2) then
        error("Supports of the given distributions must be the same.");
    end
    
    M1 = ptPoss2Comp(poss1(supp1)); // only compare non-zero values ...
    M2 = ptPoss2Comp(poss2(supp1));
    M = (M1+M2 == 2) - (M1+M2 == -2); // only 2 and -2 count?
    poss_sup = zeros(poss1);	// ... others are assigned zero directly (efficiency gain)
    poss_sup(supp1) = ptComp2Poss(M); 
endfunction

//=================================================
// ptPoss2Comp: converts a poss-dist into an extended comp matrix
//	'extended' means a w0: P(w0)==0 is added to poss-points in input vector of size qXmax,
//	resulting in a (qXmax+1)*(qXmax+1) comp matrix.
// IN:		poss-dist
// OUT:	comp matrix
//=================================================
function comp2d = ptPoss2Comp(poss1d);
    if length(poss1d) ~=length(poss1d(:)) then
       error("All input args are vectors.");
    end;
    
    poss1d = [poss1d 0];
    [poss_r, poss_c] = meshgrid(poss1d);  /// (:) makes a large 2d matrix anyway
    comp2d = (poss_r < poss_c) - (poss_r > poss_c);
endfunction

//=================================================
// ptComp2Poss: converts an extended comp matrix (see above) into a normalized poss-dist.
// IN:		comp matrix
// OUT:	poss-dist
//=================================================
function poss1d = ptComp2Poss(comp2d);
    if ~isequal(size(comp2d,1), size(comp2d,2)) then
        error("Comp matrix must be scew-symmetric.");
    end
    
    qXmax = size(comp2d, 1) - 1;
    if sum(abs(comp2d)) == 0 then
        poss1d = ones(1, qXmax);
    else
        prevec = -sum(comp2d, 'r'); // already ordered like the poss-dist we need
        poss1d = ptRescaleUni( prevec );
        poss1d = poss1d(1:qXmax);  // eliminate the extension point w0: P(w0)==0
    end
endfunction

// ==eof===eof==
