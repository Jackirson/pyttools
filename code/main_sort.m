% AndReW:
%
% There is some "logical" BUG in the algorithm. At any iteration (say the 1-st one)
% possibilities P_loser may be equal. In this case the algorithm
% erroneously decide to select technology #1 as a winner. However any
% further iteration may get this technology to be a looser.
%
% The algorithm shall be more intelligence!!!
%
% Отобрать можно только либо 2 лучших, либо 14 лучших единственным образом
% ранжировать-то можно


filename_list = {'../data/expert1.txt','../data/expert2.txt','../data/expert3.txt','../data/expert4.txt'};

vectorS1;

fprintf('Techn. #: ')
fprintf('%8d ', 1 : I)
fprintf('\n')

filename = 'collective_expertise.txt';

for k=1:I
   
    K = k;
    face;
    
    % avoid choosing twice
    P_loser_KI(k,:) = P_loser;
   %%% P_loser2(techn_sorted_I) = 10;
    

   %%% techn_sorted_I = [techn_sorted_I ind];
    
end

% start ranking from tail
fprintf('Priority:\n')
techn_sorted_I = zeros(I);
for k=I-1:-1:2
    %min element
    P =min(P_loser_KI(k,:));
    
    % indexes of min elements
    ind = (P_loser_KI(k,:) == P); 
    techn_sorted(k,:) =ind;

    fprintf('%d ', find(P_loser_KI(k,:) == P))
    fprintf('\n')
    
end


% AndReW:
% Comment out printing ranking results because they are incorrect.
%
% techn_sorted_I
