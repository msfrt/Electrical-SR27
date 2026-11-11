function membership_function_string = generate_membership_function()
% GENERATE_MEMBERSHIP_FUNCTION  Build one random MF slot as a bit row vector.
%
% Layout (param index k, 0-based, each param is precision_bits long, Gray coded):
%   Difference of Sigmoids (a1 c1 a2 c2)          k = 0-3    sorted (a1 c1)(a2 c2) pairs, c1 <= c2
%   Gaussian (sigma c)                            k = 4-5
%   Generalized Bell (a b c)                      k = 6-8
%   Linear S Shaped (a b)                         k = 9-10   sorted a <= b
%   Linear Z Shaped (a b)                         k = 11-12  sorted a <= b
%   Pi Shaped (a b c d)                           k = 13-16  sorted a <= b <= c <= d
%   Product of Sigmoids (a1 c1 a2 c2)             k = 17-20  sorted (a1 c1)(a2 c2) pairs, c1 <= c2
%   S Shaped (a b)                                k = 21-22  sorted a <= b
%   Sigmoid (a c)                                 k = 23-24
%   Trapezoidal (a b c d)                         k = 25-28  sorted a <= b <= c <= d
%   Triangular (a b c)                            k = 29-31  sorted a <= b <= c
%   Two Sided Gaussian (sigma1 c1 sigma2 c2)      k = 32-35  sorted (sigma1 c1)(sigma2 c2) pairs, c1 <= c2
%   Z Shaped (a b)                                k = 36-37  sorted a <= b
%   Select bits (4 bits, plain binary, 0-12)      after k = 37
%
% Total length = 38*precision_bits + 4

    parameters;   % loads precision_bits etc. from parameters.m
    n = precision_bits;

    membership_function_string = [];   % row vector of 0/1

    % Generate Difference of Sigmoids
    membership_function_string = generate_diff_of_sigmoids(membership_function_string, n);

    % Generate Gaussian
    membership_function_string = generate_gaussian(membership_function_string, n);

    % Generate Generalized Bell
    membership_function_string = generate_generalized_bell(membership_function_string, n);

    % Generate Linear S Shaped
    membership_function_string = generate_linear_s_shaped(membership_function_string, n);

    % Generate Linear Z Shaped
    membership_function_string = generate_linear_z_shaped(membership_function_string, n);

    % Generate Pi Shaped
    membership_function_string = generate_pi_shaped(membership_function_string, n);

    % Generate Product of Sigmoids
    membership_function_string = generate_product_of_sigmoids(membership_function_string, n);

    % Generate S Shaped
    membership_function_string = generate_s_shaped(membership_function_string, n);

    % Generate Sigmoid
    membership_function_string = generate_sigmoid(membership_function_string, n);

    % Generate Trapezoidal
    membership_function_string = generate_trapezoidal(membership_function_string, n);

    % Generate Triangular
    membership_function_string = generate_triangular(membership_function_string, n);

    % Generate Two Sided Gaussian
    membership_function_string = generate_two_sided_gaussian(membership_function_string, n);

    % Generate Z Shaped
    membership_function_string = generate_z_shaped(membership_function_string, n);

    % Generate Select Bits (13 diff funcs)
    membership_function_string = generate_select_bits(membership_function_string);

    assert(numel(membership_function_string) == 38*n + 4);
end


%% ---------- helpers ----------

function bit_list = add_param_bits(bit_list, n)
    % append n random bits for one parameter
    bit_list = [bit_list, randi([0 1], 1, n)];
end

function value = bits_to_int_gray(bit_list, offset, n)
    % gray bits -> integer (MSB first), reads n bits starting at offset (1-based)
    value = 0;
    binary_bit = 0;
    for j = 0:n-1
        binary_bit = xor(binary_bit, bit_list(offset + j));
        value = value + binary_bit * 2^(n - 1 - j);
    end
end

function bit_list = sort_params(bit_list, start, n, num_params, group_size, key_index)
    % sort num_params consecutive params (starting at bit index start, 1-based) smallest -> largest
    % if group size = 1, each param gets a key = its decoded value, params sorted by that
    % if group size = 2+, each group gets a key = decoded value of one param in the group,
    %   key index (0-based) says which param in the group that is
    if nargin < 5, group_size = 1; end
    if nargin < 6, key_index = 0; end
    assert(num_params >= 2 && num_params <= 4);

    size_bits = group_size * n;
    keys   = zeros(1, num_params);
    chunks = zeros(num_params, size_bits);
    for g = 1:num_params
        offset = start + (g-1)*size_bits;
        keys(g)     = bits_to_int_gray(bit_list, offset + key_index*n, n);
        chunks(g,:) = bit_list(offset : offset + size_bits - 1);
    end

    [~, idx] = sort(keys);
    chunks = chunks(idx, :);

    for g = 1:num_params
        offset = start + (g-1)*size_bits;
        bit_list(offset : offset + size_bits - 1) = chunks(g, :);
    end
end


%% ---------- shape generators ----------

