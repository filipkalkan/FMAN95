%%
load compEx3data.mat
im1 = imread('cube1.JPG');
im2 = imread('cube2.JPG');
[f1, d1] = vl_sift( single(rgb2gray(im1)), 'PeakThresh', 1);
[f2, d2] = vl_sift( single(rgb2gray(im1)), 'PeakThresh', 1);
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
load('cameras.mat')
load('vl_data.mat')
[n, kx] = size(x1);

x1_homogenous = [x1; ones(1,kx)];
x2_homogenous = [x2; ones(1,kx)];

DLT={};
for i=1:kx
    DLT{i}=[
        cameras{1}, x1_homogenous(:,i), zeros(3, 1);
        cameras{2}, zeros(3, 1), x2_homogenous(:,i)
    ];
end

X3D = [];
for i=1:kx
    [U,S,V] = svd(DLT{i});
    v = V(:,end);
    X3D = [X3D, v(1:4,1)];
end

x1_projected = pflat(cameras{1}*X3D);
x2_projected = pflat(cameras{2}*X3D);

figure
imshow(im1);
hold on
plot(x1_projected(1,:), x1_projected(2,:), '*')
plot(x1_homogenous(1,:), x1_homogenous(2,:), 'o')

figure
imshow(im2);
hold on
plot(x2_projected(1,:), x2_projected(2,:), '*')
plot(x2_homogenous(1,:), x2_homogenous(2,:), 'o')

%%
%Compare when normalized with inv K
[K1 Q1] = rq(cameras{1});
[K2 Q2] = rq(cameras{2});

DLT={};
for i=1:kx
    DLT{i}=[
        inv(K1)*cameras{1}, inv(K1)*x1_homogenous(:,i), zeros(3, 1);
        inv(K2)*cameras{2}, zeros(3, 1), inv(K2)*x2_homogenous(:,i)
    ];
end

X3D_normalized = [];
for i=1:kx
    [U,S,V] = svd(DLT{i});
    v = V(:,end);
    X3D_normalized = [X3D_normalized, v(1:4,1)];
end

x1_projected_normalized = pflat(cameras{1}*X3D_normalized);
x2_projected_normalized = pflat(cameras{2}*X3D_normalized);


figure
imshow(im1)
hold on
axis equal
plot(x1_homogenous(1,:), x1_homogenous(2,:), '*')
plot(x1_projected_normalized(1,:), x1_projected_normalized(2,:), 'o')
hold off

figure
imshow(im2)
hold on
axis equal
plot(x2_homogenous(1,:), x2_homogenous(2,:), '*')
plot(x2_projected_normalized(1,:), x2_projected_normalized(2,:), 'o')
hold off

%%
%Compute the errors
good_points = (sqrt(sum((x1-x1_projected_normalized(1:2 ,:)).^2))  < 3 & ...
               sqrt(sum((x2-x2_projected_normalized(1:2 ,:)).^2))  < 3);
           
X_good_points = pflat(X3D_normalized(:,good_points));
x1_good_points = x1_homogenous(:,good_points);
x2_good_points = x2_homogenous(:,good_points);

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
load('compEx3data.mat');
figure
plot3(X_good_points(1,:), X_good_points(2,:), X_good_points(3,:), '.')
hold on
plot3([Xmodel(1,startind);  Xmodel(1,endind)],...
      [Xmodel(2,startind );  Xmodel(2,endind )],...
      [Xmodel(3,startind );  Xmodel(3,endind)],'b-');

plotcams(cameras)