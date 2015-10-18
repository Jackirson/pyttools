// The procedures below implement order (predecessor, successor) on poss-dists
// TODO: develop pipeline statrting with raw data, the first qPossPerExpert poss-dist lines corresponding to the 1-st expert's opition and so on.


//=================================================
// ptSupB: supremum when supp p1 = supp p2 (case B) of two poss-dists
//=================================================
function poss_sup = lptSupB(poss1, poss2)
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
// TODO: Describe the function here
//=================================================
function comp2d = lptPoss2Comp(poss1d)
    [poss_r, poss_c] = meshgrid(poss1d(:), poss1d(:));
    comp2d = (poss_r < poss_c) - (poss_r > poss_c);
endfunction

//=================================================
// TODO: Describe the function here
//=================================================
function poss1d = lptComp2Poss(comp2d)
    if sum(abs(comp2d)) == 0 then
        poss1d = ones(1, size(comp2d, 1));
    else
        prevec = -sum(comp2d, 'r'); // already ordered like the poss-dist we need
        poss1d = (prevec - min(prevec)) / max(prevec - min(prevec)) * 0.9 + 0.1;
    end
endfunction
