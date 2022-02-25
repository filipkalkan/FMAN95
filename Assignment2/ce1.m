clear

% Plot points with cameras

load compEx1data.mat
figure(1)
axis equal
plot3(X(1,:), X(2,:), X(3,:), '*', 'Markersize', 2)
hold on
plotcams(P)
hold off
% Looks very reasonable!

%%

figure(2)
axis equal

i = 3;
image_i = imread ( imfiles { i }); % Reads the imagefile with name in imfiles {i}
imshow(image_i)
hold on
visible = isfinite (x{ i  }(1 ,:));
P_i = P{i};
x_i = x{i};

% Plot image points on image
plot(x_i(1, visible),x_i(2, visible),'*','Markersize',2);

% Plot 3D points on image
hold on
xproj = pflat(P_i * X);
plot(xproj(1, visible), xproj(2, visible),'go','Markersize',4)
% Looks reasonable

%%
T1 = [1 0 0 0; 0 4 0 0; 0 0 1 0; 1/10 1/10 0 1];
T2 = [1 0 0 0; 0 1 0 0; 0 0 1 0; 1/16 1/16 0 1];

X_T1_tilde = pflat(T1 * X);
X_T2_tilde = pflat(T2 * X);

P_T1_tilde=P;
P_T2_tilde=P;
for i=1:size(P,2)
    P_T1_tilde{i} = P{i} * inv(T1);
end
for i=1:size(P,2)
    P_T2_tilde{i} = P{i} * inv(T2);
end

% Plot transformation 1
figure(3)
axis equal
plot3(X_T1_tilde(1, visible),X_T1_tilde(2, visible), X_T1_tilde(3, visible),'*','Markersize',2);
hold on
plotcams(P_T1_tilde)
hold off

% Plot transformation 2
figure(4)
axis equal
plot3(X_T2_tilde(1, visible),X_T2_tilde(2, visible), X_T2_tilde(3, visible),'*','Markersize',2);
hold on
plotcams(P_T2_tilde)
hold off

%%
% Project new 3D points from T1 onto camera 3
figure(5)
imshow(image_i)
hold on
axis equal
visible = isfinite (x{ i  }(1 ,:));

x_i = x{i};

% Plot image points on image
plot(x_i(1, visible),x_i(2, visible),'*','Markersize',2);
hold on

% Plot 3D points on image
xproj = P_T1_tilde{3} * X_T1_tilde;
xproj = pflat(xproj);
plot(xproj(1, visible), xproj(2, visible),'go','Markersize',4)
% Looks good!