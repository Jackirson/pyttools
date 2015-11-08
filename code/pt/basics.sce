// These are some basics of possibility therory //

//=================================================
// ptIsValidPoss: test if all poss-dist values are in range [0 1]
//              and each single poss-dist has a P==1 point
// IN: 	poss array 
//		sDim: 'r' if single poss-dists to be rows, 'c' if them to be columns
// OUT:	boolean test result (%T if passed)
//=================================================
function f = ptIsValidPoss( poss, sDim );
    f = ( max(poss)==1 ) & ( min(poss)==0 );
    if( sDim == 'r' )
        f = f & ( sum(max(poss, 'c')) == length(max(poss, 'c')) );
    else
    if( sDim == 'c' )	
        f = f & ( sum(max(poss, 'r')) == length(max(poss, 'r')) );
	else
        error("Dim must be either r or c.");
	end;
    end;      
endfunction

//=================================================
// ptIsStrictlyMonotoneFunc: test if x->y is strictly monotonous
// IN: 	x, y
// OUT:	boolean test result (%T if passed)
//=================================================
function f = ptIsStrictlyMonotoneFunc(x, y);
    [x1, ind] = unique(x(:));
    y1 = y(ind);
    f1 = isequal(unique(y1), y1);
    [y1, ind] = unique(y(:));
    x1 = x(ind);
    f2 = isequal(unique(x1), x1);
    f = f1 & f2;
endfunction

//=================================================
// ptIsMonotoneFunc: test if x->y is monotonous
// IN: 	x, y
// OUT:	boolean test result (%T if passed)
//=================================================
function f = ptIsMonotoneFunc(x, y);
    [x1, ind] = gsort(x(:));
    for x0 = x1'
        if length(unique(y(x == x0))) ~= 1 then
            f = %f;
            return;
        end
    end
    y1 = y(ind);
    f = isequal(gsort(y1), y1);
endfunction

//=================================================
// ptNormalize1d: ensures the poss-dist has a maximum P==1 value.
// IN: 	poss vector (possibly without P==1 points)
// OUT:	poss-dist vector
//=================================================
function possOut = ptNormalize1d( possWithoutOnes );
    if length(possWithoutOnes) ~=length(possWithoutOnes(:)) then
       error("All input args are vectors.");
    end;
    
    possOut = possWithoutOnes;
    possOut( possOut==max(possOut) ) = 1;
endfunction

//=================================================
// ptNormalize: ensures the poss-dist has a maximum P==1 value.
// 	    same as ptNormalize1d, but for arbitrary dimensioned matrix
// IN: 	poss array (possibly without P==1 points), 
//		sDim: 'r' if single poss-dists to be rows, 'c' if them to be columns
// OUT:	poss-dist array
//=================================================
function possOut = ptNormalize( possWithoutOnes, sDim );
    possOut = possWithoutOnes;
    if( sDim == 'r' )
        possOut( possOut == repmat(max(possOut, 'c'), 1, size(possOut,2)) ) = 1;
    else
    if( sDim == 'c' )	
        possOut( possOut == repmat(max(possOut, 'r'), size(possOut,1), 1) ) = 1;
	else
        error("Dim must be either r or c.");
	end;
    end;   
endfunction

//=================================================
// ptRescale1d: rescales a dist into range [0 1].
// IN: 	vec: some vector
// OUT: 	possOut: poss-dist vector with values in range [0,1]
//=================================================
function possOut = ptRescale1d( vec );
    if length(vec) ~=length(vec(:)) then
       error("All input args are vectors.");
    end;
    
    possOut = (vec - min(vec)) / max(vec - min(vec));
endfunction

//=================================================
// ptRescale: rescales a dist into range [0 1].
//      same as ptRescale1d, but for arbitrary dimensioned matrix
// IN: 	poss array (possibly without P==1 points), 
//		sDim: 'r' if single poss-dists to be rows, 'c' if them to be columns
// OUT:	poss-dist array
//=================================================
function possOut = ptRescale( array, sDim );
    if( sDim == 'r' )
        possOut = (array - repmat(min(array, 'c'), 1, size(array, 2))) ./ repmat(max(array - repmat(min(array,'c'),1,size(array,2)),'c'),1,size(array,2));
    else
    if( sDim == 'c' )	
        possOut = (array - repmat(min(array, 'r'), size(array, 1), 1)) ./ repmat(max(array - repmat(min(array,'r'),size(array,1),1),'r'),size(array,1),1);
	else
        error("Dim must be either r or c.");
	end;
    end;  
endfunction


