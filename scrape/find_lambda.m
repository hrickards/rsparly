clear ; close all; clc

num_labels = 2;
lambda_min = 0.00001;
lambda_max = 10;

%% Load data into X and y
load -ascii y_data.txt;
load -ascii x_data.txt;
y = y_data;
X = x_data;
X = [ones(size(X, 1), 1) X];

%% Load test data into X and y
load -ascii test_y_data.txt;
load -ascii test_x_data.txt;
y_test = test_y_data;
X_test = test_x_data;
X_test = [ones(size(X_test, 1), 1) X_test];


lambda_step = (lambda_max - lambda_min) / 10;

lambdas = [];
vals = [];

for i = 0:9
  lambda = lambda_min + lambda_step * i;

  [all_theta] = oneVsAll(X, y, num_labels, lambda);

  pred = predictOneVsAll(all_theta, X_test);
  val = mean(double(pred == y_test)) * 100;

  lambdas = [lambdas lambda];
  vals = [vals val];
end

plot(lambdas, vals)
