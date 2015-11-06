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
    
    // Sort the possibilities
    [p1, ind1] = gsort(poss1(:));
    p2 = poss2(ind1);
    
    // Identify "incorrectly" ordered atomic events
    [P1, P2] = meshgrid(p1, p1);
    M1 = P1 <= P2;
    [P1, P2] = meshgrid(p2, p2);
    M2 = P1 <= P2;
    M = M1 ~= M2;
    indexes = [find(sum(M, "r") > 0), find(sum(M, "c") > 0)];
    indexes = unique(indexes);
    
    // Identify the separate groups of the incorrectly ordered atomic events
    // and make the possibilities among each group equal.
    bounds = find(diff(indexes) > 1);
    i1 = 1;
    for i2 = bounds
        p1(indexes(i1 : i2)) = max(p1(indexes(i1 : i2)));
        i1 = i2 + 1;
    end
    p1(indexes(i1 : $)) = max(p1(indexes(i1 : $)));
    
    // Form the result using the possibilities calculated at the previous step
    poss_sup = poss1;
    poss_sup(ind1) = p1(:)';
endfunction
// ==eof===eof==
