function [M, X3D]=triangulate(x, P1, P2)
clear X3D;
M={};

[n, kx] = size(x{1});
eqnbr = 0;
for i=1:kx
    eqnbr = eqnbr+1;
    M{i}=[P1, -x{1}(:,i), zeros(3, 1); P2, zeros(3, 1), -x{2}(:,i)];
    
end
X3D = [];
for j=1:kx
    [U ,S ,V] = svd(M{j});
    v = V(1:4,end);
    X3D = [X3D, v(1:4,1)];
end