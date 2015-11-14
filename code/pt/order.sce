// The procedures below implement order (predecessor, successor) on poss-dists

//  test if poss1 < poss2
function f=ptPrecise(poss1, poss2)
    // Check that the distributions have the same sizes
    if length(poss1) ~= length(poss2) | length(poss1) ~= length(poss1(:)) then
        error("Given distributions must be vectors of the same size.");
    end
    
    supp1 = poss1 > 0;
    supp2 = poss2 > 0;
	S1minusS2 = supp1 & ~supp2;
    S2minusS1 = supp2 & ~supp1;
    
    // check D1
    if ~( sum(S1minusS2) == 0 ) then
        f=%F;  // S1 is not inside S2;
        return;
    end
    
    // check D2
    if ~( ptIsMonotoneFunc(poss1(supp1), poss2(supp1)) ) then
        f=%F;  // there is no g-func;
        return;
    end           
    
    // check D3
   // Xmax = length(poss1);  // or poss2...
     f = ( min(poss2(supp1)) >= max(poss2(~supp1)) );   
endfunction

// test if poss1 > poss2
function f=ptDeprecise(poss1, poss2)
    f=ptPrecise(poss2, poss1);
endfunction

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
    
    // "mask" marks "indexes" from the same group, initially empty.
    mask = indexes ~= indexes;
    // "lb" indexes the elemets of array "indexes".
    // "lb" is the lower boundary of the group, initially 1.
    lb = 1;
    
    for i = 1 : length(indexes)
        // Search for the elements joint with the current one.
        // "Joint" means that the possibilities of the elements are ordered incorrectly.
        incorrectOrder = M(indexes(i), :) | M(:, indexes(i))';
        joint = find(incorrectOrder);
        jointMin = min(joint);
        jointMax = max(joint);
        
        // As possibilities of the elements with indexes "indexes" are ordered,
        // all the elements between indexes(jointMin) and indexes(jointMax) are
        // also in the same group.
        jointMask = jointMin <= indexes & indexes <= jointMax;
        
        // Include the elements identified into the group.
        mask(jointMask) = %t;
        
        // If the current element is the maximum one of the group, the group is full.
        if i == length(indexes) | ~mask(i + 1) then
            // Make the possibilities among the current group equal.
            gr = indexes(mask);
            p1(gr) = max(p1(gr));
            
            // Clear all the group markers and advance its lower boundary.
            mask(:) = %f;
            lb = i + 1;
        end
    end
    
    // Form the result using the possibilities calculated at the previous step
    poss_sup = poss1;
    poss_sup(ind1) = p1(:)';
endfunction
// ==eof===eof==
