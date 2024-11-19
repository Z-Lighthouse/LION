function dd = AbsDecs(f,obj,block_result)
obj.l.info('----------------------AbsDecs Start----------------------');
% 取本块输出
this_data = block_result.this_block_out.Data;
this_time = block_result.this_block_out.Time;
% 取出对比输出
comp_data = block_result.src_block_out(1).Data;
comp_time = block_result.src_block_out(1).Time;
% 1.检查输入块的数据与时间是否都相同
if length(block_result.src_block_out)~=1
    % 循环比较
    for i=2:length(block_result.src_block_out)
        if block_result.src_block_out(i).Data ~= comp_data
            fprint2mat(f,block_result.this_block_out.Name,'  Data mismatch');
            return;
        elseif block_result.this_block_out(i).Time ~= comp_time
            fprint2mat(f,block_result.this_block_out.Name,'  Time mismatch');
            return;
        end
    end
end
% 2.判断本块的输入与本块的输出是否一致
if comp_time ~= this_time
    fprint2mat(f,block_result.this_block_out.Name,'  Time mismatch');
    return;
end
% 3.进行具体的删除操作
for i = 1:length(this_data)
    if comp_data(i) == this_data(i)
    elseif comp_data(i) == -this_data(i)
    elseif strcmp(this_data(i),comp_data(i))
    else
        fprint2mat(f,block_result.this_block_out.Name,'  Data have Problem');
    end
end
if comp_data == this_data
    % 执行具体删除操作   
    deleteBlockWhileConnectBothSide(f,obj,block_result.src_block_out.Name,block_result.this_block_out.Name,block_result.dst_block_Name);
end
obj.l.info('----------------------AbsDecs End----------------------');
end