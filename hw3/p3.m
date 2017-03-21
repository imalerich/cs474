function p3

clear all;
close all;
hold on;

%% Read the data from the given spreadsheet.
data = xlsread('ozon.xlsx');

X = data(:,1:72); % All of our data, but no labels.
Y = data(:,73);	  % Labels corresponding to each entry in X.

% KernelFunctions: rbf, linear, or polynomial
% mdl = fitcsvm(X, Y, 'KernelFunction', 'polynomial', 'OptimizeHyperparameters', 'auto',...
% 	'HyperparameterOptimizationOptions', struct('Optimizer', 'bayesopt', 'Kfold', 10));
mdl = fitcsvm(X, Y, 'KernelFunction', 'polynomial', 'KernelScale', 'auto');

% Cross validate the final model to estimate performance.
err = kfoldLoss(crossval(mdl))
% rbf 		- 0.0693
% linear	- 0.0693
% polynomial	- 0.0000

end
