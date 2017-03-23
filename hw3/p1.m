function p1

clear all;
close all;
hold on;

%% Data

data = [
    % Class 1
    2, 2, 1;
    2, -2, 1;
    -2, -2, 1;
    -2, 2, 1;
    % Class -1
    1, 1, -1;
    1, -1, -1;
    -1, -1, -1;
    -1, 1, -1
];

%% Manual SVM

axis([-2 10 -2 10]);

classA = data(data(:,3)==1, 1:2);
classB = data(data(:,3)==-1, 1:2);

classA = phi(classA);
classB = phi(classB);

scatter(classA(:,1), classA(:,2), 'LineWidth', 2)
scatter(classB(:,1), classB(:,2), 'LineWidth', 2)

% Plot the decision boundary.
x = [-2, 10];
y = -1 * x + 3;
[1; 1]' * x' - 3
plot(x, y, 'k', 'LineWidth', 2);


% Plot the margins.
y1 = -1 * x + 3 + 1;
y2 = -1 * x + 3 - 1;
plot(x, y1, '--k', 'LineWidth', 1);
plot(x, y2, '--k', 'LineWidth', 1);

%% Matlab SVM

% X = data(:,1:2);
% Y = data(:,3);
% 
% mdl = fitcsvm(X, Y, 'KernelFunction', 'rbf', 'OptimizeHyperparameters', 'auto',...
%     'HyperparameterOptimizationOptions', struct('Optimizer', 'bayesopt', 'Kfold', 10));
% plotsvm(mdl)

end
