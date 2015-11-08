// The procedures below implement evaluation of some 'mean' poss-dist
// in terms of either comp matrices or preferece vectors.

//=================================================
// ptMeanStack: mean of several poss-dists   
// IN:  poss2d[qRows*qXmax]: poss-dists as qRows rows of qXmax poss-points each 
//     sTech: either 'pref' (default option) for pref vectors 
//              or 'comp' for comp matrices used as a basis to calculate mean
// OUT: their mean
//=================================================
function poss_mean = ptMeanStack(poss2d, varargin);
   [qlhs qrhs] = argn();
   if( qrhs < 1 | qrhs > 2  )
       error('Wrong number of arguments');
   end
   if( qrhs == 1 )   
       sTech = 'pref';
   else
       sTech = varargin(1);
   end
   
   [qRows qXmax]=  size(poss2d);
   S = zeros(qXmax);
  
   if( sTech == 'pref' )
     for i=1:qRows
       pref2d(i,:)   = ptPoss2Pref( poss2d(i,:) );
       S = S +  pref2d(i,:);
     end 
     
     S = round( S / qRows );
     [SSorted, qIndex1d] = gsort(S,'g','i');  // sort asc
     
     // make upper diagonal (see 151105-1)
//     qUsed = 0;
//     for i = 1:max(SSorted)
//        qIValCount = sum( SSorted == i );
//        if( qIValCount > 0 & qIValCount ~= i-qUsed ) 
//            f = %F;
//            break;
//        end
//        qUsed = qUsed + qIValCount;
//     end 
     
     S(qIndex1d) = SSorted;           // revert sort
     print(%io(2),[pref2d; S]);
     poss_mean = ptPref2Poss(S);
     return;
   end
   
   // ==== //
   if( sTech == 'comp' )
     for i=1:qRows
       comp3d(:,:,i) = ptPoss2Comp( poss2d(i,:) );
     end 
     error("Comp matrices not implemented yet.")
     return;
   end
endfunction

//=================================================
// ptMean: mean of two poss-dists
// COMMENT: just an interface to ptMeanStack for an argument pair and 
//          sTech=='pref' fixed
// IN:  poss1, poss2: poss-dists  
// OUT: their mean 
//=================================================
function poss_mean = ptMean(poss1, poss2, varargin);
    // Check that the distributions have the same sizes
    if length(poss1) ~= length(poss2) | length(poss1) ~= length(poss1(:)) then
        error("Given distributions must be vectors of the same size.");
    end
    
    poss_mean = ptMeanStack([poss1(:)'; poss2(:)']);
endfunction
