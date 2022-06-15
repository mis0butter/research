function dx = two_mass_spring_damper(t,x)
%Rao(2017) page 535
dx = [
x(2);
x(5)-4*x(2)+x(4)-5*x(1)+2*x(3);
x(4);
x(5)+0.5*x(2)-x(4)+x(1)-1.5*x(3);
-3*sin(3*t);
];