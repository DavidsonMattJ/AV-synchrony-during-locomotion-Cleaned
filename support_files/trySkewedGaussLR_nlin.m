function fittedCurve = trySkewedGaussLR_nlin(params,x);


a = params(1); % 
b = params(2); % 
c = params(3); % 


% x1: LHS
x1 = x(find(x<= a));
G1 =  exp(-(x1-a).^2/(2*b^2)) ;

% x2: RHS
x2 = x(find(x > a));
G2 =  exp(-(x2-a).^2/(2*c^2)) ;

fittedCurve =   [ G1  G2  ] ;

