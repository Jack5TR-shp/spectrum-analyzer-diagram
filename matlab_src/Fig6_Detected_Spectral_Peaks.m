%% ============================================================
%%  FIGURE 6: DETECTED SPECTRAL PEAKS
%%  IEEE Paper Ready - Professional Version
%% ============================================================

clear; clc; close all;

%% ==================== PARAMETERS ====================
fs = 48000;
N = 1024;

frequencies = [1000, 4500, 12000, 18500];
amplitudes  = [0.85, 0.65, 0.45, 0.25];
phases      = [0, pi/4, pi/3, pi/6];

peak_thresh_db = -45;
min_peak_dist_bins = 8;
add_noise = true;
noise_level = 0.02;

export_dpi = 300;
fig_folder = 'figures';
if ~exist(fig_folder, 'dir'), mkdir(fig_folder); end

%% ==================== SIGNAL + PEAK DETECTION ====================
t = (0:N-1) / fs;
x = zeros(1, N);
for i = 1:length(frequencies)
    x = x + amplitudes(i) * sin(2*pi*frequencies(i)*t + phases(i));
end
if add_noise
    x = x + noise_level * randn(1, N);
end
x = x / max(abs(x)) * 0.95;

q_levels = 2^11;
x_quant = round(x * q_levels) / q_levels;

w = 0.5 * (1 - cos(2*pi*(0:N-1)/(N-1)));
x_windowed = x_quant .* w;

X = fft(x_windowed, N);
X_single = X(1:floor(N/2)+1);
f_axis = (0:floor(N/2)) * (fs / N);
X_db = 20 * log10(abs(X_single) / max(abs(X_single)) + eps);

% Peak Detection
peak_indices = [];
for i = 2:length(X_db)-1
    if (X_db(i) > X_db(i-1)) && (X_db(i) > X_db(i+1)) && (X_db(i) >= peak_thresh_db)
        peak_indices = [peak_indices, i];
    end
end
if ~isempty(peak_indices)
    peak_indices = peak_indices(diff([0 peak_indices]) >= min_peak_dist_bins);
end

peak_freqs = f_axis(peak_indices);
peak_amps_db = X_db(peak_indices);

%% ==================== FIGURE 6 ====================
fig6 = figure('Color', 'w', 'Name', 'Fig6_PeakDetail_IEEE', ...
              'Position', [150 80 900 550]);

if ~isempty(peak_freqs)
    bar(peak_freqs/1000, peak_amps_db, 0.6, ...
        'FaceColor', [0.2 0.45 0.75], 'EdgeColor', 'k', 'LineWidth', 1.0);
    hold on;
    
    plot(peak_freqs/1000, peak_amps_db, 'o', ...
         'MarkerSize', 10, 'MarkerFaceColor', [0.9 0.2 0.2], ...
         'MarkerEdgeColor', 'w', 'LineWidth', 1.2);
    
    for k = 1:length(peak_freqs)
        text(peak_freqs(k)/1000, peak_amps_db(k) + 4.5, ...
            sprintf('%.0f Hz', peak_freqs(k)), ...
            'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');
    end
end

xlabel('Frequency (kHz)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Peak Amplitude (dB)', 'FontSize', 12, 'FontWeight', 'bold');
title('Detected Spectral Peaks from FPGA Peak Detection Module', ...
      'FontSize', 13.5, 'FontWeight', 'bold');

grid on;
ylim([min(peak_amps_db)-15, max(peak_amps_db)+18]);

% Annotation box
annotation('textbox', [0.15 0.12 0.40 0.20], ...
    'String', {'Peak detection is performed in hardware using', ...
               'a simple local-maximum algorithm with threshold.', ...
               '', ...
               'This method is efficient and easily implementable', ...
               'on FPGA using comparators and state machines.'}, ...
    'FitBoxToText', 'on', ...
    'BackgroundColor', [0.96 0.96 1], ...
    'EdgeColor', [0 0.25 0.5], ...
    'LineWidth', 1.2, ...
    'FontSize', 9.5);

text(0.5, 0.03, ...
    'FPGA Implementation: Local-max peak detection using comparator chain (HDL-friendly)', ...
    'Units', 'normalized', 'HorizontalAlignment', 'center', ...
    'FontSize', 9.5, 'Color', [0 0.35 0], 'FontAngle', 'italic');

exportgraphics(fig6, fullfile(fig_folder, 'Fig6_PeakDetail_IEEE.png'), 'Resolution', export_dpi);
exportgraphics(fig6, fullfile(fig_folder, 'Fig6_PeakDetail_IEEE.pdf'), 'ContentType', 'vector');

fprintf('✅ Figure 6 generated successfully!\n');
fprintf('   Saved: Fig6_PeakDetail_IEEE.png\n');
