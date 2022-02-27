clear
close all;
load compEx3data.mat
load compEx1data.mat

x1_normalized = K\x{1};
x2_normalized = K\x{2};

[m, kx] = size(x1_normalized);

% Construct the M matrix
M = [];
for col=1:kx
    xx = x2_normalized(:,col)*x1_normalized(:,col)';
    M(col,:) = xx(:)';
end

[U, S, V] = svd(M);
v = V(:,end);

eigen_matrix = S' * S;
min_eigen_value = min( eigen_matrix(eigen_matrix>0) ); % Minimum singular value 4e-5

v = V(:,end);
norm_M_v = norm(M * v); % 0.0066

% Construct the essential matrix
E = reshape(v, [3 3]);
[U, S, V] = svd(E);

if det(U*V')>0
    E = U * diag ([1 1 0]) * V';
else
    V = -V;
    E = U * diag ([1 1 0]) * V';
end
disp('E');
matlab2latex(E./E(3,3));
save('essential-matrix.mat','U','V');

figure
plot(diag(x2_normalized' * E * x1_normalized))

F = K'\E/K;
figure
plot(diag(x{2}' * F * x{1}));
l = F * x{1};
l = l./sqrt(repmat(l(1 ,:).^2 + l(2 ,:).^2 ,[3 1]));
random_points = randperm(20);
image = imread('kronan2.JPG');
imshow(image)
hold on
rital(l(:,random_points(1:20)),'b-')
plot(x{2}(1,random_points(1:20)), x{2}(2,random_points(1:20)),'r*')


figure
distance = abs(sum(l.*x{2}));
hist(distance, 100);
distance_mean = mean(distance)