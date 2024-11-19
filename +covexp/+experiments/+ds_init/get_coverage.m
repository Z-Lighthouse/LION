function r = get_coverage(r)
%GET_COVERAGE Summary of this function goes here
%   Detailed explanation goes here
r.simdur = [];

r.exception = false;
r.exception_ob = [];

r.blocks = [];
r.numzerocov = [];
r.num_zero_dec_cov = [];
r.num_zero_cond_cov = [];
r.num_zero_mcdc_cov = [];

r.stoptime_changed = [];

r.loc = []; % Used for Corpus models. For EXPLORE mode, use loc_input

r.duration = [];
end

