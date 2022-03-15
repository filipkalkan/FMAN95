%%
load compEx3data.mat
im1 = imread('cube1.JPG');
im2 = imread('cube2.JPG');
[f1, d1] = vl_sift( single(rgb2gray(im1)), 'PeakThresh', 1);
[f2, d2] = vl_sift( single(rgb2gray(im2)), 'PeakThresh', 1);
% vl_plotframe(f1);
% vl_plotframe(f2);
[matches ,scores] = vl_ubcmatch(d1,d2);
x1 = [f1(1,matches (1 ,:));f1(2,matches (1 ,:))];
x2 = [f2(1,matches (2 ,:));f2(2,matches (2 ,:))];
perm = randperm(size(matches ,2));
figure;
imagesc ([im1 im2]);
hold on;
plot([x1(1,perm (1:10)); x2(1,perm (1:10))+ size(im1 ,2)], ...
[x1(2,perm (1:10)); x2(2,perm (1:10))] ,'-');
hold off;
save('vl_data.mat', 'x1', 'x2')
%%
clear
im1 = imread('cube1.JPG');
im2 = imread('cube2.JPG');
load('compEx3data.mat');
load('ce3_vars.mat');
load('vl_data.mat')

Xmodel = [Xmodel; ones(1, size(Xmodel, 2))];
[n, kx] = size(x1);

%Normalize
cameras{1} = inv(K1) * cameras{1};
cameras{2} = inv(K2) * cameras{2};
x1 = pflat(inv(K1) * [x1; ones(1,kx)]);
x2 = pflat(inv(K2) * [x2; ones(1,kx)]);

X = [];
for i=1:kx
    M = [
        cameras{1} -x1(:, i) zeros(3,1);
        cameras{2} zeros(3,1) -x2(:, i)
    ];
    [U, S, V] = svd(M);
    v = V(:, end);
    X = [X v(1:4)];
end
X = pflat(X);

%Denormalize cameras
cameras{1} = K1 * cameras{1};
cameras{2} = K2 * cameras{2};

x1_projected = pflat(cameras{1} * X);
x2_projected = pflat(cameras{2} * X);
x1 = pflat(K1 * x1);
x2 = pflat(K2 * x2);

figure
imshow(im1)
hold on
axis equal
plot(x1(1,:), x1(2,:), '*')
plot(x1_projected(1,:), x1_projected(2,:), 'o')
hold off

figure
imshow(im2)
hold on
axis equal
plot(x2(1,:), x2(2,:), '*')
plot(x2_projected(1,:), x2_projected(2,:), 'o')
hold off

%Compute the errors
good_points = ((sqrt(sum((x1(1:2, :) - x1_projected(1:2 ,:)).^2)))  < 3 & ...
               (sqrt(sum((x2(1:2, :) - x2_projected(1:2 ,:)).^2)))  < 3);
           
X_good_points = X(:,good_points);
x1_good_points = x1(:,good_points);
x2_good_points = x2(:,good_points);

X_good_points_on_P1 = pflat(cameras{1}*X_good_points);
X_good_points_on_P2 = pflat(cameras{2}*X_good_points);

figure
imshow(im1);
hold on
plot(X_good_points_on_P1(1,:), X_good_points_on_P1(2,:), '*')
plot(x1_good_points(1,:), x1_good_points(2,:), 'o')

figure
imshow(im2);
hold on
plot(X_good_points_on_P2(1,:), X_good_points_on_P2(2,:), '*')
plot(x2_good_points(1,:), x2_good_points(2,:), 'o')

%3d plot
figure
plot3(X_good_points(1,:), X_good_points(2,:), X_good_points(3,:), 'r.')
hold on
plot3([Xmodel(1,startind);  Xmodel(1,endind)],...
      [Xmodel(2,startind );  Xmodel(2,endind )],...
      [Xmodel(3,startind );  Xmodel(3,endind)],'b-');

plotcams(cameras)