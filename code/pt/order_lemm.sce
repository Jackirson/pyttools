// Below are local functions for order.sce

//=================================================
// lsupLemm2: extends poss-dist p1 when supp(p1)=S1 is included into supp(p2)=S2
//	(case A1 of Supremum procedure) (local function!)
// IN: 	poss-dist vectors p1,p2, their supports S1,S2
// OUT:	modified p1
//=================================================
function p1_tilde = lsupLemm2(p1, p2, S1, S2);
  
endfunction

//=================================================
// lsupLemm2: extends both poss-dists p1 and p2 when supp(p1) XOR  supp(p2) ~= 0 
//	(case A2 of Supremum procedure) (local function!)
// IN: 	poss-dist vectors p1,p2, their supports S1,S2
// OUT:	modified p1,p2
//=================================================
function [p1_tilde, p2_tilde] = lsupLemm3(p1, p2, S1, S2);
    	S1minusS2 = S1 & ~S2;
	S2minusS1 = S2 & ~S1;
	
	p1_0d   = min( p1(S1) );
	p1__0d  = max( p1(S1minusS2) );
	p1_tilde = zeros( p1 ); 	// zeros are already on their place
//	gamm1  = ones( p1 );
	Y = p1 >= 0 & p1 <= p1_0d; // Y for P-scale, X for Om-scale
	 = y * p1__0d / p1_0d;
	//Y = p1 > p1_0d & 
endfunction
