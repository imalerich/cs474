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

classA = data(data(:,3)==1, 1:2);
classB = data(data(:,3)==-1, 1:2);

classA = phi(classA);
classB = phi(classB);

scatter(classA(:,1), classA(:,2), 'LineWidth', 2)
scatter(classB(:,1), classB(:,2), 'LineWidth', 2)

end
