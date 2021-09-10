load acceleration_sensor_log.mat;
% Retrieve acceleration sensor data
t = Acceleration.Timestamp.Second + Acceleration.Timestamp.Minute * 60;
X = Acceleration.X;

% Visualize raw sensor data
figure;
stem(t / 60, X);
grid;
title('Señal de entrada discreta');
xlabel('Tiempo (s)');
ylabel('Aceleración eje X');

% Sanitize sensor data so only integer second values are kept
t = floor(t);
sanitizedT = unique(t);
sanitizedX = zeros(size(sanitizedT));

cumCount = 0;
for i=1:length(sanitizedT)
    count = sum(sanitizedT(i) == t);
    sumX = 0;
    for j=cumCount:cumCount + count
        if j > 0
            sumX = sumX + X(j);
        end
    end
    cumCount = cumCount + count;
    sanitizedX(i) = sumX / count;
end

% Set initial time value at origin
sanitizedT = sanitizedT - sanitizedT(1);

% Visualize sanitized data
figure;
stem(sanitizedT, sanitizedX);
grid;
title('Señal de entrada discreta procesada');
xlabel('Tiempo (s)');
ylabel('Aceleración eje X');

% Moving average filter
windowSize = 5;
b = (1 / windowSize) * ones(1,windowSize);
a = 1;
filteredX = filter(b,a,sanitizedX);
figure;
plot(sanitizedT,filteredX);
grid;
title('Señal de entrada discreta filtrada');
xlabel('Tiempo (s)');
ylabel('Aceleración eje X');

% Get polynomial model
p = polyfit(sanitizedT,filteredX,17);
tp = 1:1:length(sanitizedT);
Xp = polyval(p,tp);
figure;
plot(sanitizedT,filteredX,tp,Xp);
grid;
title('Modelo polinomial de la señal de entrada discreta');
xlabel('Tiempo (s)');
ylabel('Aceleración eje X');

% Fast fourier transform
Fs = 242; % frecuencia de muestreo
T = 1/Fs; 
L = 121;
fourierT = (0:L-1) * T;

fourierX = fft(filteredX);

% Bilateral spectrum and frequency domain definition
P2 = abs(fourierX/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;
figure;
plot(f,P1);
grid;
title('Espectro de un sólo lado de X(t)');
xlabel('f(Hz)');
ylabel('|P1(f)|');

disp(fourierX);
        
