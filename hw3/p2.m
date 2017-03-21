function p2

clear all;
close all;
hold on;

M = 10000; % How many simulations are we going to run?
ans = zeros(M,1); % This should approach 1 - 1/e.
actual = (1 - 1/e); % The actual result we are expecting.

% Run M bootstrap samples.
for n = 1:M
    % Random normal data set of size 'n'.
    X = randn(n, 1);
    
    % Generate random indecies in the range [1,n].
    idx = ceil(rand(n,1)*n);
    
    % The number of samples contained in X is equal 
    % to the number of UNIQUE indecies in idx.
    % To get the fraction simply divide by n.
    ans(n) = length(unique(idx)) / n;
end

plot(1:M, ans, 'LineWidth', 2);
plot([1 M], [actual actual], 'LineWidth', 2);

end
