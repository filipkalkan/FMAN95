function x_new = pflat(x)
    last_row = x(end, :);
    [rows, ~] = size(x);
    div_matrix = repmat(last_row, [rows, 1]);
    x_new = x ./ div_matrix;
end