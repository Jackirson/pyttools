

 % Initial values %
 if ~exist( 'filename','var' )
    filename= 'collective_expertise.txt';
 end
 if ~exist( 'K','var' )
     K = 1;  % to select
 end
 
  p_init = load_p( filename );
 [J,R,I] = size(p_init);
 
 %function face

 eps_p = 0.001;  % dichotomy until |dP| < eps_p
 
 %%%%%%%%%%

% P( project 'l' doesnt't fit into K best )
P_loser = zeros(I,1);

for l=1:I   
    % dichotomy until |dP| < eps_p
    p_i = [0 1];
    p_step =0.5;
    p_old = [-1 -1];
    while ( p_step > eps_p )
        p_old = p_i;
        if dichotomy(p_init, p_i(1)+p_step, l, K)
            % +1/2 of current step
 
            p_i(1) = p_i(1) + p_step;
            p_step = 0.5 * p_step;           
        else
            % -1/2 of current step
           
             p_i(2) = p_i(2) - p_step;
             p_step = 0.5 * p_step;
        end
        
    end
    P_loser(l) = p_i(1);
end

fprintf('P_looser: ')
fprintf('%1.6f ', P_loser')
fprintf('\n')
