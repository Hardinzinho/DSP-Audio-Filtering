% =========================================================================
% BÀI TẬP LỚN XỬ LÝ TÍN HIỆU SỐ - HỌC VIỆN PTIT
% Chủ đề: Khử nhiễu tín hiệu âm thanh bằng FIR/IIR và phân tích chất lượng
% =========================================================================

clear all; close all; clc;

%% 1. KHỞI TẠO TÍN HIỆU VÀ NHIỄU
Fs = 16000;             % Tần số lấy mẫu 16 kHz
t = 0:1/Fs:0.05-1/Fs;   % Khởi tạo trục thời gian 0.05s

% Tín hiệu gốc: Sóng âm thanh hữu ích ở 1000 Hz
x_clean = sin(2*pi*1000*t);

% Tạo nhiễu: Nhiễu cao tần ở 6000 Hz
noise = 0.8 * sin(2*pi*6000*t);

% Tín hiệu thu được (Đầu vào bộ lọc)
x_noisy = x_clean + noise;

%% 2. THIẾT KẾ BỘ LỌC IIR VÀ FIR
Fc = 4000;              % Tần số cắt 4000 Hz
Wn = Fc/(Fs/2);         % Tần số cắt chuẩn hóa

% --- Thiết kế IIR (Butterworth) ---
Order_IIR = 6;          % Bậc IIR nhỏ
[b_iir, a_iir] = butter(Order_IIR, Wn, 'low');

% --- Thiết kế FIR (Cửa sổ Hamming) ---
Order_FIR = 40;         % Bậc FIR lớn
b_fir = fir1(Order_FIR, Wn, 'low', hamming(Order_FIR+1));
a_fir = 1;              % FIR không có mẫu số (a = 1)

%% 3. THỰC HIỆN LỌC TÍN HIỆU
y_iir = filter(b_iir, a_iir, x_noisy);
y_fir = filter(b_fir, a_fir, x_noisy);

% Bù trễ pha cho FIR (do FIR có độ trễ nhóm = Order/2)
delay = Order_FIR/2;
y_fir_shifted = [y_fir(delay+1:end), zeros(1, delay)]; 

%% 4. TÍNH TOÁN VÀ SO SÁNH CHỈ SỐ SNR
P_signal = sum(x_clean.^2); % Công suất tín hiệu gốc

% SNR trước khi lọc
P_noise_init = sum((x_noisy - x_clean).^2);
SNR_init = 10 * log10(P_signal / P_noise_init);

% SNR sau lọc IIR
P_noise_iir = sum((y_iir - x_clean).^2);
SNR_iir = 10 * log10(P_signal / P_noise_iir);

% SNR sau lọc FIR
P_noise_fir = sum((y_fir_shifted - x_clean).^2);
SNR_fir = 10 * log10(P_signal / P_noise_fir);

% In kết quả ra màn hình Console
fprintf('================ SO SÁNH HIỆU SUẤT LỌC ================\n');
fprintf('SNR ban đầu (Tín hiệu lẫn nhiễu) : %7.2f dB\n', SNR_init);
fprintf('SNR sau khi qua bộ lọc IIR (Bậc 6) : %7.2f dB\n', SNR_iir);
fprintf('SNR sau khi qua bộ lọc FIR (Bậc 40): %7.2f dB\n', SNR_fir);
fprintf('=======================================================\n');

%% 5. VẼ ĐỒ THỊ SO SÁNH
% -------------------------------------------------------------------------
% HÌNH 1: SO SÁNH ĐÁP ỨNG TẦN SỐ (FIR vs IIR)
figure('Name', 'So sánh đáp ứng tần số', 'NumberTitle', 'off', 'Color', 'w');
[H_iir, w_iir] = freqz(b_iir, a_iir, 1024, Fs);
[H_fir, w_fir] = freqz(b_fir, a_fir, 1024, Fs);

plot(w_iir, 20*log10(abs(H_iir)), 'b', 'LineWidth', 1.5); hold on;
plot(w_fir, 20*log10(abs(H_fir)), 'r--', 'LineWidth', 1.5);
xline(Fc, 'k:', 'LineWidth', 1.5); % Đường gióng tần số cắt
title('So sánh Đặc tuyến Biên độ: IIR (Bậc 6) vs FIR (Bậc 40)');
xlabel('Tần số (Hz)'); ylabel('Biên độ (dB)');
legend('IIR Butterworth', 'FIR Hamming', 'Tần số cắt 4000Hz');
grid on; ylim([-80 10]);

% -------------------------------------------------------------------------
% HÌNH 2: SO SÁNH TÍNH ỔN ĐỊNH (POLE-ZERO MAP)
figure('Name', 'So sánh Tính ổn định', 'NumberTitle', 'off', 'Color', 'w');
subplot(1,2,1);
zplane(b_fir, a_fir);
title('Pole-Zero FIR (Các cực đều ở gốc tọa độ)');

subplot(1,2,2);
zplane(b_iir, a_iir);
title('Pole-Zero IIR (Các cực nằm trong |z|<1)');