function [all_blocks, num_zero_cov,num_zero_dec_cov,num_zero_cond_cov,num_zero_mcdc_cov] = get_model_coverage(h, reduce_blocks)
%GET_MODEL_COVERAGE Summary of this function goes here
%   WARNING -- If you add new data here (e.g. to `blocks`, you would need
%   to rerun experiment # 2,3, and 8. So probably exp#8 is a better place
%   to add new stuff.

if nargin == 1
    reduce_blocks = false;
end

% Dynamic Signal Range analysis
% https://www.mathworks.com/help/slcoverage/ref/sigrangeinfo.html
DO_SIGNAL_RANGE = true;

num_zero_cov = 0; % blocks with zero executioninfo coverage
num_zero_dec_cov = 0; % blocks with zero executioninfo coverage
num_zero_cond_cov = 0; % blocks with zero executioninfo coverage
num_zero_mcdc_cov = 0; % blocks with zero executioninfo coverage

testObj  = cvtest(h);

if DO_SIGNAL_RANGE
    %Enable signal range coverage
    testObj.settings.sigrange = 1;
end

if reduce_blocks
    warning('Setting CovForceBlockReductionOff=off')
    data = cvsim(testObj, 'CovForceBlockReductionOff', 'off');
else
    % Note: this just disables the force-off. Behavior will now depend on
    % the model's 'BlockReduction' parameter. What if is is set to 'off'?
    % Default is 'on'
    data = cvsim(testObj);
end

blocks = covexp.get_all_blocks(h);
disp('============getAllBlocks===============');
path_name = getfullname(h);
% 记录各个块之间的联系
getFullBlockPath(path_name);
% 记录决策块
% DCfile = fopen('/Users/ojiken/Desktop/slemi-new zombile block/NewZombie/DCdetail.txt','a');
disp('============getFullBlockPath Finish get_model_coverage===============');


all_blocks = struct;

for i=1:numel(blocks)
    cur_blk = blocks(i);
    cur_blk_name = getfullname(cur_blk);
    cov = executioninfo(data, cur_blk);
    % 加入决策覆盖等其他覆盖
    dec_cov = decisioninfo(data, cur_blk);
    cond_cov = conditioninfo(data, cur_blk);
    mcdc_cov = mcdcinfo(data, cur_blk);
    percent_cov = [];
    percent_dec_cov = [];
    percent_cond_cov = [];
    percent_mcdc_cov = [];
    
    % 执行覆盖
    if ~ isempty(cov)
        percent_cov = 100 * cov(1) / cov(2);
        if percent_cov == 0
            num_zero_cov = num_zero_cov + 1;
        end
    end
    % 决策覆盖
    if ~ isempty(dec_cov)
        percent_dec_cov = 100 * dec_cov(1) / dec_cov(2);
        
        if percent_dec_cov ~= 100
            num_zero_dec_cov = num_zero_dec_cov + 1;
            % 记录决策信息
            if h~=cur_blk
%                  getDCBlockDetail(DCfile,h,cur_blk);
            end
           
        end
    end
    % 条件覆盖
    if ~ isempty(cond_cov)
        percent_cond_cov = 100 * cond_cov(1) / cond_cov(2);
        
        if percent_cond_cov ~= 100
            num_zero_cond_cov = num_zero_cond_cov + 1;
        end
    end
    % mcdc覆盖
    if ~ isempty(mcdc_cov)
        percent_mcdc_cov = 100 * mcdc_cov(1) / mcdc_cov(2);
        
        if percent_mcdc_cov ~= 100
            num_zero_mcdc_cov = num_zero_mcdc_cov + 1;
        end
    end
    
    
    sigRange = {};
    usable_sigRange = false; % Can use this signal range to synthesize conditions
    
    if DO_SIGNAL_RANGE && cur_blk ~= h % Not Root-level model
        
        try
            [~, ~, dsts] = emi.slsf.get_connections(cur_blk, false, true);
            
            n_dsts = size(dsts, 1);
            
            tmp = utility.cell(n_dsts);
            
            for d=1:n_dsts
                [minVal, maxVal] = sigrangeinfo(data, cur_blk, d);
                %                 if isinf(minVal)
                %                     disp('inf');
                %                 end
                tmp.add({minVal, maxVal});
                
                if ~usable_sigRange && (~isempty(minVal))
                    usable_sigRange = true;
                end
            end
            
            sigRange = tmp.get_cell();
        catch e
            utility.print_error(e);
            rethrow(e);
        end
        
        %
        %         if ~isempty(minVal) || ~isempty(maxVal)
        %
        %         end
    end
    
    
    all_blocks(i).fullname = cur_blk_name;
    all_blocks(i).percentcov = percent_cov;
    % 其他覆盖信息
    all_blocks(i).percent_dec_cov = percent_dec_cov;
    all_blocks(i).percent_cond_cov = percent_cond_cov;
    all_blocks(i).percent_mcdc_cov = percent_mcdc_cov;
    
    all_blocks(i).sigRange = sigRange;
    all_blocks(i).usable_sigRange = usable_sigRange;
    %     all_blocks(i).maxVal = maxVal;
    
    try
        all_blocks(i).blocktype = get_param(cur_blk, 'blocktype');
    catch
        all_blocks(i).blocktype = [];
    end
end


end

