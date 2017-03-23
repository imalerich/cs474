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

X = data(:,1:2);
Y = data(:,3);
mdl = fitcsvm(X, Y, 'KernelFunction', 'rbf', 'OptimizeHyperparameters', 'auto',...
    'HyperparameterOptimizationOptions', struct('Optimizer', 'bayesopt', 'Kfold', 10));

%% Comparison

% Generate a grid of data on each axis between [-3,3]
delta = 0.005;
[XX, YY] = meshgrid(-3:delta:3, -3:delta:3);
X = [reshape(XX, numel(XX), 1) reshape(YY, numel(YY), 1)];

% Make a prediction using Matlabs model.
LABELS0 = predict(mdl, X);
LABELS1 = p1predict(X);

% If they Agree:
% 1 - 1 = 0
%  or
% -1 - -1 = -1 + 1 = 0
% But if they Disagree:
% 1 - -1 = 2 (divide by 2 = 1)
%  or
% -1 - 1 = -2 (divide by 2 = -1, abs() for 1)
% Thus the sum is the number of labels my classifier and matlab disagree on.
DISAGREE = sum(abs(LABELS0 - LABELS1) ./ 2);
DISAGREE / length(X) % 0.0772

% classA = X(LABELS(:,1)==1, :);
% classB = X(LABELS(:,1)==-1, :);

% scatter(classA(:,1), classA(:,2), 'LineWidth', 2)
% scatter(classB(:,1), classB(:,2), 'LineWidth', 2)

end
