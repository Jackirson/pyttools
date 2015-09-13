
function [ answer ] = dichotomy( p, p_level, l, K )
%DICHOTOMY Answers the question: is it true that
% P( l(oser) doesn't fit into k maximum sum values ) > p_level ?

    [J,R,I] = size(p);

    % x is an index-to-value array: x(r) = r, r=1..R
    % useful to find max[r](r|conditions)
    x = zeros(J,R,I);
    for r = 1:R   
        x(:,r,:) = r-1; %!!!!!
    end
 
    % select only points x in 1..R: p(x) > p_level
    x = x .* ( p > p_level );
    
    
    % give best points for all i=1..N except i=l 
    % 1. select best points in point array x as maximum in each row
    % 2. change all '0' indicating p <= p_level to 'inf'
    % 3. select worst points for i=l. 
    BY_R = 2;
    x_top =  max(x, [], BY_R);  % size(x_top) = J,1,I
    
    x(~x) = inf;
    x_top(:,1,l) = min( x(:,:,l), [], BY_R );
    
    % 'upper' sum with previously selected {x}
    s_top = sum_function(x_top(:, :));

    
    % if more than K S_top(i) are better than S_top(l)
    % 'sum' here only counts 'trues' in (s_top_x > s_top_x(l)) statement
    if sum( (s_top > s_top(l)) ) > K  % changed from >= in 2015
        answer = 1;
    else
        answer = 0;
    end
         
end

