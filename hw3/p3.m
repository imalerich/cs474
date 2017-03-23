function p3

clear all;
close all;
hold on

%% Read the data from the given spreadsheet.
data = xlsread('ozon.xlsx');

X = data(:,1:72); % All of our data, but no labels (1874 Entries).
Y = data(:,73);	  % Labels corresponding to each entry in X.

%% SVM

tic;

% Kernel Functions: rbf, linear, or polynomial
mdl = fitcsvm(X, Y, 'KernelFunction', 'rbf', 'OptimizeHyperparameters', 'auto',...
    'HyperparameterOptimizationOptions', struct('Optimizer', 'bayesopt', 'Kfold', 10));
% linear and polynomial kernels weren't working with the extra parameters
% but it worked after removing them
% mdl = fitcsvm(X, Y, 'KernelFunction', 'linear');

% Get our misclassification rate estimate through cross validation.
kfoldLoss(crossval(mdl))
toc;

% rbf 		0.0671 # 148.50 seconds
% linear	0.0693 # 334.09 seconds
% polynomial	NaN    # 2.0702 seconds

%% LSSVM

tic;

% Kernel Functions: lin_kernel, poly_kernel, RBF_kernel
mdl = initlssvm(X, Y, 'c', [], [], 'poly_kernel', 'p');
mdl = tunelssvm(mdl, 'simplex', 'crossvalidatelssvm', {10, 'misclass'});
mdl = trainlssvm(mdl);
% Get our misclassification rate estimate through cross validation.
crossvalidate(mdl, 10, 'misclass')

toc;

% lin_kernel	0.0693 # 48.76 seconds
% poly_kernel	0.1012 # 43.01 seconds
% RBF_kernel	0.0596 # 75.90 seconds 

%% Box Plots

B = 100;
mcrsvm   = zeros(B,1);
mcrlssvm = zeros(B,1);

tic;

% Basically just copy and paste the prof's example code.
for b = 1:B

    % For sake of performance, use a random sample size
    % of 500 (375 Train, 125 Test).
    % We already have an estimate of misclassification error,
    % so we really are only interested in the variance, so this should be fine.

    N = 500; % How big is the random subset we are considering?
    r = randperm(size(X,1)); % Need a random permutation over ALL indecies...
    r = r(1:N); % but only want N when we are all said and done.
    ntr = ceil(0.75 * N); % The first 75% are for training.

    % Break up our data into training...
    Xtr = X(r(1:ntr), :);
    Ytr = Y(r(1:ntr));

    % and test sets.
    Xtest = X(r(ntr+1:N), :);
    Ytest = Y(r(ntr+1:N));
    
    %%%%%%%
    % SVM %
    %%%%%%%
    mdl = fitcsvm(X, Y, 'KernelFunction', 'rbf', 'OptimizeHyperparameters', 'auto',...
	'HyperparameterOptimizationOptions', struct('Optimizer', 'bayesopt', 'Kfold', 10));
    yh = predict(mdl, Xtest);
    mcrsvm(b, 1) = sum(Ytest ~= yh) / size(Ytest, 1);

    %%%%%%%%%
    % LSSVM %
    %%%%%%%%%
    mdl = initlssvm(X, Y, 'c', [], [], 'RBF_kernel', 'p');
    mdl = tunelssvm(mdl, 'simplex', 'crossvalidatelssvm', {10, 'misclass'});
    mdl = trainlssvm(mdl);

    % For whatever reason lssvm is only letting me do one prediction at a time,
    % so take this pain in the ass approach to get our predictions.
    T = size(Xtest, 1);
    yh = zeros(T, 1);
    for idx = 1:T
	yh(idx, 1) = predict(mdl, Xtest(idx, :), 1);
    end

    mcrlssvm(b, 1) = sum(Ytest ~= yh) / size(Ytest, 1);

    close all;
end

toc;

legend = { 'SVM', 'LSSVM' };
boxplot([mcrsvm, mcrlssvm], legend);
ylabel('Misclassification rate on test data');

end
