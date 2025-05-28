// ==============================================
// Working Digital Modulation Simulator
// with Guaranteed Graphic Display
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
// Create and Display Graphics Window
// ========================
f = scf(0); // Create figure with handle 0
clf(f); // Clear it
f.figure_name = "Digital Modulation Simulator - " + strcat(string(bits));
f.figure_size = [800, 800];
f.background = color("white");

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

// Force display update
show_window(f);
