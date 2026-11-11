function genome = generate_genome()
% GENERATE_GENOME  Our Genomes are just a list of membership functions.
%
% Returns a matrix with one row per MF:
%   size(genome) = [membership_function_amount, 38*precision_bits + 4]
%   genome(i, :) is MF #i (pass it straight to the extractors)

parameters;   % loads membership_function_amount, precision_bits, etc.

mf_length = 38*precision_bits + 4;
genome = zeros(membership_function_amount, mf_length);

for i = 1:membership_function_amount
    genome(i, :) = generate_membership_function();
end
end