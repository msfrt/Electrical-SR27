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

% slip ratio units
position_lb = slip_ratio_min;
position_ub = slip_ratio_max;

% also slip ratio units but want different
width_lb = 0.005; % need to fine tune more
width_ub = 0.15;  % need to fine tune more

% slope, encoded as 10-90% transition width w (slip ratio units), then a = 4.4 / w (1/slip ratio units)
slope_lb = 0.005; % need to fine tune more
slope_ub = 0.15;  % need to fine tune more

% shape exponent (unitless)
shape_exponent_lb = 1;  % need to fine tune more
shape_exponent_ub = 10; % need to fine tune more

% Adding extra precision bits adds more LSBs and so more bits does not mean that we incease the chance of affecting a population member by a lot
% This matters because this precision bits code is a one size fits all sort of thing
% If anything more precision means higher chance mutation isnt occuring on a MSB preserving population members
precision_bits = round(log2((position_ub - position_lb) / precision + 1));