%% ============================================================
%%  FIGURE 7: SIMULATION SUMMARY & FPGA RESOURCE UTILIZATION
%%  IEEE Paper Ready - Professional Version
%% ============================================================

clear; clc; close all;

export_dpi = 300;
fig_folder = 'figures';
if ~exist(fig_folder, 'dir'), mkdir(fig_folder); end

%% ==================== FIGURE 7 ====================
fig7 = figure('Color', 'w', 'Name', 'Fig7_Summary_IEEE', ...
              'Position', [120 60 850 620]);

% Top: Key Results
subplot(2,1,1);
axis off;

text(0.08, 0.92, 'FPGA-Based Spectrum Analyzer - Key Simulation Results', ...
     'FontSize', 14, 'FontWeight', 'bold');

text(0.08, 0.80, 'FFT Configuration:', 'FontSize', 11, 'FontWeight', 'bold');
text(0.08, 0.73, '    • FFT Length (N): 1024 points', 'FontSize', 10.5);
text(0.08, 0.66, '    • Sampling Rate: 48 kSPS', 'FontSize', 10.5);
text(0.08, 0.59, '    • ADC Resolution: 12 bits (XADC compatible)', 'FontSize', 10.5);
text(0.08, 0.52, '    • Window Function: Hann', 'FontSize', 10.5);
text(0.08, 0.45, '    • Frequency Resolution: 46.875 Hz/bin', 'FontSize', 10.5);

text(0.08, 0.35, 'Peak Detection Results:', 'FontSize', 11, 'FontWeight', 'bold');
text(0.08, 0.28, '    • Number of Peaks Detected: 4', 'FontSize', 10.5);
text(0.08, 0.21, '    • Detection Threshold: -45 dB', 'FontSize', 10.5);
text(0.08, 0.14, '    • Algorithm: Local-max with minimum distance (HDL-friendly)', 'FontSize', 10.5);

text(0.08, 0.05, 'Real-time Performance:', 'FontSize', 11, 'FontWeight', 'bold');
text(0.08, -0.02, '    • Theoretical Update Rate: ≈ 46.9 spectra/second', 'FontSize', 10.5);

% Bottom: Resource Utilization
subplot(2,1,2);

resources = {'LUTs', 'Flip-Flops', 'DSP48 Slices', 'BRAM18Kb'};
utilization = [12, 8, 35, 6];   % ← Thay bằng số thật từ Vivado report của bạn

barh(utilization, 'FaceColor', [0.2 0.55 0.35], 'EdgeColor', 'k', 'LineWidth', 1.0);
set(gca, 'YTickLabel', resources, 'FontSize', 11);
xlabel('Utilization (%)', 'FontSize', 12, 'FontWeight', 'bold');
title('Estimated FPGA Resource Utilization (Zynq-7000, N=1024)', ...
      'FontSize', 12, 'FontWeight', 'bold');
xlim([0 100]);
grid on;

for i = 1:length(utilization)
    text(utilization(i) + 2, i, sprintf('%d%%', utilization(i)), ...
         'FontSize', 10, 'FontWeight', 'bold', 'VerticalAlignment', 'middle');
end

text(50, -0.6, ...
    'Note: Resource values are estimates. Replace with your actual Vivado synthesis report.', ...
    'Units', 'normalized', 'HorizontalAlignment', 'center', ...
    'FontSize', 9, 'Color', [0.3 0.3 0.3], 'FontAngle', 'italic');

exportgraphics(fig7, fullfile(fig_folder, 'Fig7_Summary_IEEE.png'), 'Resolution', export_dpi);
exportgraphics(fig7, fullfile(fig_folder, 'Fig7_Summary_IEEE.pdf'), 'ContentType', 'vector');

fprintf('✅ Figure 7 generated successfully!\n');
fprintf('   Saved: Fig7_Summary_IEEE.png\n');