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

load("ce1.mat")

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

    [n, kx] = size(xA_selection);
    M = [];
    for col=1:kx
        for row=1:n
            X_transpose_indent = zeros(1, 3*(row-1));
            X_transpose_padding = zeros(1, 3*2 - size(X_transpose_indent, 2));
            X_transpose = xA_selection(:, col)';
            y = xB_selection(row, col);
            y_indent = zeros(1, col-1);
            final_padding = zeros(1, kx-col);
            M = [
                M;
                X_transpose_indent X_transpose X_transpose_padding y_indent -y final_padding
            ];
        end
    end 

    [U,S,V] = svd(M);
    v = V(:,end);
    H = [
        v(1:3)';
        v(4:6)';
        v(7:9)'
    ];

    xA_transformed = pflat(H*xA);
    
    inliers = sqrt(sum((xA_transformed-xB).^2))<5;
    if sum(inliers == 1) > sum(inliers_best == 1)
        H_best = H;
        inliers_best = inliers;
    end

end

fprintf("Found %d inliers in best iteration", sum(inliers_best == 1))

Htform = projective2d( H_best' );
Rout = imref2d( size(im1), [-200 800], [-400,600]);
[Atransf] = imwarp(im1, Htform, 'OutputView', Rout);
Idtform=projective2d(eye(3));
[Btransf] = imwarp(im2, Idtform, 'Outputview', Rout);

AB = Btransf;
AB(Btransf<Atransf) = Atransf(Btransf<Atransf);

figure()
imagesc(Rout.XWorldLimits, Rout.YWorldLimits, AB)