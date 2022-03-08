close all;
load('compEx2data.mat')

im1 =imread('im1.jpg');
im2 = imread('im2.jpg');

x1_normalized = inv(K) * [x{1}; ones(1, size(x{1}, 2))];
x2_normalized = inv(K) * [x{2}; ones(1, size(x{2}, 2))];


E_best = [];
inliers_best = [];


for i = 1:20
    random_indices = randperm(size(matches, 2), 5);
    x1_selection = xA(:, random_indices);
    x2_selection = xB(:, random_indices);

    E = fivepoint_solver(x1_selection, x2_selection);

end