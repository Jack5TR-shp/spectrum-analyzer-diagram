%% ============================================================
%%  FIGURE 4: EFFECT OF WINDOWING ON FFT SPECTRUM
%%  IEEE Paper Ready - Professional Version
%% ============================================================

clear; clc; close all;

%% ==================== PARAMETERS ====================
fs = 48000;
N = 1024;
bits_adc = 12;

frequencies = [1000, 4500, 12000, 18500];
amplitudes  = [0.85, 0.65, 0.45, 0.25];
phases      = [0, pi/4, pi/3, pi/6];

add_noise = true;
noise_level = 0.02;

export_dpi = 300;
fig_folder = 'figures';
if ~exist(fig_folder, 'dir'), mkdir(fig_folder); end

%% ==================== SIGNAL GENERATION ====================
t = (0:N-1) / fs;
x = zeros(1, N);
for i = 1:length(frequencies)
    x = x + amplitudes(i) * sin(2*pi*frequencies(i)*t + phases(i));
end
if add_noise
    x = x + noise_level * randn(1, N);
end
x = x / max(abs(x)) * 0.95;

q_levels = 2^(bits_adc - 1);
x_quant = round(x * q_levels) / q_levels;

w_hann = 0.5 * (1 - cos(2*pi*(0:N-1)/(N-1)));
x_windowed = x_quant .* w_hann;

%% ==================== FFT ====================
X_nowin = fft(x_quant, N);
X_db_nowin = 20 * log10(abs(X_nowin(1:floor(N/2)+1)) / max(abs(X_nowin(1:floor(N/2)+1))) + eps);

X_win = fft(x_windowed, N);
X_db_win = 20 * log10(abs(X_win(1:floor(N/2)+1)) / max(abs(X_win(1:floor(N/2)+1))) + eps);

f_axis = (0:floor(N/2)) * (fs / N);

%% ==================== FIGURE 4 - IEEE STYLE ====================
fig4 = figure('Color', 'w', 'Name', 'Fig4_WindowEffect_IEEE', ...
              'Position', [80 60 1150 520]);

% Left: No Window
subplot(1,2,1);
plot(f_axis/1000, X_db_nowin, 'r-', 'LineWidth', 1.3);
grid on;
xlabel('Frequency (kHz)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Magnitude (dB)', 'FontSize', 11, 'FontWeight', 'bold');
title('Without Windowing (Rectangular)', 'FontSize', 12, 'FontWeight', 'bold');
ylim([-90 5]);

text(0.5, -80, {'High sidelobes', 'Severe spectral leakage'}, ...
    'Units', 'normalized', 'HorizontalAlignment', 'center', ...
    'FontSize', 10, 'Color', [0.7 0 0], 'FontWeight', 'bold');

% Right: With Hann Window
subplot(1,2,2);
plot(f_axis/1000, X_db_win, 'b-', 'LineWidth', 1.3);
grid on;
xlabel('Frequency (kHz)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Magnitude (dB)', 'FontSize', 11, 'FontWeight', 'bold');
title('With Hann Windowing', 'FontSize', 12, 'FontWeight', 'bold');
ylim([-90 5]);

text(0.5, -80, {'Significantly reduced sidelobes', 'Clean spectral peaks'}, ...
    'Units', 'normalized', 'HorizontalAlignment', 'center', ...
    'FontSize', 10, 'Color', [0 0.4 0], 'FontWeight', 'bold');

sgtitle('Impact of Windowing on FFT Spectrum Quality', ...
        'FontSize', 14, 'FontWeight', 'bold');

% Annotation box
annotation('textbox', [0.23 0.12 0.54 0.18], ...
    'String', {'Windowing is essential in FFT-based spectrum analysis to suppress spectral leakage.', ...
               'The Hann window provides an excellent balance between frequency resolution and dynamic range.', ...
               'In FPGA implementation: Window multiplication is performed in real-time using DSP slices.'}, ...
    'FitBoxToText', 'on', ...
    'BackgroundColor', [0.96 0.96 1], ...
    'EdgeColor', [0 0.25 0.5], ...
    'LineWidth', 1.2, ...
    'FontSize', 9.5);

exportgraphics(fig4, fullfile(fig_folder, 'Fig4_WindowEffect_IEEE.png'), 'Resolution', export_dpi);
exportgraphics(fig4, fullfile(fig_folder, 'Fig4_WindowEffect_IEEE.pdf'), 'ContentType', 'vector');

fprintf('✅ Figure 4 generated successfully!\n');
fprintf('   Saved: Fig4_WindowEffect_IEEE.png\n');