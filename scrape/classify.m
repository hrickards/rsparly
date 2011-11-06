clear ; close all; clc

lambda = 0.01;

%% Load data into X and y
load -ascii y_data.txt;
load -ascii x_data.txt;
y = y_data;
X = x_data;
X = [ones(size(X, 1), 1) X];

num_labels = max(y)

[all_theta] = oneVsAll(X, y, num_labels, lambda);
save -ascii theta.mat all_theta;

%% Load test data into X and y
load -ascii test_y_data.txt;
load -ascii test_x_data.txt;
y = test_y_data;
X = test_x_data;
X = [ones(size(X, 1), 1) X];

load theta.mat, all_theta;

pred = predictOneVsAll(all_theta, X);
fprintf('MSE: %f\n', sum((pred - y).^2)/length(y));
fprintf('\nAccuracy: %f\n', mean(double(pred == y)) * 100);
pred_acc = pred == y
save -ascii ac_pred.txt pred_acc
save -ascii pred.txt pred
save -ascii ac.txt pred
