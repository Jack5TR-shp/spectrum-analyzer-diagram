%% ============================================================
%%  FIGURE 5: REAL-TIME WATERFALL SPECTROGRAM (IMPROVED)
%%  IEEE Paper Ready
%% ============================================================

clear; clc; close all;

fs = 48000;
N = 1024;

frequencies = [1000, 4500, 12000, 18500];
amplitudes  = [0.85, 0.65, 0.45, 0.25];
phases      = [0, pi/4, pi/3, pi/6];

add_noise = true;
noise_level = 0.02;
num_frames = 30;

export_dpi = 300;
fig_folder = 'figures';
if ~exist(fig_folder, 'dir'), mkdir(fig_folder); end

%% ==================== TẠO DỮ LIỆU WATERFALL ====================
t = (0:N-1) / fs;
spec_matrix = zeros(num_frames, floor(N/2)+1);
time_axis = (0:num_frames-1) * (N/fs);

for frm = 1:num_frames
    x_frame = zeros(1, N);
    for i = 1:length(frequencies)
        drift = 15 * sin(2*pi*0.25*frm/num_frames);
        amp_mod = amplitudes(i) * (0.88 + 0.12*sin(2*pi*frm/6));
        x_frame = x_frame + amp_mod * sin(2*pi*(frequencies(i)+drift)*t + phases(i));
    end
    if add_noise
        x_frame = x_frame + noise_level * randn(1, N);
    end
    x_frame = x_frame / max(abs(x_frame)) * 0.95;

    q_levels = 2^11;
    xq = round(x_frame * q_levels) / q_levels;
    w = 0.5 * (1 - cos(2*pi*(0:N-1)/(N-1)));
    xw = xq .* w;
    Xf = fft(xw, N);
    spec_matrix(frm, :) = 20*log10(abs(Xf(1:floor(N/2)+1)) / max(abs(Xf(1:floor(N/2)+1))) + eps);
end

f_axis = (0:floor(N/2)) * (fs / N);

%% ==================== FIGURE 5 ====================
fig5 = figure('Color', 'w', 'Name', 'Fig5_Waterfall_Improved', ...
              'Position', [60 50 1080 600]);

imagesc(f_axis/1000, time_axis*1000, spec_matrix);
colormap(parula);
c = colorbar;
c.Label.String = 'Magnitude (dB)';
c.Label.FontSize = 11;

xlabel('Frequency (kHz)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Time (ms)', 'FontSize', 12, 'FontWeight', 'bold');
title('Real-Time Waterfall Spectrogram of FPGA-Based Spectrum Analyzer', ...
      'FontSize', 14, 'FontWeight', 'bold');

set(gca, 'YDir', 'normal');
grid on;
set(gca, 'GridLineStyle', ':', 'GridAlpha', 0.3);

% Annotation box (chuyên nghiệp hơn)
annotation('textbox', [0.13 0.13 0.40 0.22], ...
    'String', {'This waterfall plot simulates the real-time', ...
               'spectrum display on FPGA HDMI/VGA output.', ...
               '', ...
               'Each horizontal line represents one 1024-point', ...
               'FFT result (updated every ~21 ms).'}, ...
    'FitBoxToText', 'on', ...
    'BackgroundColor', [0.96 0.96 1], ...
    'EdgeColor', [0 0.25 0.5], ...
    'LineWidth', 1.3, ...
    'FontSize', 10);

% Dòng note FPGA
text(0.5, 0.03, ...
    'FPGA Implementation: Continuous FFT processing with real-time HDMI spectrum display', ...
    'Units', 'normalized', 'HorizontalAlignment', 'center', ...
    'FontSize', 10, 'Color', [0 0.4 0], 'FontAngle', 'italic');

exportgraphics(fig5, fullfile(fig_folder, 'Fig5_Waterfall_Improved.png'), 'Resolution', export_dpi);
exportgraphics(fig5, fullfile(fig_folder, 'Fig5_Waterfall_Improved.pdf'), 'ContentType', 'vector');

fprintf('✅ Fig5 đã cải thiện xong!\n');
fprintf('   Saved: Fig5_Waterfall_Improved.png\n');
