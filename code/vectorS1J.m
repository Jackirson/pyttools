

% invariant vector S is used
% to merge expert assesstments of p(j,r,i) 
% provided in different scales (from different people)
%
% In this script: only i=1 considered; 
% each p(j,:,1) is assumed to be given in own scale.

%initial%
 filename = 'expert_possib.txt'; 
 p_init_JRI = load_p( filename );
 [J,R,I] = size(p_init_JRI);
  
 eps_p = 0.01;  % some |x-y| < eps_p

% x is an index-to-value array: x(r) = r, r=1..R
x_JR = zeros(J,R);
for r = 1:R
    x_JR(:,r) = r;
end 

%%%%%%%%%%
 
p_init_JR = p_init_JRI(:,:,1); % In this script: only i=1 considered; 

% expert weights (?)
exp_w = ones(J);

% make vector s for each j
BY_R = 2;
vector_s_JR = zeros(J,R);
for r0=1:R

    % make a compare matrix p(r0) >=? p(r)
    % p_init(:,r) is a column vector 
    % repmat function stacks column vectors
	vector_s_JR(:,r0) =  sum( ...
       x_JR .* repmat(p_init_JR(:,r0),1,R) >= p_init_JR, ...
                            BY_R );

end

% make average vector j
vector_s_1R = mean( vector_s_JR );

% set one max element to R (normalize)
[maxel, ind] = max( vector_s_1R );
vector_s_1R(ind) = R;

% round other elements 
vector_s_1R = round( vector_s_1R );

vector_s_1R











