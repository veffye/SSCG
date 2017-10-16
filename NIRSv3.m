clc;
clear;
close all;

tmin=0;                       %sec
tmax=100;                        %sec
steps=5e4;                      
h = (tmax-tmin)/(steps-1);      %sec
t=tmin:h:tmax;  
CenterFrequency=5;              %Hz
FrequencyDeviation=1;           %Hz
widthT=50;                      %sec

%{
tmin = 0;
%Dlitel'nost' signala
tmax = input('Signal duration (s) = ');
%Kol-vo shagov
steps = input('How many steps = ');   
%Dlitel'nost' shaga
h = (tmax-tmin)/(steps-1);
t=tmin:h:tmax;

%Central'naya chastota
CenterFrequency = input('Center frequency (Hz) = ');
%Otklonenie chastoti
FrequencyDeviation = input('Frequency deviation (Hz) = ');
% "Shirina treygol'nika" 
widthT = 1 / input('Modulation rate (Hz) = ');   
%}

%Modulating signal generation
d = tmin:widthT:tmax;  
ModulatingSignal = 2 * FrequencyDeviation * pulstran(t - widthT/2 , d , 'tripuls' , widthT) + (CenterFrequency - FrequencyDeviation);

%Frequency array
%f = (0:100002-1)/steps/h;
f=(0:steps)/steps/h;
%Pulse amplitude
A=5;
%Definition array for SSCG 
SSCG(1:steps) = 0;
%Temprorary dot on ModulatingSignal plot
Temp = int64(1);
%Initial value
SpectrumSSCG = 0;

while Temp <= steps 
   %value from ModulatingSignal 
   fT = ModulatingSignal(Temp);
   %pulse duration
   tay = 1/(2*fT);
   SSCG(Temp : Temp + (ceil(tay/h)-1)) = A;
   tay = (ceil(tay/h))*h;
   %Spectrum of a signal as a sum of the spectra of pulses
   SpectrumSSCG = SpectrumSSCG + A*tay*sinc(f*tay).*exp(-1i*2*pi*f*(double(Temp)*h+tay/2));
   %Temprorary dot shift
   Temp = int64(ceil(Temp) + 2*tay/h);  
   
end

figure(1)
%ModulatingSignal plot
subplot(4,1,1);
plot(t,ModulatingSignal);
grid on;
xlabel('time, sec');
ylabel('Frequency, Hz');
title('Frequency profile of spread-spectrum CLK');
axis([tmin tmax 0 1.1*(CenterFrequency+FrequencyDeviation)]);
T=tmin:(tmax-tmin)/(length(SSCG)-1):tmax;
subplot(4,1,2);
plot(T,SSCG);
grid on;
xlabel('time, sec');
ylabel('Amplitude, V');
title('Spread-Spectrum CLK');
axis([tmin tmax 0 6]);   

%{
subplot(4,1,3);
plot(f,20*log10(abs(SpectrumSSCG)));
xlim([0 20])
ylim([-50 30])
grid on;
xlabel('Hz');
ylabel('dB');
title('Spectrum');
%}

%FFT  SSCG
subplot(2,1,2);
plot((0:length(SSCG)-1)/steps/h - 0.5/h,fftshift(20*log10(abs(fft(SSCG))*h)),...
     f,20*log10(abs(SpectrumSSCG)));
xlim([0 20])
ylim([-50 30])
grid on;
xlabel('Hz');
ylabel('dB');
title('Spectrum'); 


figure(2)
spectrogram(SSCG, 1024 , 512 , 1024 , 1/h,'yaxis');

