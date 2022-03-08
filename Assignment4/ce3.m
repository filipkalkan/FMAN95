clear
clc
close all
load('ce2.mat')

P = { P_0, P_best };


gamma_k = 10^-10;
P_new = P;
U_new = X;
[error_1 , residuals] = ComputeReprojectionError(P_new, U_new, x_inliers);

figure
plot(0, sum(residuals), 'r*')
hold on

for i = 1:10
    [r, J] = LinearizeReprojErr(P_new, U_new, x_inliers);
    delta_v = -gamma_k * J' * r;
    [P_new, U_new] = update_solution(delta_v, P_new, U_new);
    [error , residuals] = ComputeReprojectionError(P_new, U_new, x_inliers);
    plot(i, sum(residuals), 'r*');
end

RMS = sqrt(error / size(residuals, 2))