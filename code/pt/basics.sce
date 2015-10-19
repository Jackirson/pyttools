// These are some basics of possibility therory //

//=================================================
// ptNormalize: ensures the poss-dist has a maximum P==1 value.
//=================================================
function possOut = ptNormalize( possWithoutOnes );
    possOut = possWithoutOnes;
    possOut( possOut==max(possOut) ) = 1;
endfunction

//=================================================
// ptRestrict: rescales a dist into range [0 1]; 
// 	with respert to PT_ZERO_POINT setting the minimum value is either 0 or 0.1
//=================================================
function possOut = ptRescale( someDist );
if( PT_ZERO_POINT == 'B' ) // do not use zero
    possOut = (someDist - min(someDist)) / max(someDist - min(someDist)) * 0.9 + 0.1;
else   // 'A' (use zero) - minumal values are set to zero, or 'C' (use sub-zero) - no sub-zero points by default
    possOut = (someDist - min(someDist)) / max(someDist - min(someDist));
end;  
endfunction


