// ==============================================
// Complete Digital Modulation & PCM Simulator
// with Dual Graphic Windows
// ==============================================

clc;
clear;
close;

// ========================
// User Input Dialog
// ========================
bits = [];
valid_input = %f;
while ~valid_input
    bit_str = x_dialog(['Enter binary bit sequence (e.g., 1010)';'Minimum 4 bits, maximum 8 bits:'], '10110010');
    
    if bit_str == [] then
        exit; // User pressed cancel
    end
    
    // Validate input
    if ~isempty(strindex(bit_str,'0')) | ~isempty(strindex(bit_str,'1')) then
        bits = strsplit(bit_str)';
        bits = evstr(bits);
        if length(bits) >= 4 & length(bits) <= 8 then
            valid_input = %t;
        else
            messagebox("Please enter 4-8 bits", "Error", "error");
        end
    else
        messagebox("Please enter only 0s and 1s", "Error", "error");
    end
end

// ========================
// Simulation Parameters
// ========================
bit_rate = 100;         // bits per second
carrier_freq = 1000;    // Hz
sampling_rate = 10000;  // Samples per second
total_time = length(bits)/bit_rate; // Adjust time based on bits
t = 0:1/sampling_rate:total_time; // Time vector

// ========================
// Create Digital Signal
// ========================
bit_duration = 1/bit_rate;
samples_per_bit = bit_duration * sampling_rate;

digital_signal = [];
for i = 1:length(bits)
    digital_signal = [digital_signal bits(i)*ones(1, samples_per_bit)];
end

// ========================
// Digital-to-Analog Modulation
// ========================
function modulated_signal = modulate(signal, bits, modulation_type)
    carrier = sin(2*%pi*carrier_freq*t);
    modulated_signal = zeros(1, length(signal));
    
    for i = 1:length(bits)
        start_idx = (i-1)*samples_per_bit + 1;
        end_idx = i*samples_per_bit;
        
        if modulation_type == "ASK" then
            // Amplitude Shift Keying
            modulated_signal(start_idx:end_idx) = (0.5 + bits(i)*0.5) .* carrier(start_idx:end_idx);
        elseif modulation_type == "FSK" then
            // Frequency Shift Keying
            freq = carrier_freq * (0.5 + bits(i));
            modulated_signal(start_idx:end_idx) = sin(2*%pi*freq*t(start_idx:end_idx));
        elseif modulation_type == "PSK" then
            // Phase Shift Keying
            phase = %pi * bits(i);
            modulated_signal(start_idx:end_idx) = sin(2*%pi*carrier_freq*t(start_idx:end_idx) + phase);
        end
    end
endfunction

// Generate modulated signals
ask_signal = modulate(digital_signal, bits, "ASK");
fsk_signal = modulate(digital_signal, bits, "FSK");
psk_signal = modulate(digital_signal, bits, "PSK");

// ========================
// PCM Conversion Parameters
// ========================
analog_freq = 50; // Hz
analog_signal = 0.5*sin(2*%pi*analog_freq*t) + 0.5; // Offset to 0-1 range
quantization_levels = 16; // 4-bit quantization
sampling_interval = round(1/(2*analog_freq) * sampling_rate); // Nyquist rate

// Sample the analog signal
sampled_signal = analog_signal(1:sampling_interval:length(analog_signal));
sampled_time = t(1:sampling_interval:length(t));

// Quantize the samples
quantized_signal = round((quantization_levels-1)*sampled_signal)/(quantization_levels-1);

// Reconstruct digital signal
digital_output = [];
for i = 1:length(quantized_signal)
    digital_output = [digital_output quantized_signal(i)*ones(1, sampling_interval)];
end

// ========================
// Create Modulation Window
// ========================
f1 = scf(0); // Create figure with handle 0
clf(f1); // Clear it
f1.figure_name = "Digital Modulation - " + strcat(string(bits));
f1.figure_size = [800, 800];
f1.background = color("white");

