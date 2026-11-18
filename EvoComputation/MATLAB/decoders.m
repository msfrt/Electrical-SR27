classdef decoders
% DECODERS  Turn one MF bit row vector into actual parameter values.
%
% Usage:
%   mf = generate_membership_function();
%   a  = decoders.decode_trapezoidal_a(mf);        % one param
%   p  = decoders.decode_trapezoidal(mf);          % [a b c d]
%   d  = decoders.decode_membership_function(mf);  % [select_int, params...]
%   g  = decoders.decode_genome(generate_genome()); % cell array, one decoded MF per cell
%
% Units for decoded parameters are slip ratio, (1/slip ratio), or a shape exponent.
% Param bits are Gray coded, select bits are plain binary.
% No sorting here, ordering is handled by generation / crossover / mutation.
%
% Ranges are loaded once from parameters.m and cached.
% If you change parameters.m, run  clear decoders  to reload them.

    methods (Static)

        %% ---------- decoder helper functions ----------
        % position, width, slope, and shape exponent are diff decoders,
        % but code is clean cuz they all just call decode_range

        % gray bits -> value in [lb, ub]
        function value = decode_range(bits, lb, ub)
            n = numel(bits);
            value = lb + decoders.bits_to_int_gray(bits) * (ub - lb) / (2^n - 1);
        end

        function value = decode_position(bits)
            p = decoders.params();
            value = decoders.decode_range(bits, p.position_lb, p.position_ub);
        end

        function value = decode_width(bits)
            p = decoders.params();
            value = decoders.decode_range(bits, p.width_lb, p.width_ub);
        end

        function value = decode_slope(bits)
            % 10-90% transition width w -> sigmoid slope a = 4.4 / w (positive, sign applied per shape)
            p = decoders.params();
            value = 4.4 / decoders.decode_range(bits, p.slope_lb, p.slope_ub);
        end

        function value = decode_shape_exponent(bits)
            p = decoders.params();
            value = decoders.decode_range(bits, p.shape_exponent_lb, p.shape_exponent_ub);
        end


        %% Difference of Sigmoids [a1 c1 a2 c2] (both slopes positive)
        function value = decode_diff_of_sigmoids_a1(bit_list)
            value = decoders.decode_slope(extractors.extract_diff_of_sigmoids_a1(bit_list));
        end
        function value = decode_diff_of_sigmoids_c1(bit_list)
            value = decoders.decode_position(extractors.extract_diff_of_sigmoids_c1(bit_list));
        end
        function value = decode_diff_of_sigmoids_a2(bit_list)
            value = decoders.decode_slope(extractors.extract_diff_of_sigmoids_a2(bit_list));
        end
        function value = decode_diff_of_sigmoids_c2(bit_list)
            value = decoders.decode_position(extractors.extract_diff_of_sigmoids_c2(bit_list));
        end
        function value = decode_diff_of_sigmoids(bit_list)
            value = [decoders.decode_diff_of_sigmoids_a1(bit_list), decoders.decode_diff_of_sigmoids_c1(bit_list), ...
                     decoders.decode_diff_of_sigmoids_a2(bit_list), decoders.decode_diff_of_sigmoids_c2(bit_list)];
        end

        %% Gaussian [sigma c]
        function value = decode_gaussian_sigma(bit_list)
            value = decoders.decode_width(extractors.extract_gaussian_sigma(bit_list));
        end
        function value = decode_gaussian_center(bit_list)
            value = decoders.decode_position(extractors.extract_gaussian_center(bit_list));
        end
        function value = decode_gaussian(bit_list)
            value = [decoders.decode_gaussian_sigma(bit_list), decoders.decode_gaussian_center(bit_list)];
        end

        %% Generalized Bell [a b c]
        function value = decode_generalized_bell_a(bit_list)
            value = decoders.decode_width(extractors.extract_generalized_bell_a(bit_list));
        end
        function value = decode_generalized_bell_b(bit_list)
            value = decoders.decode_shape_exponent(extractors.extract_generalized_bell_b(bit_list));
        end
        function value = decode_generalized_bell_c(bit_list)
            value = decoders.decode_position(extractors.extract_generalized_bell_c(bit_list));
        end
        function value = decode_generalized_bell(bit_list)
            value = [decoders.decode_generalized_bell_a(bit_list), decoders.decode_generalized_bell_b(bit_list), ...
                     decoders.decode_generalized_bell_c(bit_list)];
        end

        %% Linear S Shaped [a b]
        function value = decode_linear_s_shaped_a(bit_list)
            value = decoders.decode_position(extractors.extract_linear_s_shaped_a(bit_list));
        end
        function value = decode_linear_s_shaped_b(bit_list)
            value = decoders.decode_position(extractors.extract_linear_s_shaped_b(bit_list));
        end
        function value = decode_linear_s_shaped(bit_list)
            value = [decoders.decode_linear_s_shaped_a(bit_list), decoders.decode_linear_s_shaped_b(bit_list)];
        end

        %% Linear Z Shaped [a b]
        function value = decode_linear_z_shaped_a(bit_list)
            value = decoders.decode_position(extractors.extract_linear_z_shaped_a(bit_list));
        end
        function value = decode_linear_z_shaped_b(bit_list)
            value = decoders.decode_position(extractors.extract_linear_z_shaped_b(bit_list));
        end
        function value = decode_linear_z_shaped(bit_list)
            value = [decoders.decode_linear_z_shaped_a(bit_list), decoders.decode_linear_z_shaped_b(bit_list)];
        end

        %% Pi Shaped [a b c d]
        function value = decode_pi_shaped_a(bit_list)
            value = decoders.decode_position(extractors.extract_pi_shaped_a(bit_list));
        end
        function value = decode_pi_shaped_b(bit_list)
            value = decoders.decode_position(extractors.extract_pi_shaped_b(bit_list));
        end
        function value = decode_pi_shaped_c(bit_list)
            value = decoders.decode_position(extractors.extract_pi_shaped_c(bit_list));
        end
        function value = decode_pi_shaped_d(bit_list)
            value = decoders.decode_position(extractors.extract_pi_shaped_d(bit_list));
        end
        function value = decode_pi_shaped(bit_list)
            value = [decoders.decode_pi_shaped_a(bit_list), decoders.decode_pi_shaped_b(bit_list), ...
                     decoders.decode_pi_shaped_c(bit_list), decoders.decode_pi_shaped_d(bit_list)];
        end

        %% Product of Sigmoids [a1 c1 a2 c2] (a1 positive, a2 negative)
        function value = decode_product_of_sigmoids_a1(bit_list)
            value = decoders.decode_slope(extractors.extract_product_of_sigmoids_a1(bit_list));
        end
        function value = decode_product_of_sigmoids_c1(bit_list)
            value = decoders.decode_position(extractors.extract_product_of_sigmoids_c1(bit_list));
        end
        function value = decode_product_of_sigmoids_a2(bit_list)
            value = -decoders.decode_slope(extractors.extract_product_of_sigmoids_a2(bit_list));
        end
        function value = decode_product_of_sigmoids_c2(bit_list)
            value = decoders.decode_position(extractors.extract_product_of_sigmoids_c2(bit_list));
        end
        function value = decode_product_of_sigmoids(bit_list)
            value = [decoders.decode_product_of_sigmoids_a1(bit_list), decoders.decode_product_of_sigmoids_c1(bit_list), ...
                     decoders.decode_product_of_sigmoids_a2(bit_list), decoders.decode_product_of_sigmoids_c2(bit_list)];
        end

        %% S Shaped [a b]
        function value = decode_s_shaped_a(bit_list)
            value = decoders.decode_position(extractors.extract_s_shaped_a(bit_list));
        end
        function value = decode_s_shaped_b(bit_list)
            value = decoders.decode_position(extractors.extract_s_shaped_b(bit_list));
        end
        function value = decode_s_shaped(bit_list)
            value = [decoders.decode_s_shaped_a(bit_list), decoders.decode_s_shaped_b(bit_list)];
        end

        %% Sigmoid [a c] (positive slope, opens right)
        function value = decode_sigmoid_a(bit_list)
            value = decoders.decode_slope(extractors.extract_sigmoid_a(bit_list));
        end
        function value = decode_sigmoid_c(bit_list)
            value = decoders.decode_position(extractors.extract_sigmoid_c(bit_list));
        end
        function value = decode_sigmoid(bit_list)
            value = [decoders.decode_sigmoid_a(bit_list), decoders.decode_sigmoid_c(bit_list)];
        end

        %% Trapezoidal [a b c d]
        function value = decode_trapezoidal_a(bit_list)
            value = decoders.decode_position(extractors.extract_trapezoidal_a(bit_list));
        end
        function value = decode_trapezoidal_b(bit_list)
            value = decoders.decode_position(extractors.extract_trapezoidal_b(bit_list));
        end
        function value = decode_trapezoidal_c(bit_list)
            value = decoders.decode_position(extractors.extract_trapezoidal_c(bit_list));
        end
        function value = decode_trapezoidal_d(bit_list)
            value = decoders.decode_position(extractors.extract_trapezoidal_d(bit_list));
        end
        function value = decode_trapezoidal(bit_list)
            value = [decoders.decode_trapezoidal_a(bit_list), decoders.decode_trapezoidal_b(bit_list), ...
                     decoders.decode_trapezoidal_c(bit_list), decoders.decode_trapezoidal_d(bit_list)];
        end

        %% Triangular [a b c]
        function value = decode_triangular_a(bit_list)
            value = decoders.decode_position(extractors.extract_triangular_a(bit_list));
        end
        function value = decode_triangular_b(bit_list)
            value = decoders.decode_position(extractors.extract_triangular_b(bit_list));
        end
        function value = decode_triangular_c(bit_list)
            value = decoders.decode_position(extractors.extract_triangular_c(bit_list));
        end
        function value = decode_triangular(bit_list)
            value = [decoders.decode_triangular_a(bit_list), decoders.decode_triangular_b(bit_list), ...
                     decoders.decode_triangular_c(bit_list)];
        end

        %% Two Sided Gaussian [sigma1 c1 sigma2 c2]
        function value = decode_two_sided_gaussian_sigma1(bit_list)
            value = decoders.decode_width(extractors.extract_two_sided_gaussian_sigma1(bit_list));
        end
        function value = decode_two_sided_gaussian_c1(bit_list)
            value = decoders.decode_position(extractors.extract_two_sided_gaussian_c1(bit_list));
        end
        function value = decode_two_sided_gaussian_sigma2(bit_list)
            value = decoders.decode_width(extractors.extract_two_sided_gaussian_sigma2(bit_list));
        end
        function value = decode_two_sided_gaussian_c2(bit_list)
            value = decoders.decode_position(extractors.extract_two_sided_gaussian_c2(bit_list));
        end
        function value = decode_two_sided_gaussian(bit_list)
            value = [decoders.decode_two_sided_gaussian_sigma1(bit_list), decoders.decode_two_sided_gaussian_c1(bit_list), ...
                     decoders.decode_two_sided_gaussian_sigma2(bit_list), decoders.decode_two_sided_gaussian_c2(bit_list)];
        end

        %% Z Shaped [a b]
        function value = decode_z_shaped_a(bit_list)
            value = decoders.decode_position(extractors.extract_z_shaped_a(bit_list));
        end
        function value = decode_z_shaped_b(bit_list)
            value = decoders.decode_position(extractors.extract_z_shaped_b(bit_list));
        end
        function value = decode_z_shaped(bit_list)
            value = [decoders.decode_z_shaped_a(bit_list), decoders.decode_z_shaped_b(bit_list)];
        end

        %% Select Bits (4 plain binary bits after Z Shaped, 0-12 valid, 13-15 invalid)
        function value = decode_select_bits(bit_list)
            value = decoders.bits_to_int(extractors.extract_select_bits(bit_list));
        end


        %% ---------- whole MF / genome ----------

        % decode one MF: returns [select_int, params...] (params in MATLAB order)
        function value = decode_membership_function(membership_function)
            mf = membership_function;
            select_int = decoders.decode_select_bits(mf);
            switch select_int
                case 0,  value = [select_int, decoders.decode_diff_of_sigmoids(mf)];
                case 1,  value = [select_int, decoders.decode_gaussian(mf)];
                case 2,  value = [select_int, decoders.decode_generalized_bell(mf)];
                case 3,  value = [select_int, decoders.decode_linear_s_shaped(mf)];
                case 4,  value = [select_int, decoders.decode_linear_z_shaped(mf)];
                case 5,  value = [select_int, decoders.decode_pi_shaped(mf)];
                case 6,  value = [select_int, decoders.decode_product_of_sigmoids(mf)];
                case 7,  value = [select_int, decoders.decode_s_shaped(mf)];
                case 8,  value = [select_int, decoders.decode_sigmoid(mf)];
                case 9,  value = [select_int, decoders.decode_trapezoidal(mf)];
                case 10, value = [select_int, decoders.decode_triangular(mf)];
                case 11, value = [select_int, decoders.decode_two_sided_gaussian(mf)];
                case 12, value = [select_int, decoders.decode_z_shaped(mf)];
            end
        end

        % decode a whole genome (matrix, one MF per row) -> cell array, one decoded MF per cell
        % (cell array because shapes have different numbers of params)
        function decoded_genome = decode_genome(genome)
            decoded_genome = cell(1, size(genome, 1));
            for i = 1:size(genome, 1)
                decoded_genome{i} = decoders.decode_membership_function(genome(i, :));
            end
        end

    end

    methods (Static, Access = private)

        % gray bits -> integer (MSB first), reads all bits given
        function value = bits_to_int_gray(bits)
            n = numel(bits);
            value = 0;
            binary_bit = 0;
            for j = 1:n
                binary_bit = xor(binary_bit, bits(j));
                value = value + binary_bit * 2^(n - j);
            end
        end

        % binary bits -> integer (MSB first), reads all bits given (used for select bits)
        function value = bits_to_int(bits)
            n = numel(bits);
            value = 0;
            for j = 1:n
                value = value + bits(j) * 2^(n - j);
            end
        end

        % decode ranges from parameters.m, loaded once
        function p = params()
            persistent cached
            if isempty(cached)
                parameters;
                cached.position_lb = position_lb;
                cached.position_ub = position_ub;
                cached.width_lb = width_lb;
                cached.width_ub = width_ub;
                cached.slope_lb = slope_lb;
                cached.slope_ub = slope_ub;
                cached.shape_exponent_lb = shape_exponent_lb;
                cached.shape_exponent_ub = shape_exponent_ub;
            end
            p = cached;
        end

    end
end