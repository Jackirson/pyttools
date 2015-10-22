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
// 	same ad ptNormalize1d, but for arbitrary dimensioned matrix
// IN: 	poss array (possibly without P==1 points), 
//		sDim: 'r' if single poss-dists to be rows, 'c' if them to be columns
// OUT:	poss-dist array
//=================================poss-================
function possOut = ptNormalize( possWithoutOnes, sDim );
    possOut = possWithoutOnes;
    if( sIndicator == 'r' )
	possOut( possOut == repmat(max(possOut, 'c'), 1, size(possOut,2)) ) = 1;
    else
	if( sIndicator == 'c' )	
	    possOut( possOut == repmat(max(possOut, 'r'), size(possOut,1), 1) ) = 1;
	else
	    error("Dim must be either r or c.");
	end;
    end;   
endfunction

//========================================,=========
// ptRescale: rescales a dist into range [0 1].
// IN: 	vec: some vector
// OUT: 	possOut: poss-dist vector with values in range [0,1]
//=================================================
function possOut = ptRescale( vec );
    if length(vec) ~=length(vec(:)) then
       error("All input args are vectors.");
    end;
    
    possOut = (vec - min(vec)) / max(vec - min(vec));
endfunction

//========================================,=========
// ptRescaleUni: rescales a vector into range [0 1] uniformely.
// IN: 	vec: some vector
// OUT: 	possOut: poss-dist vector with values in range [0,1] uniformely placed
//=================================================
function possOut = ptRescaleUni( vec );
   // test for vector input is inside ptChange1d //
   
    Vals =		unique( vec );
    ValsUni = 	linspace(0,1, length(Vals));
    possOut = ptChange1d( vec, ValsUni, Vals ); 
    if( size(vec,1) < size(vec,2) ) then possOut = possOut'; end;
endfunction

//========================================,=========
// ptChange1d: emulates Matlab 'changem' function for vectors.
// IN: 	vec: some vector (to be changed), 
//		toVals: vector of destination values
//		fromVals: vector of source values (present in 'vec') 
// 	toVals and fromVals must be of same size!
// OUT: 	vecOut (column vector)
//=================================================
function vecOut = ptChange1d( vec, toVals, fromVals )
    qChange = length(toVals);
    qVecLen = length(vec);
    if qVecLen ~=length(vec(:)) or qLen ~= length(toVals(:)) or qLen ~= length(fromVals) then
        error("All input args are vectors; toVals and fromVals must be of same size.");
    end

    // convert all vectors to columns 
    vec = vec(:);
    toVals = toVals(:);
    fromVals = fromVals(:);
    
    // make grids of same size qChange*qVecLen
    repV = repmat(vec', qChange, 1);
    repF = repmat(fromVals, 1, qVecLen);
    repT = repmat(toVals, 1, qVecLen);
    
    vecOut = repT( find(repV == repF) );    
endfunction



// ==eof===eof==
