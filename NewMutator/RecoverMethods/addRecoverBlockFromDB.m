function last_Outport = addRecoverBlockFromDB(Obj,Name,sys_path)
disp('addMutatorRandomBlockFromDB');
% 每层最大生成块数
GEN_NUM = 1;
% 生成层数
GEN_DEEPTH = 3;
% 记录第一个块的名字
first_blk = Name;
% 获取系统中的所有块
all_block = find_system(Obj.mutant.sys,'Type','Block');
all_blk_type = get_param(all_block,'BlockType');
% 去重
all_blk_type = unique(all_blk_type);
% 去掉一些不能生成的 SubSystem Outport To Workspace
all_blk_type(strcmp(all_blk_type,'Outport'))=[];
all_blk_type(strcmp(all_blk_type,'SubSystem'))=[];
all_blk_type(strcmp(all_blk_type,'ToWorkspace'))=[];
all_blk_type(strcmp(all_blk_type,'ActionPort'))=[];
all_blk_type(strcmp(all_blk_type,'S-Function'))=[];
all_blk_type(strcmp(all_blk_type,'If Action Subsystem'))=[];
% 随机取一个块
blk = MCMCchoose(all_blk_type);
% 获取这个块的全名
blk = getFullBlockTypeName(blk);
f_tName = strcat(Name,'_start');
% 生成这个块
add_block(blk,f_tName);
ft_port = get_param(f_tName,'PortHandles');
% 判断一下有没有Inport口
while isempty(ft_port.Inport)
    delete_block(f_tName);
    new_blk = MCMCchoose(all_blk_type);
    % 获取这个块的全名
    new_blk = getFullBlockTypeName(new_blk);
    f_tName = strcat(Name,'_start');
    add_block(new_blk,f_tName);
    ft_port = get_param(f_tName,'PortHandles');
end
% 把这个块和Name后续连到一起
name_port = get_param(Name,'PortHandles');
try
    add_line(sys_path,name_port.Outport(1),ft_port.Inport(1),'autorouting','on');
catch
end
% 判断一下是否是If
if strcmp(blk,'simulink/Ports & Subsystems/If')
    if_sub = strcat(f_tName,'if_sub');
    add_block('simulink/Ports & Subsystems/If Action Subsystem',if_sub);
    ifaction_port = get_param(if_sub,'PortHandles');
    n_port = get_param(f_tName,'PortHandles');
    add_line(sys_path,n_port.Outport(1),ifaction_port.Ifaction,'autorouting','on');
    f_tName = if_sub;
end
% 记录第一个块的名字
first_blk = f_tName;
% 数据库操作
conn = database('newzombiedb', 'root', 'zhongrui985527', 'com.mysql.jdbc.Driver', 'jdbc:mysql://localhost:3306/newzombiedb');
% 根据层数生成
tree = {first_blk};
for i = 1:GEN_DEEPTH
    % 看看几个要生成的
    n_tree_list={};
    for j =1:length(tree)
        % 随机确定生成几个
        num = GEN_NUM;
        blk = tree{j};
        port = get_param(blk,'PortHandles');
        all_blk_type = addBlockFromdb(blk);
        % 如果没有
        if isempty(all_blk_type)
            continue;
        end
        % 如果数量不够
        if length(all_blk_type) < num
            num = length(all_blk_type);
        end

        for w = 1:num
            % 随机生成一个
            new_blk = MCMCchoose(all_blk_type);
            nblk_Name = strcat(first_blk,'nzb','_',string(i),'_',string(j),'_',string(w));
            try
                add_block(new_blk,nblk_Name);
            catch e
                disp(e.message);
            end
            n_port = get_param(nblk_Name,'PortHandles');
            % 判断一下有没有Inport口
            while isempty(n_port.Inport)||isempty(n_port.Outport)
                delete_block(nblk_Name);
                new_blk = MCMCchoose(all_blk_type);
                nblk_Name = strcat(first_blk,'nzb','_',string(i),'_',string(j),'_',string(w));
                try
                    add_block(new_blk,nblk_Name);
                catch e
                    disp(e.message);
                end
                n_port = get_param(nblk_Name,'PortHandles');
            end
            % 添加线
            try
                add_line(sys_path,port.Outport(1),n_port.Inport(1),'autorouting','on');
            catch e
                add_line(sys_path,port.Outport,n_port.Inport(1),'autorouting','on');
            end
            n_tree_list{end+1} = nblk_Name(1,1);
            % 判断一下是否是If
            if strcmp(new_blk,'simulink/Ports & Subsystems/If')
                if_sub = strcat(nblk_Name,'if_sub');
                add_block('simulink/Ports & Subsystems/If Action Subsystem',if_sub);
                ifaction_port = get_param(if_sub,'PortHandles');

                add_line(sys_path,n_port.Outport(1),ifaction_port.Ifaction,'autorouting','on');
                nblk_Name = if_sub;
                n_tree_list{end} = nblk_Name;
            end
        end
    end
    if ~isempty(n_tree_list)
        tree = n_tree_list;
    else
        break;
    end
end
% 根据块和数量从数据库中选取生成
    function block_list = addBlockFromdb(name)
        %1.查询类别
        blk_type = get_param(name,'BlockType');
        blk_type = getFullBlockTypeName(blk_type);
        sql = strcat('select * from blockMap where srcType="',blk_type,'"');
        %2.如果没有，就退出
        cursorA = exec(conn, sql);
        setdbprefs ('DataReturnFormat','cellarray');
        cursorA=fetch(cursorA);

        % 如果没有后续的话，就不能再加了
        block_list={};
        if ~isempty(cursorA.Data)
            if strcmp(cursorA.Data{1},'No Data')
                return;
            end
            % 可供选择的块的数组
            for j =1:size(cursorA.Data,1)
                result = string(cursorA.Data{j,3});
                if contains(result,'simulink')
                    %如果字符串中含有“m”则执行if内的程序
                    if contains(result,'Bus')
                        block_list{j} ='';
                    elseif contains(result,'MATLAB')
                        block_list{j} ='';
                    else
                        block_list{j} =result;
                    end
                else
                    block_list{j} ='';
                end
            end
        end
        % 去掉一下不符合线路的报错的块
        block_list(strcmp(block_list,''))=[];

    end
% 随机选择块的方法
    function blk = randomchoose(all_blk_type)
        % 去掉一下不符合线路的报错的块
        num = randi(length(all_blk_type));
        blk = all_blk_type{num};
    end
% MCMC的方法选择
    function blk = MCMCchoose(all_blk_type)
        % deleta数
        delta = .5;
        % 获取到到block数量
        blockCount = length(all_blk_type);
        % 定义正态分布函数
        pdf = @(x) normpdf(x);
        % 定义连续均匀概率密度函数
        proppdf = @(x,y) unifpdf(y-x,-delta,delta);
        % 定义和随机数生成器
        proprnd = @(x) (x - (1 - rand)* 2 * delta);
        x = mhsample(1,1,'pdf',pdf,'proprnd',proprnd,'symmetric',1);
        % 注意+1
        BlockNum =  int16((blockCount-1) * x) + 1;
        % 得到的具体block
        blk = all_blk_type{BlockNum};
    end
close(conn);
% 返回最后一个块的输出端口
last_blk = tree{1};
PortHandles = struct2table(get_param(last_blk, 'PortHandles'),'AsArray', true);
last_Outport = PortHandles.Outport;
end
