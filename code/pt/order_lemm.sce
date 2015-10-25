// Below are local functions for order.sce

//=================================================
// lsupLemm2: extends poss-dist p1 when supp(p1)=S1 is included into supp(p2)=S2
//	(case A1 of Supremum procedure) (local function!)
// IN: 	poss-dist vectors p1,p2, their supports S1,S2
// OUT:	modified p1
//=================================================
function p1_tilde = lsupLemm2(p1, p2, S1, S2);
	S2minusS1 = S2 & ~S1;
	
	p1_0d   = min( p1(S1) );
	p2__0d  = max( p2(S2minusS1) );
	p1_tilde = zeros( p1 ); // zeros are already on their place

    p1_tilde(S1) = p1(S1);
    p1_tilde(S2minusS1) = p2(S2minusS1)* p1_0d/(2*p2__0d);
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
	p2_0d   = min( p2(S2) );
	p2__0d  = max( p2(S2minusS1) );
	p1_tilde = zeros( p1 ); // zeros are already on their place
	p2_tilde = zeros( p2 ); 

    // > and >= signs below ought to cover whole [0; 1] range
    // the choice between > and >= is based on estimated calc.eff.          
	X = p1(S1) < p1_0d; // bool mask for Om scale
         // there'll be automatically no %T points not in supp(p1)
	p1_tilde(X) = p1(X)* p1__0d/p1_0d;
    X = (p1(S1) >= p1_0d & p1(S1) <= p1__0d) | S2minusS1;
    p1_tilde(X) = p1__0d;
    X = p1(S1) > p1__0d;
    p1_tilde(X) = p1(X);
    
    // same shit for p2
    X = p2(S2) < p2_0d; 
	p2_tilde(X) = p2(X)* p2__0d/p2_0d;
    X = (p2(S2) >= p2_0d & p2(S2) <= p2__0d) | S1minusS2;
    p2_tilde(X) = p2__0d;
    X = p2(S2) > p2__0d;
    p2_tilde(X) = p2(X);
endfunction
