function [DOS,DOSval] = Beyer_Swinehart(energy,frequencies)

DOS = zeros(energy+1,1);
DOS(1)=1;



for i = 1:length(frequencies)
    for j = frequencies(i):energy
        DOS(j+1) = DOS(j+1) + DOS(j+1-frequencies(i));
    end
end

DOSval = DOS(end);