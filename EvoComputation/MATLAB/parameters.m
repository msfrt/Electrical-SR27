% Current Prototype Limited to Generating Slip Ratio MF's (Derivative Not Implemented Yet)
membership_function_amount = 3;

% Slip Ratio Constants
slip_ratio_min = -0.25; % accelerating only so this should be pos but ill still account for full range
slip_ratio_max = 0.25;
slip_ratio_optimal = 0.12;
slip_ratio_derivative_min = []; % calc from logs, check validity of calc with matt
slip_ratio_derivative_max = [];

% Inputs
slip_ratio_input = [];
slip_ratio_derivative_input = [];

% GA Encoding Constants
precision = 0.00196; % Need to figure out precision so will look at papers for that later
ub = slip_ratio_max;
lb = slip_ratio_min;
precision_bits = round(log2((ub - lb) / precision + 1));