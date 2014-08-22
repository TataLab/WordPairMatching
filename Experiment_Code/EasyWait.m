function [ done ] = EasyWait( time )
%EASYWAIT high resolution countdown timer that's neat and tidy

t=tic;
done=0;

while(toc(t)<time)
    %spin
end

done=1;

return;
end

