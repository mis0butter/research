function dx = rotate_SC(t, x, Ixx, Iyy, Izz)

dx = zeros(3,1); 

dx(1) = (Iyy' - Izz') * x(3) * x(2) / Ixx';
dx(2) = (Izz' - Ixx') * x(3) * x(1) / Iyy'; 
dx(3) = (Ixx' - Iyy') * x(2) * x(1) / Izz'; 

% dx(1) = x(3) * x(2); 
% dx(2) = x(3) * x(1); 
% dx(3) = x(2) * x(1); 

end 

