%This script computes the performance of the subjects by counting the
%number of hit, miss, lure, false alarm, and correct rejection.


for i = 1:numBlocks
    for j = 1:numTrials 
        if strncmp(allTrials{i,1}(j).outcome,'hit',1)
            hitCounter=hitCounter+1;
        elseif strncmp(allTrials{i,1}(j).outcome,'miss',1)
            missCounter=missCounter+1;  
        elseif strncmp(allTrials{i,1}(j).outcome,'lure',1)
            lureCounter = lureCounter+1;
        elseif strncmp(allTrials{i,1}(j).outcome,'false_alarm',1)
            FACounter = FACounter+1;
        else strncmp(allTrials{i,1}(j).outcome,'correct_rejection',1)
            CRCounter=CRCounter+1;
        end
    end
end
%performance structure
performance.hit=100*hitCounter/(numBlocks*numPairs);
performance.miss=100*missCounter/(numBlocks*numPairs);
performance.lure=100*lureCounter/(numBlocks*numPairs);
performance.correct_rejection=100*CRCounter/(numBlocks*numPairs);
performance.false_alarm=100*FACounter/(numBlocks*numTrials);
%performance vector (percentage)
performanceVector=100*[hitCounter,missCounter,lureCounter,CRCounter,FACounter/2]/(numBlocks*numPairs);
