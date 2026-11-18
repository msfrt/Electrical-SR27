function plot_genome(decoded_genome)
% PLOT_GENOME  Plot every MF in a decoded genome on one slip ratio axis.
%
% decoded_genome is the cell array from genome.decode_genome:
%   decoded_genome{i} = [select_int, params...]
%
% Usage:
%   g = genome.generate_genome();
%   plot_genome(genome.decode_genome(g));
%
% Uses the Fuzzy Logic Toolbox MF functions (linsmf / linzmf need R2022a or newer).

parameters;   % loads position_lb, position_ub, etc.
x = linspace(position_lb, position_ub, 1000);

figure;
hold on;

for i = 1:numel(decoded_genome)
    decoded_mf = decoded_genome{i};
    select_int = decoded_mf(1);       % which MF shape
    params = decoded_mf(2:end);       % that shape's parameters
    mf_num = sprintf('MF %d', i);

    switch select_int
        case 0   % Difference of Sigmoids
            plot(x, dsigmf(x, params), 'DisplayName', [mf_num ' (Difference of Sigmoids)']);
        case 1   % Gaussian
            plot(x, gaussmf(x, params), 'DisplayName', [mf_num ' (Gaussian)']);
        case 2   % Generalized Bell
            plot(x, gbellmf(x, params), 'DisplayName', [mf_num ' (Generalized Bell)']);
        case 3   % Linear S Shaped
            plot(x, linsmf(x, params), 'DisplayName', [mf_num ' (Linear S Shaped)']);
        case 4   % Linear Z Shaped
            plot(x, linzmf(x, params), 'DisplayName', [mf_num ' (Linear Z Shaped)']);
        case 5   % Pi Shaped
            plot(x, pimf(x, params), 'DisplayName', [mf_num ' (Pi Shaped)']);
        case 6   % Product of Sigmoids
            plot(x, psigmf(x, params), 'DisplayName', [mf_num ' (Product of Sigmoids)']);
        case 7   % S Shaped
            plot(x, smf(x, params), 'DisplayName', [mf_num ' (S Shaped)']);
        case 8   % Sigmoid
            plot(x, sigmf(x, params), 'DisplayName', [mf_num ' (Sigmoid)']);
        case 9   % Trapezoidal
            plot(x, trapmf(x, params), 'DisplayName', [mf_num ' (Trapezoidal)']);
        case 10  % Triangular
            plot(x, trimf(x, params), 'DisplayName', [mf_num ' (Triangular)']);
        case 11  % Two Sided Gaussian
            plot(x, gauss2mf(x, params), 'DisplayName', [mf_num ' (Two Sided Gaussian)']);
        case 12  % Z Shaped
            plot(x, zmf(x, params), 'DisplayName', [mf_num ' (Z Shaped)']);
    end
end

xlabel('Slip Ratio');
ylabel('Degree of Membership');
legend('show');
hold off;
end