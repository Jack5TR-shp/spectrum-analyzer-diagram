%% ============================================================
%%  FIGURE 2: WINDOW FUNCTIONS COMPARISON (FINAL VERSION)
%%  IEEE Paper Ready - Best Layout
%% ============================================================

clear; clc; close all;

N = 1024;
export_dpi = 300;
fig_folder = 'figures';
if ~exist(fig_folder, 'dir'), mkdir(fig_folder); end

n = 0:N-1;

w_rect     = ones(1, N);
w_hann     = 0.5 * (1 - cos(2*pi*n/(N-1)));
w_hamming  = 0.54 - 0.46*cos(2*pi*n/(N-1));
w_blackman = 0.42 - 0.5*cos(2*pi*n/(N-1)) + 0.08*cos(4*pi*n/(N-1));

fig2 = figure('Color', 'w', 'Name', 'Fig2_WindowFunctions_Final', ...
              'Position', [100 70 1050 620]);

plot(n/N, w_rect,   'k-',  'LineWidth', 1.8); hold on;
plot(n/N, w_hann,   'b-',  'LineWidth', 2.2);
plot(n/N, w_hamming, 'r--', 'LineWidth', 1.9);
plot(n/N, w_blackman,'g-.', 'LineWidth', 1.9);

xlabel('Normalized Time Index (n/N)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Amplitude', 'FontSize', 12, 'FontWeight', 'bold');
title('Comparison of Window Functions for FFT-Based Spectrum Analysis', ...
      'FontSize', 13.5, 'FontWeight', 'bold');

legend('Rectangular (No Window)', 'Hann (Recommended)', ...
       'Hamming', 'Blackman', 'Location', 'eastoutside', 'FontSize', 10);

grid on;
set(gca, 'GridLineStyle', ':', 'GridAlpha', 0.4);
ylim([0 1.08]);
xlim([0 1]);

% ==================== ANNOTATION BOX - TOP RIGHT ====================
annotation('textbox', [0.58 0.68 0.36 0.24], ...
    'String', {'Window functions reduce spectral leakage', ...
               'before FFT computation.', ...
               '', ...
               'Hann window offers good trade-off between', ...
               'mainlobe width and sidelobe attenuation.', ...
               '', ...
               'FPGA: Coefficients stored in ROM/BRAM', ...
               'and applied using DSP slices.'}, ...
    'FitBoxToText', 'on', ...
    'BackgroundColor', [0.95 0.95 1], ...
    'EdgeColor', [0 0.25 0.5], ...
    'LineWidth', 1.3, ...
    'FontSize', 9.5);

text(0.5, 0.04, ...
    'FPGA Implementation: Window coefficients are pre-computed and stored in on-chip memory', ...
    'Units', 'normalized', 'HorizontalAlignment', 'center', ...
    'FontSize', 9.5, 'Color', [0 0.35 0], 'FontAngle', 'italic');

exportgraphics(fig2, fullfile(fig_folder, 'Fig2_WindowFunctions_Final.png'), 'Resolution', export_dpi);
exportgraphics(fig2, fullfile(fig_folder, 'Fig2_WindowFunctions_Final.pdf'), 'ContentType', 'vector');

fprintf('✅ Final Figure 2 generated successfully!\n');