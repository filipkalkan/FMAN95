clear;
load("ce1.mat");
load('compEx1data.mat');

P1 = [
    1 0 0 0;
    0 1 0 0;
    0 0 1 0
];

e2 = null(F');
e2_x = [
    0 -e2(3) e2(2);
    e2(3) 0 -e2(1);
    -e2(2) e2(1) 0
];

P2 = [e2_x*F e2];

x_normalized = x;
x_normalized{1} = N1*x{1};
x_normalized{2} = N2*x{2};
P1_normalized = N1*P1;
P2_normalized = N1*P2;

disp('P1');
matlab2latex(P1);
disp('P1_normalized');
matlab2latex(P1_normalized);
disp('P2');
matlab2latex(P2);
disp('P2_normalized');
matlab2latex(P2_normalized);

[M, X_3D] = triangulate(x_normalized, P1_normalized, P2_normalized);

x_on_P1 = pflat(P1_normalized * X_3D);
x_on_P2 = pflat(P2_normalized * X_3D);

x_on_P1_normalized = inv(N1) * x_on_P1;
x_on_P2_normalized = inv(N2) * x_on_P2;

image = imread("kronan1.JPG");
figure
imshow(image);
hold on;
axis equal;
plot(x_on_P1_normalized(1,:), x_on_P1_normalized(2,:), 'r*');
plot(x{1}(1,:), x{1}(2,:), 'bo');

image = imread("kronan2.JPG");
figure
imshow(image);
hold on;
axis equal;
plot(x_on_P2_normalized(1,:), x_on_P2_normalized(2,:), 'r*');
plot(x{2}(1,:), x{2}(2,:), 'bo');

figure
X_3D = pflat(X_3D);
plot3(X_3D(1,:), X_3D(2,:), X_3D(3,:), '*')