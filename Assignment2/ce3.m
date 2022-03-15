clear;
close all;

load compEx3data.mat

cameras = {};

for i=1:size(x,2)
    x_i_mean = mean(x{i}(1:2,:), 2);
    x_i_std = std(x{i}(1:2,:), 0, 2);
    s = 1/x_i_std(1);
    x_mean = x_i_mean(1);
    y_mean = x_i_mean(2);
    N = [
        s 0 -s*x_mean;
        0 s -s*y_mean;
        0 0 1;
    ];
    normalized_points = N*x{i};
    
    axis equal
    figure
    plot(normalized_points(1,:),normalized_points(2,:),'.');

    % Looks like points are centered around (0, 0) with mean distance 1 to
    % origin

    [n, kx] = size(Xmodel);
    [m, ky] = size(x{i});

     M = [];
    for col=1:kx
        for row=1:n
            X_transpose_indent = zeros(1, 4*(row-1));
            X_transpose_padding = zeros(1, 4*2 - size(X_transpose_indent, 2));
            X_transpose = Xmodel(:, col)';
            y = normalized_points(row, col);
            y_indent = zeros(1, col-1);
            final_padding = zeros(1, kx-col);
            M = [
                M;
                X_transpose_indent X_transpose 1 X_transpose_padding y_indent -y final_padding
            ];
        end
    end 

    
    [U, S, V] = svd(M);
    eigen_matrix = S' * S;
    min_eigen_value = min( eigen_matrix(eigen_matrix>0) ) % (0.7255, pretty close to zero)
    
    v = V(:,end);
    norm_M_v = norm(M * v) % 0.8517 pretty close to zero
    
    P = reshape (v(1:12), [4 3])';
    P_denormalized = inv(N)*(P) % (-P) So we use the positive solution (where camera faces towards the scene points, giving positive depths)
    cameras{i} = P_denormalized;

    X = [Xmodel;ones(1,size(Xmodel,2))];
    x_projected = pflat( P_denormalized * X );
    
    % Plot projected points
    figure
    im = imread(strcat( strcat('cube',string(i)) , '.JPG'));
    imshow(im);
    
    hold on
    plot(x{i}(1,:),x{i}(2,:),'o')
    plot(x_projected(1,:), x_projected(2,:),'*'); % Very close to each other! :D 
end

% Plot cameras and model
figure
plot3([Xmodel(1,startind );  Xmodel(1,endind )],...
      [Xmodel(2,startind );  Xmodel(2,endind )],...
      [Xmodel(3,startind );  Xmodel(3,endind)],'b-');
hold on
axis equal
plot3(Xmodel(1,:),Xmodel(2,:),Xmodel(3,:),'x')
plotcams(cameras)

% Plot camera centers
camera_center_1 = pflat(null(cameras{1}));
camera_center_2 = pflat(null(cameras{2}));

plot3(camera_center_1(1,:),camera_center_1(2,:),camera_center_1(3,:),'g*')
plot3(camera_center_2(1,:),camera_center_2(2,:),camera_center_2(3,:),'b*')

[K1 Q1] = rq(cameras{1})
[K2 Q2] = rq(cameras{2})

save('ce3_vars','cameras','K1','K2');

matlab2latex(K1./K1(3,3));
matlab2latex(Q1);
matlab2latex(K2./K2(3,3));
matlab2latex(Q2);