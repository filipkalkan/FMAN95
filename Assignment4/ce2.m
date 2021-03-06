close all;
clear
load('compEx2data.mat')

im1 =imread('im1.jpg');
im2 = imread('im2.jpg');

x1 = [x{1}; ones(1, size(x{1}, 2))];
x2 = [x{2}; ones(1, size(x{2}, 2))];

x1_normalized = inv(K) * x1;
x2_normalized = inv(K) * x2;


E_best = [];
inliers_best = 0;


% Find best E matrix using RANSAC
for i = 1:100
    random_indices = randperm(size(x1_normalized, 2), 5);
    x1_selection = x1_normalized(:, random_indices);
    x2_selection = x2_normalized(:, random_indices);

    E_candidates = fivepoint_solver(x1_selection, x2_selection);
    for j = 1:size(E_candidates, 2)
        F = inv(K)' * E_candidates{j} * inv(K);
        
        epipolar_line_1 = pflat(F'*x2);
        epipolar_line_1 = epipolar_line_1 ./ sqrt(repmat(epipolar_line_1(1,:).^2 + epipolar_line_1(2,:).^2, [3 1]));

        epipolar_line_2 = pflat(F*x1);
        epipolar_line_2 = epipolar_line_2 ./ sqrt(repmat(epipolar_line_2(1,:).^2 + epipolar_line_2(2,:).^2, [3 1]));
        
        distance_1 = abs(sum(epipolar_line_1 .* x1));
        distance_2 = abs(sum(epipolar_line_2 .* x2));
        
        inliers = (distance_1 < 5) & (distance_2 < 5);

        if sum(inliers(:) == 1) > sum(inliers_best(:) == 1)
            E_best = E_candidates{j};
            inliers_best = inliers;
            distance_1_best = distance_1;
            distance_2_best = distance_2;
        end
    end
end

sum(inliers_best(:)) %1472, as many as there are sift features

P_0 = K * [eye(3,3) zeros(3,1)];
P = camerasFromE(E_best);
[P_best, X] = infrontOfCamera(P, x, x1_normalized, x2_normalized);
P_best = K * P_best;
X = pflat(X);
X = X(:, inliers_best == 1);

x_inliers ={x1(:,inliers_best==1), x2(:,inliers_best==1)};

[error, residuals] = ComputeReprojectionError({ P_0, P_best }, X, x_inliers);
RMS = sqrt(error / size(residuals, 2))

figure
hist(residuals, 100);

figure
plot3(X(1,:), X(2,:), X(3,:), '.', 'Markersize', 3);
axis equal
hold on
plotcams({ P_best, P_0 });

save("ce2",'P_0','P_best','X','x_inliers','K');








