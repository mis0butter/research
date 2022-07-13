clear; close all

% Generate Data

x0 = [ -8; 8; 28 ];  % Initial conditions
n = size(x0, 1); 

% Lorenz attractor 
sigma = 10; 
rho   = 28; 
beta  = 8/3; 

dt = 0.01; 
tspan = [0: dt : 10];
options = odeset('RelTol',1e-12,'AbsTol',1e-12*ones(1,n));
% [t,x] = ode45(@(t,x) ode_test(t,x),tspan,x0,options);
[t,x] = ode45(@(t,x) ode_lorenz(t,x,rho,sigma,beta),tspan,x0,options);

% add noise 
x = x + randn(size(x))*0.0001; 

% specify GPR type 
use_gauss = 6;

% specify derivative type 
% 1 = truth, 2 = central difference 
use_dx = 2;  

% sparsification knob 
lambda = 0.01;       

plot3(x(:,1), x(:,2), x(:,3))

%% GP regression 

if use_gauss > 1
    for i = 1:size(x,2)
        switch use_gauss 
            
            % squared exponential 
            case 1 
                gprMdl = fitrgp(t, x(:,i)); 
                
            % squared exponential custom 
            case 1.1 
                sigma0 = 0.2;
                kparams0 = [3.5, 6.2]; 
                gprMdl = fitrgp(t, x(:,i),'KernelFunction','squaredexponential',...
                    'KernelParameters',kparams0,'Sigma',sigma0);
                
            % squared exponential 
            case 2 
                gprMdl = fitrgp(t, x(:,i), 'KernelFunction', 'exponential'); 
                
            % matern 3/2 
            case 3 
                gprMdl = fitrgp(t, x(:,i), 'KernelFunction', 'matern32'); 
                
            % matern 5/2 
            case 4 
                gprMdl = fitrgp(t, x(:,i), 'KernelFunction', 'matern52'); 
                
            % rational quadratic 
            case 5 
                gprMdl = fitrgp(t, x(:,i), 'KernelFunction', 'rationalquadratic'); 
                
            % custom kernel 
            case 6 
                kfcn = @(XN,XM,theta) (exp(theta(2))^2)*exp(-(pdist2(XN,XM).^2)/(2*exp(theta(1))^2));
                theta0 = [1.5,0.2];
                gprMdl = fitrgp(t,x(:,i),'KernelFunction',kfcn,'KernelParameters',theta0);
                
        end 
        x(:,i) = resubPredict(gprMdl); 
    end 
end

figure
plot(x)
title('Gauss Process x') 


%% Compute Derivative

for i = 1:length(x)
%     dx_t(i,:) = ode_test(t(i),x(i,:)); 
    dx_t(i,:) = ode_lorenz(t(i),x(i,:),rho,sigma,beta); 
end

% forwards difference 
for i = 1:length(x) 
    if ~isequal(i, length(x))
        dx_f(i,:) = ( x(i+1,:) - x(i,:) ) / dt; 
    else
        dx_f(i,:) = ( x(i,:) - x(i-1,:) ) / dt; 
    end 
end 

% central difference 
for i = 1:length(x) 
    if i == 1
        dx_c(i,:) = ( x(i+1,:) - x(i,:) ) / dt; 
    elseif i == length(x)
        dx_c(i,:) = ( x(i,:) - x(i-1,:) ) / dt;             
    else
        dx_c(i,:) = ( x(i+1,:) - x(i-1,:) ) / (2*dt); 
    end 
end 

% backwards difference 
for i = 1:length(x) 
    if i > 1
        dx_b(i,:) = ( x(i,:) - x(i-1,:) ) / dt; 
    else 
        dx_b(i,:) = ( x(i+1,:) - x(i,:) ) / dt; 
    end 
end 
 
plot_option = 1; 
if plot_option == 1
    figure() 
        hold on; grid on; 
        % truth 
            sz = 2; 
            leg(1) = plot(t, dx_t(:,1), 'linewidth', sz); 
            if size(dx_t, 2) > 1
                plot(t, dx_t(:,2), 'linewidth', sz)
                if size(dx_t, 2) > 2
                    plot(t, dx_t(:,3), 'linewidth', sz)
                end 
            end 
        % central 
%         plot(t, dx_f, '--', 'linewidth', 1.5) 
            sz = 1; 
            leg(2) = plot(t, dx_c(:,1), '--', 'linewidth', sz); 
            if size(dx_t, 2) > 1
                plot(t, dx_c(:,2), '--', 'linewidth', sz)
                if size(dx_t, 2) > 2
                    plot(t, dx_c(:,3), '--', 'linewidth', sz)
                end 
            end 
%         plot(t, dx_b, '--')
    legend(leg, 't', 'c')
end 


% add noise 
% dx = dx + randn(size(dx))*0.00000001; 

%% Build library and compute sparse regression

if use_dx == 1
    dx = dx_t; 
elseif use_dx == 2
    dx = dx_c; 
end 

usesine = 1;
xin = [x,t];
polyorder = n;
Theta = poolData(xin, n, polyorder, usesine);  % up to third order polynomials
% lambda = 1; 
Xi = sparsifyDynamics(Theta, dx, lambda, n); 

for i = 1:n
    x_n{i} = sprintf('x%d', i); 
end 
poolDataLIST(x_n, Xi, n, polyorder, usesine);


%% dynamics functions 

function dx = ode_test(t,x)

dx = [
%     -x(1)^2 + sin(x(1)); 
    x(1)*x(2) ;
    -1/2 * x(1) ; 
%     -1/8 * x(3) 
%     0
    ];

end 

% Lorenz attractor 
function dx = ode_lorenz(t, x, sigma, rho, beta)

dx = [ 
   sigma * (x(2) - x(1)); 
   x(1) * ( rho - x(3) ) - x(2); 
   x(1) * x(2) - beta * x(3); 
]; 

end 







