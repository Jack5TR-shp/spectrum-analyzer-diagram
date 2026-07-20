%% ============================================================
%%  FIGURE 3: FFT SPECTRUM WITH DETECTED PEAKS
%%  IEEE Paper Ready - Standalone Version
%% ============================================================

clear; clc; close all;

%% ==================== PARAMETERS ====================
fs = 48000;
N = 1024;
bits_adc = 12;
window_type = 'hann';

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

%% ==================== SIGNAL + PROCESSING ====================
t = (0:N-1) / fs;
x = zeros(1, N);
for i = 1:length(frequencies)
    x = x + amplitudes(i) * sin(2*pi*frequencies(i)*t + phases(i));
end
if add_noise
    x = x + noise_level * randn(1, N);
end
x = x / max(abs(x)) * 0.95;

% 12-bit ADC
q_levels = 2^(bits_adc - 1);
x_quant = round(x * q_levels) / q_levels;

% Windowing
switch lower(window_type)
    case 'hann'
        w = 0.5 * (1 - cos(2*pi*(0:N-1)/(N-1)));
    case 'hamming'
        w = 0.54 - 0.46*cos(2*pi*(0:N-1)/(N-1));
    case 'blackman'
        w = 0.42 - 0.5*cos(2*pi*(0:N-1)/(N-1)) + 0.08*cos(4*pi*(0:N-1)/(N-1));
    otherwise
        w = ones(1, N);
end
w = w(:)';
x_windowed = x_quant .* w;

% FFT
X = fft(x_windowed, N);
X_single = X(1:floor(N/2)+1);
f_axis = (0:floor(N/2)) * (fs / N);
X_mag = abs(X_single);
X_db = 20 * log10(X_mag / max(X_mag) + eps);

%% ==================== PEAK DETECTION ====================
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

%% ==================== FIGURE 3 - IEEE STYLE ====================
fig3 = figure('Color', 'w', 'Name', 'Fig3_Spectrum_Peaks_IEEE', ...
              'Position', [120 60 1100 620]);

% Spectrum plot
plot(f_axis/1000, X_db, 'Color', [0 0.35 0.7], 'LineWidth', 1.3);
hold on;
grid on;
set(gca, 'GridLineStyle', ':', 'GridAlpha', 0.4);

% Detected peaks
if ~isempty(peak_indices)
    plot(peak_freqs/1000, peak_amps_db, 'o', ...
         'MarkerSize', 11, 'MarkerFaceColor', [0.85 0.1 0.1], ...
         'MarkerEdgeColor', 'w', 'LineWidth', 1.2);
    
    for k = 1:length(peak_freqs)
        plot([peak_freqs(k)/1000 peak_freqs(k)/1000], ...
             [min(X_db)-10 peak_amps_db(k)], '--', ...
             'Color', [0.85 0.1 0.1], 'LineWidth', 1.0);
        
        text(peak_freqs(k)/1000 + 0.28, peak_amps_db(k) + 3.5, ...
            sprintf('%.1f Hz  (%.1f dB)', peak_freqs(k), peak_amps_db(k)), ...
            'FontSize', 9.5, 'Color', [0.7 0 0], 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'left');
    end
end

xlabel('Frequency (kHz)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Magnitude (dB, normalized)', 'FontSize', 12, 'FontWeight', 'bold');
title(sprintf('FFT Spectrum Analyzer Output (N = %d, %s Window, %d-bit ADC)', ...
              N, window_type, bits_adc), 'FontSize', 13, 'FontWeight', 'bold');

legend('Magnitude Spectrum', 'Detected Peaks', 'Location', 'northeast', 'FontSize', 10);

% Annotation box
annotation('textbox', [0.13 0.105 0.36 0.195], ...
    'String', {sprintf('Sampling Rate: %d kHz', fs/1000), ...
               sprintf('Frequency Resolution: %.2f Hz / bin', fs/N), ...
               sprintf('Number of Peaks Detected: %d', length(peak_indices)), ...
               sprintf('Peak Detection Threshold: %.0f dB', peak_thresh_db), ...
               'Red markers = FPGA-implementable peak detection'}, ...
    'FitBoxToText', 'on', ...
    'BackgroundColor', [1 1 1], ...
    'EdgeColor', [0 0.3 0.6], ...
    'LineWidth', 1.2, ...
    'FontSize', 9.5);

% FPGA note
text(0.5, 0.015, ...
    'FPGA Implementation: Radix-2 FFT (custom or Xilinx IP) + simple local-max peak detection in hardware', ...
    'Units', 'normalized', 'HorizontalAlignment', 'center', ...
    'FontSize', 9, 'Color', [0 0.4 0], 'FontAngle', 'italic');

xlim([0 max(f_axis)/1000]);
ylim([min(X_db)-12 max(X_db)+8]);

%% Export
exportgraphics(fig3, fullfile(fig_folder, 'Fig3_SpectrumWithPeaks_IEEE.png'), 'Resolution', export_dpi);
exportgraphics(fig3, fullfile(fig_folder, 'Fig3_SpectrumWithPeaks_IEEE.pdf'), 'ContentType', 'vector');

fprintf('✅ Figure 3 generated successfully!\n');
fprintf('   Saved: Fig3_SpectrumWithPeaks_IEEE.png\n');
