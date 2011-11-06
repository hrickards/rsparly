function [J, grad] = costFunction(theta, X, y, lambda)
  m = length(y);
  hypothesis = sigmoid(X * theta);
  theta2 = theta(2:end);
  J = (1/m)*sum(-y.*log(hypothesis)-(1-y).*log(1-hypothesis)) + (lambda/(2*m)) * sum(theta2.^2);
  grad = (1/m) * (X' * (hypothesis - y) + [0, (lambda * theta2)']');
end
