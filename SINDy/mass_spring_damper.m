function dx = mass_spring_damper(t,x,m,c,k)
dx = [
x(2);
-(c/m)*x(1)-(k/m)*x(2)+x(3);
-2*sin(2*t);
];