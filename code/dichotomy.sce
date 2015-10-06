// This file contains functions for local usage //
//DICHOTOMY Answers the question: is it true that
// P( object l(oser) doesn't fit into k maximum sum values ) > p_level ?
function [ answer ] = ldichotomy( p, p_level, l, K, sum_function ) // math symbols used here as variable names and 'l' for locals omitted
    [M,Xmax,N] = size(p);

    // index-to-value array: x(r) = r, r=1..Xmax
    // useful to find max_r(r|conditions)
    X3d = zeros(M,Xmax,N);
    for x = 1:Xmax   
        X3d(:,x,:) = x-1; 
    end
 
    // select only points x in 1..Xmax: p(x) > p_level
    X3d = X3d .* ( p > p_level );
    
    // Construction of T_edge: give best points for all objects i=1..N except i=l ans worst points for object l
    // 1. select best points as maximum in each row of 
    T_edge3d =  max(X3d, 'c');  // sum into single column along rows: M*1*N
    T_edge2d = T_edge3d(:,:);  // a sideway concatenation of matrices in array x_top(:,ONLY,:) eliminates the not used middle index and makes a normal M*N matrix                   
    // 2. change all '0' indicating p <= p_level to 'inf'
    X3d(~X3d) = %inf;   
    // 3. select worst points as minimum in each row of X  
    T_edge2d(:,l) = min( X3d(:,:,l), 'c' );
    
    // "quality" for each object based on previously "selected"
    for i=1:N // this could be eliminated, but good for user experience: user can define the sum_function in form of e.g. x(1)+x(2)+.. instead of having to write x(1,:)+x(2,:)+.. 
        edgeQuality1d(i) = sum_function(T_edge2d(:,i));
    end
    
    // if more than K objects have S_top better than S_top(l), then P(l) > p_level
    // 'sum' here only counts 'trues' in (s_top_x > s_top_x(l)) statement (aka Pi_l)
    if sum( (edgeQuality1d > edgeQuality1d(l)) ) > K  // changed from >= in 2015
        answer = %T;
    else
        answer = %F;
    end
       
endfunction
// ===================
// return value is a scalar!
function  [ P_loser ] = lfindPLoser(poss_init, qLoser, qSelSize, sum_function)
    // dichotomy until |dP| < eps_p, the latter initialized in loader.sce
    p_cur = [0 1];
    p_step =0.5;
  //  p_old = [-1 -1];
    while ( p_step > eps_p )
       // p_old = p_i;
        if ldichotomy(poss_init, p_cur(1)+p_step, qLoser, qSelSize, sum_function)
            // +1/2 of current step
            p_cur(1) = p_cur(1) + p_step;
            p_step = 0.5 * p_step;           
        else
            // -1/2 of current step
            p_cur(2) = p_cur(2) - p_step;
            p_step = 0.5 * p_step;
        end
    end
    P_loser = (p_cur(1)+p_cur(2))/2;
        
endfunction

