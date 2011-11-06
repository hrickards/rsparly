function p = predictOneVsAll(all_theta, X)
  [val, index] = max(sigmoid(X * all_theta'), [], 2);
  p = index;
end
