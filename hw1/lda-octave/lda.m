function lda

clear;
close all;

% Define some simple comments to make things more readable.
NO = 0;
YES = 1;

% Here's the data as it was provided in the homework.
DATA = [
	25000,	NO;
	35000,	NO;
	32000,	YES;
	41000,	NO;
	42000,	NO;
	43000, 	YES;
	44000, 	YES;
	47500, 	NO;
	49000, 	YES;
	53000, 	YES;
	53500, 	NO
]

OWNERS = DATA( find(DATA(:,2)),1 );
NONOWNERS = setdiff(DATA(:,1), OWNERS);

hold on;
plot(NONOWNERS, NO, 'xr', 'LineWidth', 3);
plot(OWNERS, YES, 'og', 'LineWidth', 3);

end
