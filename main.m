load acceleration_sensor_log.mat;
% Retrieve acceleration sensor data
t = Acceleration.Timestamp.Second + Acceleration.Timestamp.Minute * 60;
X = Acceleration.X;

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

stem(sanitizedT, sanitizedX);

% Get polynomial model
p = polyfit(sanitizedT,sanitizedX,15);
tp = 1:1:length(sanitizedT);
Xp = polyval(p,tp);
figure;
plot(sanitizedT,sanitizedX,tp,Xp);