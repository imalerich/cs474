function p2

%% Data
% Input features to train on.
train = [
    % Class 0
    0.6585, 0.2444;
    2.2460, 0.5281;
    -2.7665, -3.8303;
    % Class 1
    -1.2565, 3.4912;
    -0.7973, 1.2288;
    1.1170, 2.2637
];
% Labels for the input features.
labels = [0; 0; 0; 1; 1; 1];
% We want to know the class and
% posterior class probabilities for this point.
test = [0, 1];

%% Classification
% Create our model, and use it to evaluate the test point.
model = fitcnb(train, labels, 'Distribution', 'normal')
% label = 1
% Posterior = 0.2493, 0.7507
[label, Posterior] = predict(model, test)

end