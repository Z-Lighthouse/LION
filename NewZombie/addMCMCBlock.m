function dd = addMCMCBlock(List_mcmc)
disp('addMCMCBlock');
List_mcmc_new = List_mcmc;
for i = 1:size(List_mcmc_new)
    for j = i+1:size(List_mcmc_new)
        if ~strcmp(List_mcmc_new(i),List_mcmc_new(j))
        else
            List_mcmc_new(i)={1};
        end
    end
end
List_mcmc_new = List_mcmc_new(cellfun(@(p)~isequal(p,1),List_mcmc_new));
m = size(List_mcmc_new,1);
p = ones(m);
p = 0;
for i = 1:size(List_mcmc)
    for j = i+1:size(List_mcmc)-1
        if strcmp(List_mcmc(i),List_mcmc(j))
            p=p+1;
            p(i,j)=p/m;
        end
    end
end
k=0;
for i = 1:m
    a = P(:,1)./P(1,:);
    for j = size(a)
        if a(j)>=1
            k=k+1;
        end
    end
end
List_mcmc_accepted = {};
for i =1:m
    a = P(:,1)./P(1,:);
    for j = size(a)
        if a(j)>=1
            List_mcmc_accepted{i} = List_mcmc_new{i};
        end
    end
end
end