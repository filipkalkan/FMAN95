clear
close all
load('ce2.mat')


P = {P_0, P_best};
lambda = 0.1;
P_new = P;
U_new = X;

[error_1 , residuals] = ComputeReprojectionError(P_new, U_new, x_inliers);
figure
plot(0, sum(residuals),'b*')
hold on

for i = 1:10
    [r, J] = LinearizeReprojErr(P_new, U_new, x_inliers);
    C = J' * J + lambda * speye(size(J, 2));
    c = J'*r;
    delta_v = -C \ c;
    [P_new, U_new] = update_solution(delta_v,P_new,U_new);
    [err , residuals] = ComputeReprojectionError(P_new,U_new,x_inliers);
    plot(i, sum(residuals), 'b*')
end

RMS = sqrt(err / size(residuals, 2))