function bit_list = generate_diff_of_sigmoids(bit_list, n)
    start = numel(bit_list) + 1;              % bit index where diff of sigmoids begins (1-based)
    bit_list = add_param_bits(bit_list, n);   % a1
    bit_list = add_param_bits(bit_list, n);   % c1
    bit_list = add_param_bits(bit_list, n);   % a2
    bit_list = add_param_bits(bit_list, n);   % c2
    bit_list = sort_params(bit_list, start, n, 2, 2, 1);   % sort (a1 c1)(a2 c2) pairs so c1 <= c2
end

function bit_list = generate_gaussian(bit_list, n)
    bit_list = add_param_bits(bit_list, n);   % sigma
    bit_list = add_param_bits(bit_list, n);   % c
end

function bit_list = generate_generalized_bell(bit_list, n)
    bit_list = add_param_bits(bit_list, n);   % a
    bit_list = add_param_bits(bit_list, n);   % b
    bit_list = add_param_bits(bit_list, n);   % c
end

function bit_list = generate_linear_s_shaped(bit_list, n)
    start = numel(bit_list) + 1;              % bit index where linear s shaped begins (1-based)
    bit_list = add_param_bits(bit_list, n);   % a
    bit_list = add_param_bits(bit_list, n);   % b
    bit_list = sort_params(bit_list, start, n, 2);   % sort a <= b
end

function bit_list = generate_linear_z_shaped(bit_list, n)
    start = numel(bit_list) + 1;              % bit index where linear z shaped begins (1-based)
    bit_list = add_param_bits(bit_list, n);   % a
    bit_list = add_param_bits(bit_list, n);   % b
    bit_list = sort_params(bit_list, start, n, 2);   % sort a <= b
end

function bit_list = generate_pi_shaped(bit_list, n)
    start = numel(bit_list) + 1;              % bit index where pi shaped begins (1-based)
    bit_list = add_param_bits(bit_list, n);   % a
    bit_list = add_param_bits(bit_list, n);   % b
    bit_list = add_param_bits(bit_list, n);   % c
    bit_list = add_param_bits(bit_list, n);   % d
    bit_list = sort_params(bit_list, start, n, 4);   % sort a <= b <= c <= d
end

function bit_list = generate_product_of_sigmoids(bit_list, n)
    start = numel(bit_list) + 1;              % bit index where product of sigmoids begins (1-based)
    bit_list = add_param_bits(bit_list, n);   % a1
    bit_list = add_param_bits(bit_list, n);   % c1
    bit_list = add_param_bits(bit_list, n);   % a2
    bit_list = add_param_bits(bit_list, n);   % c2
    bit_list = sort_params(bit_list, start, n, 2, 2, 1);   % sort (a1 c1)(a2 c2) pairs so c1 <= c2
end

function bit_list = generate_s_shaped(bit_list, n)
    start = numel(bit_list) + 1;              % bit index where s shaped begins (1-based)
    bit_list = add_param_bits(bit_list, n);   % a
    bit_list = add_param_bits(bit_list, n);   % b
    bit_list = sort_params(bit_list, start, n, 2);   % sort a <= b
end

function bit_list = generate_sigmoid(bit_list, n)
    bit_list = add_param_bits(bit_list, n);   % a
    bit_list = add_param_bits(bit_list, n);   % c
end

function bit_list = generate_trapezoidal(bit_list, n)
    start = numel(bit_list) + 1;              % bit index where trapezoidal begins (1-based)
    bit_list = add_param_bits(bit_list, n);   % a
    bit_list = add_param_bits(bit_list, n);   % b
    bit_list = add_param_bits(bit_list, n);   % c
    bit_list = add_param_bits(bit_list, n);   % d
    bit_list = sort_params(bit_list, start, n, 4);   % sort a <= b <= c <= d
end

function bit_list = generate_triangular(bit_list, n)
    start = numel(bit_list) + 1;              % bit index where triangular begins (1-based)
    bit_list = add_param_bits(bit_list, n);   % a
    bit_list = add_param_bits(bit_list, n);   % b
    bit_list = add_param_bits(bit_list, n);   % c
    bit_list = sort_params(bit_list, start, n, 3);   % sort a <= b <= c
end

function bit_list = generate_two_sided_gaussian(bit_list, n)
    start = numel(bit_list) + 1;              % bit index where two sided gaussian begins (1-based)
    bit_list = add_param_bits(bit_list, n);   % sigma1
    bit_list = add_param_bits(bit_list, n);   % c1
    bit_list = add_param_bits(bit_list, n);   % sigma2
    bit_list = add_param_bits(bit_list, n);   % c2
    bit_list = sort_params(bit_list, start, n, 2, 2, 1);   % sort (sigma1 c1)(sigma2 c2) pairs so c1 <= c2
end

function bit_list = generate_z_shaped(bit_list, n)
    start = numel(bit_list) + 1;              % bit index where z shaped begins (1-based)
    bit_list = add_param_bits(bit_list, n);   % a
    bit_list = add_param_bits(bit_list, n);   % b
    bit_list = sort_params(bit_list, start, n, 2);   % sort a <= b
end

function bit_list = generate_select_bits(bit_list)
    select_int  = randi([0 12]);
    select_bits = dec2bin(select_int, 4) - '0';   % plain binary, e.g. '0101' -> [0 1 0 1]
    bit_list = [bit_list, select_bits];
end