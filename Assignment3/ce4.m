clear
close all
load ce1.mat
load essential-matrix.mat
load compEx1data.mat
load compEx3data.mat

W = [
    0 -1 0;
    1 0 0; 
    0 0 1
];

P1 = [
    1 0 0 0;
    0 1 0 0; 
    0 0 1 0
];

x_normalized = x;
x_normalized{1} = K\x{1};
x_normalized{2} = K\x{2};

index = 'abcd';
for i=1:length(index)

    if i == 1
        P2_i = [U*W*V' (U(:,3))];
    end
    if i == 2
        P2_i = [U*W*V' -(U(:,3))];
    end
    if i == 3
        P2_i = [U*W'*V' (U(:,3))];
    end
    if i == 4
        P2_i = [U*W'*V' -(U(:,3))];
    end

    [M_i, X3D_i] = triangulate(x_normalized, P1, P2_i);
    X3D_i = pflat(X3D_i);

    figure('Name', strcat('Camera matrix P2_', index(i)))
    plot3(X3D_i(1,:), X3D_i(2,:), X3D_i(3,:), '.')
    hold on
    plotcams({P1, P2_i})

    figure('Name', strcat('3D P2_', index(i)))
    P2_i_normalized = K * P2_i;
    x_i = P2_i_normalized * X3D_i;
    x_i = pflat(x_i);
    image = imread('kronan2.JPG');
    imshow(image);
    hold on
    plot(x_i(1,:),x_i(2,:),'bo');
    hold on
    plot(x{2}(1,:),x{2}(2,:),'r*');
    hold on
end

P1_normalized = K * P1;
