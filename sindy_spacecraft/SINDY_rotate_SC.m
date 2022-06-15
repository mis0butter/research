clear all, close all, clc

%% Generate Data

Ixx = 1; 
Iyy = 2; 
Izz = 4; 

n = 3; 

% Initial conditions
x0    = [0.02; 0.1; 0.1];  
dt = 0.01; 
tspan = [0:dt:10];
options = odeset('RelTol',1e-12,'AbsTol',1e-12*ones(1,n));
[t, x] = ode45(@(t,x) rotate_SC(t, x, Ixx, Iyy, Izz), tspan, x0, options);

% noise 
% x = x + rand(size(x))*0.1; 

%% Compute Derivative

% truth dynamics
for i = 1:length(x)
    dx_a(i,:) = rotate_SC(t(i,1), x(i,:), Ixx, Iyy, Izz);
end

% computed derivatives 

diff_option = 2; 

if diff_option == 1
    
    % forwards difference 
    for i = 1:length(x) 
        if ~isequal(i, length(x))
            dx_b(i,:) = ( x(i+1,:) - x(i,:) ) / dt; 
        else
            dx_b(i,:) = ( x(i,:) - x(i-1,:) ) / dt; 
        end 
    end     
    
elseif diff_option == 2

    % central difference 
    for i = 1:length(x) 
        if i == 1
            dx_b(i,:) = ( x(i+1,:) - x(i,:) ) / dt; 
        elseif i == length(x)
            dx_b(i,:) = ( x(i,:) - x(i-1,:) ) / dt;             
        else
            dx_b(i,:) = ( x(i+1,:) - x(i-1,:) ) / (2*dt); 
        end 
    end 
    
else
    
    % backwards difference 
    for i = 1:length(x) 
        if i > 1
            dx_b(i,:) = ( x(i,:) - x(i-1,:) ) / dt; 
        else
            dx_b(i,:) = ( x(i+1,:) - x(i,:) ) / dt; 
        end 
    end 
    
end 

figure()
plot(t, dx_a, t, dx_b, '--', 'linewidth', 2)

dx = dx_b; 

%% Build library and compute sparse regression

usesine = 0;
xin=[x,t];
Theta = poolData(xin,n,3,usesine);  % up to third order polynomials
lambda = 0.025;      % lambda is our sparsification knob.
% lambda = 0.05; 
Xi = sparsifyDynamics(Theta,dx,lambda,n)
polyorder = n;
poolDataLIST({'x1','x2','x3'},Xi,n,polyorder,usesine);
