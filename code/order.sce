// The procedures below implement order (predecessor, successor) on poss-dists 
// TODO: develop pipeline statrting with raw data, the first qPossPerExpert poss-dist lines corresponding to the 1-st expert's opition and so on.
// supremum when supp p1 = supp p2 (case B) of two poss-dists ( i.e. poss2d[2,qXmax] )
function poss_sup = lptSupB(poss2d)
    M1 = lptPoss2Comp( poss2d(1,:) );
    M2 = lptPoss2Comp( poss2d(1,:) );
    M = (M1+M2 == 2) - (M1+M2 == -2); // only 2 and -2 count?  
    poss_sup = lptComp2Poss( M );
endfunction
//==============
function comp2d= lptPoss2Comp(poss1d)
    qXmax = length(poss1d)
    stackRows = repmat(poss1d, qXmax, 1);
    stackCols = repmat(poss1d', 1, qXmax);
    comp2d = (stackCols-stackRows > 0) - (stackCols-stackRows < 0);
endfunction
//==============
function poss1d= lptComp2Poss(comp2d)
    prevec = -sum(comp2d, 'r'); // already ordered like the poss-dist we need
    poss1d = (prevec - min(prevec))/max(prevec-min(prevec));  
endfunction

