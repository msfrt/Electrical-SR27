function decoded_mf = decode_membership_function(membership_function)
% DECODE_MEMBERSHIP_FUNCTION  Decode one MF bit row vector.
%
% Returns [select_int, params...] with params in MATLAB order,
% or [] if the select code is invalid (13-15).
%
% Uses the decoders class (decoders.m) for every param.

mf = membership_function;
select_int = decoders.decode_select_bits(mf);

switch select_int
    case 0   % Difference of Sigmoids
        decoded_mf = [select_int, decoders.decode_diff_of_sigmoids_a1(mf), decoders.decode_diff_of_sigmoids_c1(mf), ...
            decoders.decode_diff_of_sigmoids_a2(mf), decoders.decode_diff_of_sigmoids_c2(mf)];
    case 1   % Gaussian
        decoded_mf = [select_int, decoders.decode_gaussian_sigma(mf), decoders.decode_gaussian_center(mf)];
    case 2   % Generalized Bell
        decoded_mf = [select_int, decoders.decode_generalized_bell_a(mf), decoders.decode_generalized_bell_b(mf), ...
            decoders.decode_generalized_bell_c(mf)];
    case 3   % Linear S Shaped
        decoded_mf = [select_int, decoders.decode_linear_s_shaped_a(mf), decoders.decode_linear_s_shaped_b(mf)];
    case 4   % Linear Z Shaped
        decoded_mf = [select_int, decoders.decode_linear_z_shaped_a(mf), decoders.decode_linear_z_shaped_b(mf)];
    case 5   % Pi Shaped
        decoded_mf = [select_int, decoders.decode_pi_shaped_a(mf), decoders.decode_pi_shaped_b(mf), ...
            decoders.decode_pi_shaped_c(mf), decoders.decode_pi_shaped_d(mf)];
    case 6   % Product of Sigmoids
        decoded_mf = [select_int, decoders.decode_product_of_sigmoids_a1(mf), decoders.decode_product_of_sigmoids_c1(mf), ...
            decoders.decode_product_of_sigmoids_a2(mf), decoders.decode_product_of_sigmoids_c2(mf)];
    case 7   % S Shaped
        decoded_mf = [select_int, decoders.decode_s_shaped_a(mf), decoders.decode_s_shaped_b(mf)];
    case 8   % Sigmoid
        decoded_mf = [select_int, decoders.decode_sigmoid_a(mf), decoders.decode_sigmoid_c(mf)];
    case 9   % Trapezoidal
        decoded_mf = [select_int, decoders.decode_trapezoidal_a(mf), decoders.decode_trapezoidal_b(mf), ...
            decoders.decode_trapezoidal_c(mf), decoders.decode_trapezoidal_d(mf)];
    case 10  % Triangular
        decoded_mf = [select_int, decoders.decode_triangular_a(mf), decoders.decode_triangular_b(mf), ...
            decoders.decode_triangular_c(mf)];
    case 11  % Two Sided Gaussian
        decoded_mf = [select_int, decoders.decode_two_sided_gaussian_sigma1(mf), decoders.decode_two_sided_gaussian_c1(mf), ...
            decoders.decode_two_sided_gaussian_sigma2(mf), decoders.decode_two_sided_gaussian_c2(mf)];
    case 12  % Z Shaped
        decoded_mf = [select_int, decoders.decode_z_shaped_a(mf), decoders.decode_z_shaped_b(mf)];
    otherwise   % 13-15, invalid select code
        decoded_mf = [];
end
end