close all
clear all

% some data: proptions synchronous vs SOA   

    SOAs =   [-1024  -512   -256  -128  -64   0    64  128  256  512  1024 ];
    pSync =  [ 0       0     .02   .15  .55  .87  .95  .91  .72   .3  .05  ] ;



NLIN= 1; % 1 for NLINFIT; 0 or FMINSEARCH; 
              % Note: Only NLINFIT gives CIs and takes Weights



startingVals = [ 0  50  100   1 ]; % .1];
if NLIN
    [ estimates,  resid, jacob, covarEst mse ] = nlinfit(SOAs, pSync,  @trySkewedGaussLR_nlin,startingVals );
    ci = nlparci(estimates, resid, 'jacobian' , jacob); % calculate 95% confidence limits around estimates.
else
    options = optimset; 
    estimates = fminsearch(@trySkewedGaussLR,startingVals,options,SOAs ,pSync);    
end
estimates = round(estimates*1000)/1000;

a = estimates(1); % Mean
b = estimates(2); % SD of left half
c = estimates(3); % SD of right half
%%
% test:
% 
% 'mean    left SD   right SD'
% [ a b c ]

clf; 
plot(SOAs, pSync); 
fitC = trySkewedGaussLR_nlin(estimates, SOAs);
hold on;
plot(SOAs, fitC, 'r');