// Digital Signal
subplot(4,1,1);
plot(t(1:length(digital_signal)), digital_signal, 'r', 'thickness', 2);
title("Original Digital Signal: " + strcat(string(bits)), "fontsize", 4);
xgrid(1);
a = gca();
a.grid = [1 1];
a.font_size = 3;
ylabel("Amplitude", "fontsize", 3);

// ASK Modulation
subplot(4,1,2);
plot(t(1:length(ask_signal)), ask_signal, 'b', 'thickness', 2);
title("ASK Modulation (Amplitude Shift Keying)", "fontsize", 4);
xgrid(1);
a = gca();
a.grid = [1 1];
a.font_size = 3;
ylabel("Amplitude", "fontsize", 3);

// FSK Modulation
subplot(4,1,3);
plot(t(1:length(fsk_signal)), fsk_signal, 'g', 'thickness', 2);
title("FSK Modulation (Frequency Shift Keying)", "fontsize", 4);
xgrid(1);
a = gca();
a.grid = [1 1];
a.font_size = 3;
ylabel("Amplitude", "fontsize", 3);

// PSK Modulation
subplot(4,1,4);
plot(t(1:length(psk_signal)), psk_signal, 'm', 'thickness', 2);
title("PSK Modulation (Phase Shift Keying)", "fontsize", 4);
xgrid(1);
a = gca();
a.grid = [1 1];
a.font_size = 3;
xlabel("Time (seconds)", "fontsize", 3);
ylabel("Amplitude", "fontsize", 3);

// Add bit indicators
for i = 1:length(bits)
    bit_time = (i-1)*bit_duration;
    for j = 1:4
        subplot(4,1,j);
        xstring(bit_time + bit_duration/2, -1.5, string(bits(i)));
        e = gce();
        e.font_size = 3;
        e.font_foreground = color("black");
    end
end

// ========================
// Create PCM Window
// ========================
f2 = scf(1); // Create figure with handle 1
clf(f2); // Clear it
f2.figure_name = "PCM Conversion";
f2.figure_size = [800, 600];
f2.background = color("white");

// Original Analog Signal
subplot(3,1,1);
plot(t, analog_signal, 'b', 'thickness', 2);
title("Original Analog Signal (50Hz)", "fontsize", 4);
xgrid(1);
a = gca();
a.grid = [1 1];
a.font_size = 3;
ylabel("Amplitude", "fontsize", 3);

// Sampled Signal
subplot(3,1,2);
plot(t, analog_signal, 'b:', 'thickness', 1);
plot(sampled_time, sampled_signal, 'ro', 'thickness', 2);
title("Sampled Signal (PCM Step 1)", "fontsize", 4);
xgrid(1);
a = gca();
a.grid = [1 1];
a.font_size = 3;
ylabel("Amplitude", "fontsize", 3);
legend(["Analog", "Samples"], 4);

// Quantized Signal
subplot(3,1,3);
plot(sampled_time, quantized_signal, 'g-', 'thickness', 2);
plot(sampled_time, quantized_signal, 'ro', 'thickness', 2);
title("Quantized Signal (PCM Step 2, " + string(quantization_levels) + " levels)", "fontsize", 4);
xgrid(1);
a = gca();
a.grid = [1 1];
a.font_size = 3;
xlabel("Time (seconds)", "fontsize", 3);
ylabel("Amplitude", "fontsize", 3);

// ========================
// Force Display Update
// ========================
show_window(f1);
show_window(f2);

// ========================
// Display Information
// ========================
disp("=== Simulation Parameters ===");
disp("Bit sequence: "+strcat(string(bits)));
disp("Bit rate: "+string(bit_rate)+" bps");
disp("Carrier frequency: "+string(carrier_freq)+" Hz");
disp("Sampling rate: "+string(sampling_rate)+" Hz");
disp("PCM quantization levels: "+string(quantization_levels));
