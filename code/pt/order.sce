// The procedures below implement order (predecessor, successor) on poss-dists

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
    if length(poss1) ~= length(poss2) | length(poss1) ~= length(poss1(:)) then
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
    if length(poss1) ~= length(poss2) | length(poss1) ~= length(poss1(:)) then
        error("Given distributions must be vectors of the same size.");
    end

    // Check that the distributions have the same supports
    supp1 = poss1 > 0;
    supp2 = poss2 > 0;
    if ~isequal(supp1, supp2) then
        error("Supports of the given distributions must be the same.");
    end

    // define an explicit function poss_sup = gamm(poss1)
    PVals = unique([poss1 poss2]); // "All" P-values
    dstPVals = PVals;  // that means, initially map PVals to same PVals 
    
    for i=1:length(PVals)  
        p = PVals(i);   // loop on 'p' actually
        X2 = (poss2 == p);
        if( sum(X2) == 0 ) 
            continue;
        end;
        srcPartMin = min( poss1(X2) );
        srcPartMax = max( poss1(X2) );
        srcPValsPart = PVals( PVals >= srcPartMin & PVals <= srcPartMax );
        dstPVals = ptChange1d(dstPVals, srcPartMax, srcPValsPart);
    end
        
    poss_sup = ptChange1d(poss1, dstPVals, PVals );	
endfunction
// ==eof===eof==





















// ==eof===eof==
