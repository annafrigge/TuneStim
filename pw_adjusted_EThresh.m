function y_estimate = pw_adjusted_EThresh(x_estimate)
% Pulse width-adjusted electric field norm thresholds based on Åström 2015
% x_estimate = Pulse width of DBS pulse
% y_estimate = Efield threshold value for activated tissue (VTA)

%% Estimating VTA thresholds according to values from Åstrom 2015 at 3.5um
x = [30,60,90,120];
y = [300,185,142,121];
% Define the exponential function to fit (a*exp(-bx))
model = @(params, x) params(1) * exp(-params(2) * x);

% Initial guess for the parameters (a and b)
initialGuess = [1, 0.01];

% Define the x values where you want to estimate y
%x_estimate = 60;

% Fit the exponential function to the data
params_fit = lsqcurvefit(model, initialGuess, x, y);

% Use the fitted parameters to estimate y at x = 50
y_estimate = model(params_fit, x_estimate);

% Display the estimated value at x = 30
%fprintf('Estimated y at x = %.1f us: %.2f\n', x_estimate,y_estimate);

end