clear all, close all, clc
%% Generate Data
% m = 1;
% c = 0.1;
% k = 0.5;
n = 5;
% 4th order polynomial + input
x0 = [0.2; 1; 0; 0;0];  % Initial conditions
tspan = [0:.01:20];
options = odeset('RelTol',1e-12,'AbsTol',1e-12*ones(1,n));
[t,x] = ode45(@(t,x) two_mass_spring_damper(t,x),tspan,x0,options);

%% Compute Derivative
for i = 1:length(x)
    dx(i,:) = two_mass_spring_damper(t(i,1),x(i,:));
end

%% Build library and compute sparse regression
usesine = 1;
xin = [x,t];
Theta = poolData2(xin,n,4,usesine);  % up to third order polynomials
lambda = 0.025;      % lambda is our sparsification knob.
Xi = sparsifyDynamics(Theta,dx,lambda,n)
polyorder = n;
poolDataLIST2({'x1','x2','x3','x4','x5'},Xi,n,polyorder,usesine);
][][]