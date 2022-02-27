clear;
load('compEx1data.mat');

% Calculate the image points mean and standard deviation
x1_mean = mean(x{1}(1:2,:),2);
x1_std = std(x{1}(1:2,:),0,2);
x2_mean = mean(x{2}(1:2,:),2);
x2_std = std(x{2}(1:2,:),0,2);
s1 = 1/x1_std(1);
s2 = 1/x2_std(1);

% Normalize image points
N1 = [
    s1 0 -s1*x1_mean(1);
    0 s1 -s1*x1_mean(2);
    0 0 1;
];
N2 = [
    s2 0 -s2*x2_mean(1);
    0 s2 -s2*x2_mean(2);
    0 0 1;
];
% N1 = eye(3,3);
% N2 = eye(3,3);
x1_normalized = N1*x{1};
x2_normalized = N1*x{2};

% Construct M for eight point algorithm
[number_of_coordinates, number_of_points] = size(x{1});

M = [];
for point=1:number_of_points
    M_col_transposed = x2_normalized(:, point) * x1_normalized(:, point)';
    M(point, :) = M_col_transposed(:)';
end

% Find F with singular value decomposition
[U, S, V] = svd(M);
v = V(:,end);
F_normalized = reshape(v, [3 3]);

% Make the determinant of F zero
F_determinant_before = det(F_normalized);
[U,S,V] = svd(F_normalized);
S(3, end) = 0;
F_normalized = U*S*transpose(V);

% Verify that the new F is valid and better
F_determinant_after = det(F_normalized); % A lot smaller than it was before

eigen_matrix = S' * S;
min_eigen_value = min( eigen_matrix(eigen_matrix>0) ); % Minimum singular value 0.4789

v = V(:,end);
norm_M_v = norm(F_normalized * v); % 6.9389e-18

% Plot state of epipolar constraints
figure
plot(diag(x2_normalized' * F_normalized * x1_normalized)); % All values pretty close to zero

% Denormalize F
F = N2' * F_normalized * N1;

% Compute epipolar lines
epipolar_lines = F*x{1};
epipolar_lines = epipolar_lines./sqrt(repmat(epipolar_lines(1 ,:).^2 + epipolar_lines(2 ,:).^2 ,[3 1]));

lines_to_plot = randperm(20);
im = imread('kronan2.JPG');
figure
imshow(im)
hold on
rital(epipolar_lines(:,lines_to_plot(1:20)),'b-')
plot(x{2}(1,lines_to_plot(1:20)), x{2}(2,lines_to_plot(1:20)),'r*')
hold off

figure
distances = (abs(sum(epipolar_lines.*x{2})));
hist(distances, 100);
distance_mean = mean(distances)
F = F./F(3,3)
save('ce1.mat','F','N1','N2');





