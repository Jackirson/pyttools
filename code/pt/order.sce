// The procedures below implement order (predecessor, successor) on poss-dists
// TODO: develop pipeline statrting with raw data, the first qPossPerExpert poss-dist lines corresponding to the 1-st expert's opition and so on.


//=================================================
// ptSupB: supremum when supp p1 = supp p2 (case B) of two poss-dists
//=================================================
function poss_sup = ptSupB(poss1, poss2)
    // Check that the distributions have the same sizes
    if ~isequal(size(poss1), size(poss2)) then
        error("Given distributions must be of the same size");
    end
    
    // Check that the distributions have the same supports
    supp1 = poss1 > 0;
    supp2 = poss2 > 0;
    if ~isequal(supp1, supp2) then
        error("Supports of the given distributions must be the same");
    end
    
    M1 = lptPoss2Comp(poss1(supp1));
    M2 = lptPoss2Comp(poss2(supp1));
    M = (M1+M2 == 2) - (M1+M2 == -2); // only 2 and -2 count?
    poss_sup = zeros(poss1);
    poss_sup(supp1) = lptComp2Poss(M);
endfunction

//=================================================
// ptPoss2Comp: converts a poss-dist into an extended comp matrix
//	'extended' means a w0: P(w0)==0 is added to poss-points in input vector of size qXmax,
//	resulting in a (qXmax+1)*(qXmax+1) comp matrix.
// IN:		poss-dist
// OUT:	comp matrix
//=================================================
function comp2d = ptPoss2Comp(poss1d)
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
function poss1d = ptComp2Poss(comp2d)
    qXmax = size(comp2d, 1) - 1;
    if sum(abs(comp2d)) == 0 then
        poss1d = ones(1, qXmax);
    else
        prevec = -sum(comp2d, 'r'); // already ordered like the poss-dist we need
        poss1d = ptRescaleUni( prevec );
        poss1d = poss1d(1:qXmax);  // eliminate the extension point w0: P(w0)==0
    end
endfunction