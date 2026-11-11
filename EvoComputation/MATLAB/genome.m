classdef genome
% GENOME  Generate and decode genomes.
%
% Our Genomes are just a list of membership functions.
%
% Usage:
%   g  = genome.generate_genome();   % matrix, one MF per row
%   dg = genome.decode_genome(g);    % cell array, one decoded MF per cell
%
% Don't name a variable "genome" (e.g. genome = genome.generate_genome()),
% it hides this class for the rest of the script.

    methods (Static)

        % Generate Genome
        % returns a matrix with one row per MF:
        %   size = [membership_function_amount, 38*precision_bits + 4]
        function g = generate_genome()
            parameters;   % loads membership_function_amount, precision_bits, etc.

            mf_length = 38*precision_bits + 4;
            g = zeros(membership_function_amount, mf_length);

            for i = 1:membership_function_amount
                g(i, :) = generate_membership_function();
            end
        end

        % Decode Genome
        % returns a cell array, one decoded MF ([select_int, params...]) per cell
        % (cell array because shapes have different numbers of params)
        function decoded_genome = decode_genome(g)
            decoded_genome = cell(1, size(g, 1));
            for i = 1:size(g, 1)
                decoded_genome{i} = decode_membership_function(g(i, :));
            end
        end

    end
end