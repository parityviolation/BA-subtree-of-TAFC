function  spiketimes  = unwrap_time( t, tr, dur, spacing)
 
cumdur = cumsum([0 dur(1:end-1)]) + spacing*[0:(length(dur)-1)];
    spiketimes = t + cumdur(tr);

