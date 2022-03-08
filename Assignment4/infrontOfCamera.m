function [a,b] = infrontOfCamera(P,x,x1norm,x2norm)
    P_0 = [eye(3) zeros(3, 1)];
    infront = zeros(size(P, 2));
    X = [];
    
    for i = 1:size(P, 2)
        for j = 1:size(x{1},2)
            M = [
                P_0 -x1norm(:,j) zeros(3,1);
                P{i} zeros(3,1) -x2norm(:,j)
            ];
            [~, ~, V] = svd(M);
            v = V(:,end);

            X{i}(1:4, j) = v(1:4, 1);
            depth_0 = depth(P_0, v(1:4, 1));
            depth_1 = depth(P{i}, v(1:4, 1));

            if sign(depth_0) > 0 && sign(depth_1) > 0
                infront(i) = infront(i) + 1;
            end 
        end
    
    end
    [~, max_infront_index] = max(infront);
    a = P{max_infront_index};
    b = X{max_infront_index};


end

function d = depth(P, X)
    d = [];
    for i = 1:size(X, 2)
        d(:,i) = (sign(det(P(:,1:3)))) / (norm(P(:, 1:3), 2) *X(4,i)) * P(3,:) * X(:,i);
    end
end