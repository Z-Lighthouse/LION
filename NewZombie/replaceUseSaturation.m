function dd = replaceUseSaturation(obj,this_block)
% 持久块
new_blk = 'simulink/Discontinuities/Saturation';
% 更换为持续块
replace_block(obj.mutant.sys,this_block.Name,new_blk);

end