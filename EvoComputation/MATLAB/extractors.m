classdef extractors
% EXTRACTORS  Pull bit blocks / single params out of one MF bit row vector.
%
% Usage:
%   mf = generate_membership_function();
%   a  = extractors.extract_trapezoidal_a(mf);
%   tr = extractors.extract_trapezoidal(mf);
%
% Param index k is 0-based (same layout as generate_membership_function.m);
% param k lives at bits k*n+1 : (k+1)*n in MATLAB's 1-based indexing.
%
% precision_bits is loaded once from parameters.m and cached.
% If you change parameters.m, run  clear extractors  to reload it.

    methods (Static)

        % Difference of Sigmoids
        function out = extract_diff_of_sigmoids(bit_list)
            out = extractors.block(bit_list, 0, 3);
        end
        function out = extract_diff_of_sigmoids_a1(bit_list)
            out = extractors.param(bit_list, 0);
        end
        function out = extract_diff_of_sigmoids_c1(bit_list)
            out = extractors.param(bit_list, 1);
        end
        function out = extract_diff_of_sigmoids_a2(bit_list)
            out = extractors.param(bit_list, 2);
        end
        function out = extract_diff_of_sigmoids_c2(bit_list)
            out = extractors.param(bit_list, 3);
        end

        % Gaussian
        function out = extract_gaussian(bit_list)
            out = extractors.block(bit_list, 4, 5);
        end
        function out = extract_gaussian_sigma(bit_list)
            out = extractors.param(bit_list, 4);
        end
        function out = extract_gaussian_center(bit_list)
            out = extractors.param(bit_list, 5);
        end

        % Generalized Bell
        function out = extract_generalized_bell(bit_list)
            out = extractors.block(bit_list, 6, 8);
        end
        function out = extract_generalized_bell_a(bit_list)
            out = extractors.param(bit_list, 6);
        end
        function out = extract_generalized_bell_b(bit_list)
            out = extractors.param(bit_list, 7);
        end
        function out = extract_generalized_bell_c(bit_list)
            out = extractors.param(bit_list, 8);
        end

        % Linear S Shaped
        function out = extract_linear_s_shaped(bit_list)
            out = extractors.block(bit_list, 9, 10);
        end
        function out = extract_linear_s_shaped_a(bit_list)
            out = extractors.param(bit_list, 9);
        end
        function out = extract_linear_s_shaped_b(bit_list)
            out = extractors.param(bit_list, 10);
        end

        % Linear Z Shaped
        function out = extract_linear_z_shaped(bit_list)
            out = extractors.block(bit_list, 11, 12);
        end
        function out = extract_linear_z_shaped_a(bit_list)
            out = extractors.param(bit_list, 11);
        end
        function out = extract_linear_z_shaped_b(bit_list)
            out = extractors.param(bit_list, 12);
        end

        % Pi Shaped
        function out = extract_pi_shaped(bit_list)
            out = extractors.block(bit_list, 13, 16);
        end
        function out = extract_pi_shaped_a(bit_list)
            out = extractors.param(bit_list, 13);
        end
        function out = extract_pi_shaped_b(bit_list)
            out = extractors.param(bit_list, 14);
        end
        function out = extract_pi_shaped_c(bit_list)
            out = extractors.param(bit_list, 15);
        end
        function out = extract_pi_shaped_d(bit_list)
            out = extractors.param(bit_list, 16);
        end

        % Product of Sigmoids
        function out = extract_product_of_sigmoids(bit_list)
            out = extractors.block(bit_list, 17, 20);
        end
        function out = extract_product_of_sigmoids_a1(bit_list)
            out = extractors.param(bit_list, 17);
        end
        function out = extract_product_of_sigmoids_c1(bit_list)
            out = extractors.param(bit_list, 18);
        end
        function out = extract_product_of_sigmoids_a2(bit_list)
            out = extractors.param(bit_list, 19);
        end
        function out = extract_product_of_sigmoids_c2(bit_list)
            out = extractors.param(bit_list, 20);
        end

        % S Shaped
        function out = extract_s_shaped(bit_list)
            out = extractors.block(bit_list, 21, 22);
        end
        function out = extract_s_shaped_a(bit_list)
            out = extractors.param(bit_list, 21);
        end
        function out = extract_s_shaped_b(bit_list)
            out = extractors.param(bit_list, 22);
        end

        % Sigmoid
        function out = extract_sigmoid(bit_list)
            out = extractors.block(bit_list, 23, 24);
        end
        function out = extract_sigmoid_a(bit_list)
            out = extractors.param(bit_list, 23);
        end
        function out = extract_sigmoid_c(bit_list)
            out = extractors.param(bit_list, 24);
        end

        % Trapezoidal
        function out = extract_trapezoidal(bit_list)
            out = extractors.block(bit_list, 25, 28);
        end
        function out = extract_trapezoidal_a(bit_list)
            out = extractors.param(bit_list, 25);
        end
        function out = extract_trapezoidal_b(bit_list)
            out = extractors.param(bit_list, 26);
        end
        function out = extract_trapezoidal_c(bit_list)
            out = extractors.param(bit_list, 27);
        end
        function out = extract_trapezoidal_d(bit_list)
            out = extractors.param(bit_list, 28);
        end

        % Triangular
        function out = extract_triangular(bit_list)
            out = extractors.block(bit_list, 29, 31);
        end
        function out = extract_triangular_a(bit_list)
            out = extractors.param(bit_list, 29);
        end
        function out = extract_triangular_b(bit_list)
            out = extractors.param(bit_list, 30);
        end
        function out = extract_triangular_c(bit_list)
            out = extractors.param(bit_list, 31);
        end

        % Two Sided Gaussian
        function out = extract_two_sided_gaussian(bit_list)
            out = extractors.block(bit_list, 32, 35);
        end
        function out = extract_two_sided_gaussian_sigma1(bit_list)
            out = extractors.param(bit_list, 32);
        end
        function out = extract_two_sided_gaussian_c1(bit_list)
            out = extractors.param(bit_list, 33);
        end
        function out = extract_two_sided_gaussian_sigma2(bit_list)
            out = extractors.param(bit_list, 34);
        end
        function out = extract_two_sided_gaussian_c2(bit_list)
            out = extractors.param(bit_list, 35);
        end

        % Z Shaped
        function out = extract_z_shaped(bit_list)
            out = extractors.block(bit_list, 36, 37);
        end
        function out = extract_z_shaped_a(bit_list)
            out = extractors.param(bit_list, 36);
        end
        function out = extract_z_shaped_b(bit_list)
            out = extractors.param(bit_list, 37);
        end

        % Select Bits (4 bits after Z Shaped)
        function out = extract_select_bits(bit_list)
            n = extractors.nbits();
            out = bit_list(38*n + 1 : 38*n + 4);
        end

    end

    methods (Static, Access = private)

        % helper: one param, 0-based k (same as Python _param)
        function out = param(bit_list, k)
            n = extractors.nbits();
            out = bit_list(k*n + 1 : (k+1)*n);
        end

        % helper: whole block from param k_first through k_last (0-based, inclusive)
        function out = block(bit_list, k_first, k_last)
            n = extractors.nbits();
            out = bit_list(k_first*n + 1 : (k_last+1)*n);
        end

        % helper: precision_bits from parameters.m, loaded once
        function n = nbits()
            persistent cached_n
            if isempty(cached_n)
                parameters;
                cached_n = precision_bits;
            end
            n = cached_n;
        end

    end
end