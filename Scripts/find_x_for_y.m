function x_vals = find_x_for_y(coeff, y_val)
    % Given a 6th order polynomial with coefficients 'coeff' and a y-value 'y_val',
    % this function returns the corresponding x-values.

    % Input:
    % coeff: A 1x7 vector containing the coefficients of the polynomial in descending order (from x^6 to x^0 term).
    % y_val: A scalar specifying the y-value.

    % Output:
    % x_vals: A vector containing the x-values corresponding to the given y-value.

    % Example usage:
    % coeff = [1, -2, 3, -1, 2, -3, 1];
    % y_val = 5;
    % x = find_x_for_y(coeff, y_val)

    if length(coeff) ~= 7
        error('The coefficient vector should have 7 elements for a 6th order polynomial.');
    end

    % Define the polynomial based on given coefficients
    p = poly2sym(coeff);
    
    % Create the equation p(x) - y_val = 0
    eqn = p - y_val;

    % Solve the equation to find x values
    x_vals = double(solve(eqn));
end