//=================================================
// ptRescaleUni: rescales a vector into range [0 1] uniformely.
// IN: 	vec: some vector
// OUT: 	possOut: poss-dist vector with values in range [0,1] uniformely placed
//=================================================
//function possOut = ptRescaleUnif( vec );
//   // test for vector input is inside ptChange1d //
//   // ptChange1d can not be avoided
//   
//    ValsOld =   unique( vec );
//    ValsUnif =  linspace(0,1, length(Vals));
//    possOut = ptChange1d( vec, ValsUnif, ValsOld ); 
//endfunction
//
////=================================================
//// ptRescale2Given: rescales a vector into range [0 1] by correcting a  
////      transformation function between some vector 'vec' and a given 
////      poss-dist 'givenPoss' to make it 'close to' a linear transform  
//// IN: 	vec: some vector, givenPoss: goal scale
//// OUT: possOut: poss-dist vector with values in range [0,1] uniformely placed
////=================================================
//function  possOut = ptRescale2Given( vec );
//// NOT YET NEEDED
//endfunction
//
////========================================,=========
//// ptChange1d: emulates Matlab 'changem' function for vectors.
//// COMMENT: an implementation of p2=gamma(p1) in Pytyev will be:
////    P1Vals=unique(p1);
////    ... // define gammaOnP1Vals somehow
////    p2 = ptChange1d( p1, gammaOnP1Vals, P1Vals);
//// IN: 	vec: some vector (to be changed), 
////		toVals: vector of destination values
////		fromVals: vector of source values (present in 'vec') 
//// 	toVals and fromVals must be of same size!
//// OUT: 	vecOut 
////=================================================
//function vecOut = ptChange1d( vec, toVals, fromVals )
//    qFrom = length(fromVals);
//    qTo = length(toVals);
//    qVecLen = length(vec);
//    if qVecLen ~=length(vec(:)) | qFrom ~= length(fromVals(:)) |  ( qFrom ~= qTo & qTo > 1  ) | qTo ~= length(toVals(:))  
//         error("All input args are vectors; toVals and fromVals must be of same size except if toVals is of size 1.");
//    end
//
//    vecOut = vec;
//    for i=1:qVecLen
//        for j=1:qFrom
//            if vec(i) == fromVals(j) 
//                if( qTo > 1 )
//                  vecOut(i) = toVals(j);
//                else
//                  vecOut(i) = toVals;
//                end;    
//            end;
//        end;    
//    end;
//endfunction

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
// ptIsValidCompMatrix: test if a matrix is a valid comp matrix (see Pytyev)
// IN:	comp matrix,
// OUT:	boolean test result (%T if passed)
//=================================================
function f = ptIsValidCompMatrix(comp2d);
    // is a skew-symmetric matrix with values -1, 0 and 1
    f = isequal(size(comp2d,1), size(comp2d,2));
    f = f& isequal(comp2d', -comp2d);
    f = f& ( sum((comp2d ~= 0) & (comp2d ~= -1) & (comp2d ~= 1)) == 0 );
    
    // is transitive
    qSize = size(comp2d,1);
    for i=1:qSize
        for j=1:qSize
            for k=1:qSize
                ij =  comp2d(i,j);
                if( ij == comp2d(j,k) & ij ~= comp2d(i,k) )
                    f = %F;
                end 
            end
        end
    end
    
endfunction

//=================================================
// ptComp2Poss: converts an extended comp matrix (see above) into a
//      uniformly scaled poss-dist.
// IN:	comp matrix,
// OUT:	poss-dist
//=================================================
function poss1d = ptComp2Poss(comp2d);
    if ~ptIsValidCompMatrix(comp2d) then
        error("The input is not a comp matrix. Sorry.");
    end
    
    qXmax = size(comp2d, 1) - 1;
    if sum(abs(comp2d)) == 0 then
        poss1d = ones(1, qXmax);
    else
        prevec = -sum(comp2d, 'r'); // already ordered like the poss-dist we need
        poss1d = ptRescale1d( prevec );
        poss1d = poss1d(1:qXmax);  // eliminate the extension point w0: P(w0)==0
    end
endfunction

//=================================================
// ptPoss2Pref: converts a poss-dist into an extended preference vector
//	'extended' means a w0: P(w0)==0 is added to poss-points in input vector of size qXmax
//	resulting in a qXmax+1 pref vector.
// IN:	poss-dist
// OUT:	pref vector
//=================================================
function pref1d = ptPoss2Pref(poss1d);
    if length(poss1d) ~=length(poss1d(:)) then
       error("All input args are vectors.");
    end;

    [poss_r, poss_c] = meshgrid([poss1d 0]);
    pref1d = sum( (poss_r >= poss_c), 'r' );
endfunction

//=================================================
// ptIsValidCompMatrix: test if a matrix is a valid comp matrix (see Pytyev)
// IN:	comp matrix,
// OUT:	boolean test result (%T if passed)
//=================================================
function f = ptIsValidPrefVector(pref1d);
     
    // is a vector with max == length
    f = (length(pref1d) == length(pref1d(:))) 
    f = f& (length(pref1d) == max(pref1d));
    
    // is upper diagonal (see 151105-1)
    qUsed = 0;
    for i = 1:max(pref1d)
        qIValCount = sum( pref1d == i );
        if( qIValCount > 0 & qIValCount ~= i-qUsed ) 
            f = %F;
            break;
        end
        qUsed = qUsed + qIValCount;
    end
endfunction

//=================================================
// ptPref2Poss: converts an extended prefvector (see above) into a normalized poss-dist.
// IN:	pref vector,
// OUT:	poss-dist
//=================================================
function poss1d = ptPref2Poss(pref1d);
    if ~ptIsValidPrefVector(pref1d) then
        error("The input is not a pref vector. Sorry.");
    end

     qXmax = length(pref1d) - 1;
     poss1d = ptRescale1d( pref1d );
     poss1d = poss1d(1:qXmax);  // eliminate the extension point w0: P(w0)==0
endfunction
// ==eof===eof==

