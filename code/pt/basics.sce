// These are some basics of possibility therory //

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
function possOut = ptRescaleUnif( vec );
   // test for vector input is inside ptChange1d //
   
    ValsOld =   unique( vec );
    ValsUnif =  linspace(0,1, length(Vals));
    possOut = ptChange1d( vec, ValsUnif, ValsOld ); 
endfunction

//=================================================
// ptRescale2Given: rescales a vector into range [0 1] by correcting a  
//      transformation function between some vector 'vec' and a given 
//      poss-dist 'givenPoss' to make it 'close to' a linear transform  
// IN: 	vec: some vector, givenPoss: goal scale
// OUT: possOut: poss-dist vector with values in range [0,1] uniformely placed
//=================================================
///function  possOut = ptRescale2Given( vec );
/// NOT YET NEEDED
///endfunction

//========================================,=========
// ptChange1d: emulates Matlab 'changem' function for vectors.
// COMMENT: an implementation of p2=gamma(p1) in Pytyev will be:
//    P1Vals=unique(p1);
//    ... // define gammaOnP1Vals somehow
//    p2 = ptChange1d( p1, gammaOnP1Vals, P1Vals);
// IN: 	vec: some vector (to be changed), 
//		toVals: vector of destination values
//		fromVals: vector of source values (present in 'vec') 
// 	toVals and fromVals must be of same size!
// OUT: 	vecOut 
//=================================================
function vecOut = ptChange1d( vec, toVals, fromVals )
    qFrom = length(fromVals);
    qTo = length(toVals);
    qVecLen = length(vec);
    if qVecLen ~=length(vec(:)) | qFrom ~= length(fromVals(:)) |  ( qFrom ~= qTo & qTo > 1  ) | qTo ~= length(toVals(:))  
         error("All input args are vectors; toVals and fromVals must be of same size except if toVals is of size 1.");
    end

    vecOut = vec;
    for i=1:qVecLen
        for j=1:qFrom
            if vec(i) == fromVals(j) 
                if( qTo > 1 )
                  vecOut(i) = toVals(j);
                else
                  vecOut(i) = toVals;
                end;    
            end;
        end;    
    end;
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
// IN:	comp matrix,
//      sRescale: 'n' - none (may be omitted), 'u' - uniform, 'l' - linear  
// OUT:	poss-dist
//=================================================
function poss1d = ptComp2Poss(comp2d, sRescale);
    if ~isequal(size(comp2d,1), size(comp2d,2)) then
        error("Comp matrix must be scew-symmetric.");
    end
    
    qXmax = size(comp2d, 1) - 1;
    if sum(abs(comp2d)) == 0 then
        poss1d = ones(1, qXmax);
    else
        prevec = -sum(comp2d, 'r'); // already ordered like the poss-dist we need
        if( sRescale == "u" ) then poss1d = ptRescaleUnif( prevec ); end;
        if( sRescale == "l" ) then poss1d = ptRescale( prevec ); end;
        poss1d = poss1d(1:qXmax);  // eliminate the extension point w0: P(w0)==0
    end
endfunction
// ==eof===eof==

