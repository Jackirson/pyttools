

% invariant vector S is used
% to merge expert assesstments of p(j,r,i) 
% provided in different scales (from different people)
%
% In this script: some files with p(j,r,i)[n], n=1..N loaded and
% merged into a single p(j,r,i) named 'collective expertise'
% each p(j,r,i) is assumed to be given in own scale.

%initial%
NOK = [1 2 6 12 60 60];

 if ~exist( 'filename_list','var' )
    filename_list = {'expert1.txt','expert2.txt','expert3.txt','expert4.txt'};
 end
 
N = size(filename_list,2);

[p_init_JRI, iis(:,1)] = load_p( filename_list{1} );
[J,R,I] = size(p_init_JRI);

p_init_4N = zeros(J,R,I, NOK(N));

p_init_4N(:,:,:,1) = p_init_JRI;
for n=2:N
 [p_init_JRI, iis(:,n)] = load_p( filename_list{n} );
 p_init_4N(:,:,:,n) = p_init_JRI;
end

% NOK and copy
for i=1:I
   num_exp_yes = sum(iis(i,:));
   ind_exp_yes = find(iis(i,:));
   ind_virt_exp = setdiff(1:NOK(N), ind_exp_yes);  %A \ B sets
    
   for n=1:size(ind_virt_exp,2)
      
       
       p_init_4N(:,:,i,ind_virt_exp(n)) = ...
       p_init_4N(:,:,i,ind_exp_yes(mod(n, num_exp_yes)+1));
       
             
   end
   
end

p_init_2N = reshape(p_init_4N, J*R*I, NOK(N));  % does not allocate memory?

% make vector s from every p( )
vector_s_2N = zeros(J*R*I, NOK(N));
BY_N=2;
for index=1:J*R*I

    % p_full_2N(:,r) is a column vector 
    % repmat function stacks column vectors
   vector_s_2N(index,:) =   ...
        sum(( repmat(p_init_2N(index,:),J*R*I,1) >= p_init_2N ),1);
end



%%%%%%%%%%
% make average vector S
vector_s_1N(1:J*R*I) = 0;% = zeros(J*R*I,1);


    
    %  seeking for collective expertise
    vector_s_1N = ...
        sum(vector_s_2N, BY_N) / NOK(N);


% normalize to [0, 1] 
[maxel, ind] = max( vector_s_1N );
p_full_JRI = reshape(vector_s_1N/maxel,J,R,I);

for j=1:J
     for i=1:I
        [maxel, ind] = ...
            max(p_full_JRI(j,:,i));
        p_full_JRI(j,ind,i)=1.0;
        
     end
end

save_p('collective_expertise.txt',p_full_JRI,1:I);

%%%%%%%%%%











