function [C] = top(YO, WO, S, TCHL)


if TCHL == 1          	% Rectangular channel
  C= WO;
elseif TCHL == 2,     	% Trapezoidal channel
  C= WO+2.*YO.*S;
else % TCHL == 3,	% Natural channel
  [N,M] = size(WO);
  W1 = WO(:,1);
  W2 = WO(:,2:M);
  WI = interp1(W1, W2, YO);
  C = diag(WI)';
  clear W1 W2 WI N M;
end

  

