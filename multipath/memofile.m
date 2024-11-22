figure()
for k=[19 1 2 3 4]
    plot(1:4637,each_mul(k,:));
    hold on
    grid on
    ylim([-1 1]);
end

