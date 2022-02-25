clear;

load compEx1data.mat;

T1 = [1 0 0 0; 0 4 0 0; 0 0 1 0; 1/10 1/10 0 1];
T2 = [1 0 0 0; 0 1 0 0; 0 0 1 0; 1/16 1/16 0 1];

P_T1_tilde = P;
P_T2_tilde = P;
for i=1:size(P,2)
    P_T1_tilde{i} = P{i} * inv(T1);
    P_T2_tilde{i} = P{i} * inv(T2);
end

P_i = P_T1_tilde{3};
P_j = P_T2_tilde{3};

[r1, q1] = rq(P_i)
[r2, q2] = rq(P_j)

K1 = r1;
K2 = r2;

K1 = K1./K1(3,3)

% K1 =
% 
%    1.0e+03 *
% 
%     2.3937    0.3284    0.9486
%          0    0.6481    0.9267
%          0         0    0.0010

K2 = K2./K2(3,3)
% K2 =
% 
%    1.0e+03 *
% 
%     2.3940    0.0000    0.9324
%          0    2.3981    0.6283
%          0         0    0.0010