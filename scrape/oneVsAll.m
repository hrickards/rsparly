function [all_theta] = oneVsAll(X, y, num_labels, lambda)
  for i = 1:num_labels
    %% Vector of 1s and 0s
    labels = y == i;

    initial_theta = zeros(size(X, 2), 1);
    options = optimset('GradObj', 'on', 'MaxIter', 50);

    [theta] = fminunc(@(t)(costFunction(t, X, labels, lambda)), initial_theta, options);

    all_theta(i,:) = theta;
  end
end
