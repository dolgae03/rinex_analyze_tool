function sig = stdnan(x);
idx = ~isnan(x);
sig = std(x(idx(:)));

end