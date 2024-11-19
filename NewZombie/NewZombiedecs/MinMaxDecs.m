function dd = MinMaxDecs(f,obj,block_result)
obj.l.info('----------------------MinMaxDecs Start----------------------');
% 通过采样时间判断他们的SampleTime是否一致 tag: 0 一致 1 输入不一致
tag =0;
comp_length=length(block_result.src_block_out(1).Time);
for j =2:length(block_result.src_block_out)
    if comp_length ~= length(block_result.src_block_out(j).Time)
        tag=1;
        break;
    end
end
% 输入输出检查
if tag == 0 && (comp_length ~= length(block_result.this_block_out.Time))
    fprint2mat(f,block_result.this_block_out.Name,'  Time mismatch');
    return;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
this_data = block_result.this_block_out.Data;
% 一致做法
if tag == 0
    NameList={};
    for wks =1:length(block_result.src_block_out)
        position = find(this_data == block_result.src_block_out(wks).Data);
        % 完全没被用到
        if isempty(position)
            NameList{end+1} = block_result.src_block_out(wks).Name;
        end
        % 说明他一个人就能表示所有的情况
        if length(position) == length(this_data)
            for ts =1:length(block_result.src_block_out)
                name = block_result.src_block_out(ts).Name;
                if ~strcmp(name,block_result.src_block_out(wks).Name)
                    NameList{end+1} = name;
                end
            end
            break;
        end
    end
    % 数组去重
    NameList = unique(NameList);
    % 开始进行具体变异
    if length(NameList) == 1
        name = NameList{1};
        place = strfind(name, '/');
        sys_path = name(1:place(end)-1);
        % 1.添加随机块
%         addRandomBlockFromSystem(obj,name,sys_path);
        % 2.从数据库里添加块
%         addDBBlock(obj,name,sys_path);
        % 3.随机添加块
%         addRandomBlockFromLibrary(obj,name,sys_path);
        % 4.MCMC
%         addMCMCBlock(obj,name,sys_path);
    else
        for i=1:length(NameList)
            name = NameList{i};
            place = strfind(name, '/');
            sys_path = name(1:place(end)-1);
            % 1.添加随机块
%             addRandomBlockFromSystem(obj,name);
            % 2.从数据库里添加块
%             addDBBlock(obj,name,sys_path);
            % 3.随机添加块
%             addRandomBlockFromLibrary(obj,name,sys_path);
            % 4.MCMC
%             addMCMCBlock(obj,name,sys_path);
        end
    end
    % 不一致做法
elseif tag == 1
    disp('长度不一致');
end
obj.l.info('----------------------MinMaxDecs End----------------------');
end