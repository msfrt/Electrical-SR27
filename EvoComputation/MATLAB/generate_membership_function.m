function membership_function_string = generate_membership_function()
% GENERATE_MEMBERSHIP_FUNCTION  Build one random MF slot as a bit row vector.
%
% Layout (param index k, 0-based, each param is precision_bits long):
%   Difference of Sigmoids (a1 c1 a2 c2)          k = 0-3
%   Gaussian (sigma c)                            k = 4-5
%   Generalized Bell (a b c)                      k = 6-8
%   Linear S Shaped (a b)                         k = 9-10
%   Linear Z Shaped (a b)                         k = 11-12
%   Pi Shaped (a b c d)                           k = 13-16
%   Product of Sigmoids (a1 c1 a2 c2)             k = 17-20
%   S Shaped (a b)                                k = 21-22
%   Sigmoid (a c)                                 k = 23-24
%   Trapezoidal (a b c d)                         k = 25-28  (sorted a<=b<=c<=d)
%   Triangular (a b c)                            k = 29-31  (sorted a<=b<=c)
%   Two Sided Gaussian (sigma1 c1 sigma2 c2)      k = 32-35
%   Z Shaped (a b)                                k = 36-37
%   Select bits (4 bits, picks 1 of 13 shapes)    after k = 37
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

function value = bits_to_int(bit_list, offset, n)
    % decode n bits starting at offset (1-based), MSB first
    value = 0;
    for j = 0:n-1
        value = value + bit_list(offset + j) * 2^(n - 1 - j);
    end
end

function bit_list = sort_params(bit_list, start, n, num_params)
    % sort num_params consecutive params (starting at bit index start) by
    % decoded value, smallest first, and write the sorted bits back
    ints   = zeros(1, num_params);
    chunks = zeros(num_params, n);
    for p = 1:num_params
        offset = start + (p-1)*n;
        ints(p)     = bits_to_int(bit_list, offset, n);
        chunks(p,:) = bit_list(offset : offset + n - 1);
    end

    [~, idx] = sort(ints);
    chunks = chunks(idx, :);

    for p = 1:num_params
        offset = start + (p-1)*n;
        bit_list(offset : offset + n - 1) = chunks(p, :);
    end
end


%% ---------- shape generators ----------

function bit_list = generate_diff_of_sigmoids(bit_list, n)
    bit_list = add_param_bits(bit_list, n);   % a1
    bit_list = add_param_bits(bit_list, n);   % c1
    bit_list = add_param_bits(bit_list, n);   % a2
    bit_list = add_param_bits(bit_list, n);   % c2
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
    bit_list = add_param_bits(bit_list, n);   % a
    bit_list = add_param_bits(bit_list, n);   % b
end

function bit_list = generate_linear_z_shaped(bit_list, n)
    bit_list = add_param_bits(bit_list, n);   % a
    bit_list = add_param_bits(bit_list, n);   % b
end

function bit_list = generate_pi_shaped(bit_list, n)
    bit_list = add_param_bits(bit_list, n);   % a
    bit_list = add_param_bits(bit_list, n);   % b
    bit_list = add_param_bits(bit_list, n);   % c
    bit_list = add_param_bits(bit_list, n);   % d
end

function bit_list = generate_product_of_sigmoids(bit_list, n)
    bit_list = add_param_bits(bit_list, n);   % a1
    bit_list = add_param_bits(bit_list, n);   % c1
    bit_list = add_param_bits(bit_list, n);   % a2
    bit_list = add_param_bits(bit_list, n);   % c2
end

function bit_list = generate_s_shaped(bit_list, n)
    bit_list = add_param_bits(bit_list, n);   % a
    bit_list = add_param_bits(bit_list, n);   % b
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
    bit_list = sort_params(bit_list, start, n, 4);   % enforce a <= b <= c <= d
end

function bit_list = generate_triangular(bit_list, n)
    start = numel(bit_list) + 1;              % bit index where triangular begins (1-based)
    bit_list = add_param_bits(bit_list, n);   % a
    bit_list = add_param_bits(bit_list, n);   % b
    bit_list = add_param_bits(bit_list, n);   % c
    bit_list = sort_params(bit_list, start, n, 3);   % enforce a <= b <= c
end

function bit_list = generate_two_sided_gaussian(bit_list, n)
    bit_list = add_param_bits(bit_list, n);   % sigma1
    bit_list = add_param_bits(bit_list, n);   % c1
    bit_list = add_param_bits(bit_list, n);   % sigma2
    bit_list = add_param_bits(bit_list, n);   % c2
end

function bit_list = generate_z_shaped(bit_list, n)
    bit_list = add_param_bits(bit_list, n);   % a
    bit_list = add_param_bits(bit_list, n);   % b
end

function bit_list = generate_select_bits(bit_list)
    select_int  = randi([0 12]);
    select_bits = dec2bin(select_int, 4) - '0';   % e.g. '0101' -> [0 1 0 1]
    bit_list = [bit_list, select_bits];
end