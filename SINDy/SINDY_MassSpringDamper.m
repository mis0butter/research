clear all, close all, clc
%% Generate Data
m = 1;
c = 0.1;
k = 0.5;
n = 3;
x0 = [0.02; 0;0];  % Initial conditions
tspan = [0:.01:10];
options = odeset('RelTol',1e-12,'AbsTol',1e-12*ones(1,n));
[t,x] = ode45(@(t,x) mass_spring_damper(t,x,m,c,k),tspan,x0,options);

%% Compute Derivative
for i = 1:length(x)
    dx(i,:) = mass_spring_damper(t(i,1),x(i,:),m,c,k);
end

%% Build library and compute sparse regression
usesine=1;
xin=[x,t];
Theta = poolData(xin,n,3,usesine);  % up to third order polynomials
lambda = 0.025;      % lambda is our sparsification knob.
Xi = sparsifyDynamics(Theta,dx,lambda,n)
polyorder = n;
poolDataLIST({'x1','x2','x3'},Xi,n,polyorder,usesine);
