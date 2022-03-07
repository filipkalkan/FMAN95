close all;
im1 = imread('a.jpg');
im2 = imread('b.jpg');

figure();
imshow(im1);

figure();
imshow(im2);

[ fA, dA ] = vl_sift( single( rgb2gray(im1 )) ); % a.jpg has 947 sift features
[ fB, dB ] = vl_sift( single( rgb2gray(im2 )) ); % b.jpg has 865 sift features
matches = vl_ubcmatch(dA , dB ); % There are 204 matches

save('ce1.mat','fA','fB','dA', 'dB', 'matches');

xA = [ 
    fA(1:2, matches(1,:)); 
    ones(1, size(matches, 2))
];
xB =[
    fB(1:2, matches(2, :));
    ones(1, size(matches, 2))
];

H_best = [];
inliers_best = [];
for i = 1:20
    random_indices = randperm(size(matches, 2), 4);
    xA_selection = xA(:, random_indices);
    xB_selection = xB(:, random_indices);
    X = xA_selection(1, :);
    Y = xA_selection(2, :);
    x = xB_selection(1, :);
    y = xB_selection(2, :);

    rows0 = zeros(3, 4);
    rowsXY = -[X; Y; ones(1,4)];
    M_A = [rowsXY; rows0; x.*X; x.*Y; x];
    M_B = [rows0; rowsXY; y.*X; y.*Y; y];
    M = [M_A M_B];

    [U,S,V] = svd(M);
    v = V(:,end);
    H = [
        v(1:3)';
        v(4:6)';
        v(7:9)'
    ];
end