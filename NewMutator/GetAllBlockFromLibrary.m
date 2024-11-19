function all_blk_type = GetAllBlockFromLibrary()
% 获得Library中的所有块
load_system('simulink');
Discrete_blocks = find_system('simulink/Discrete');
Continuous_blocks = find_system('simulink/Continuous');
Math_Operations_blocks = find_system('simulink/Math Operations');
Sources_blocks = find_system('simulink/Sources');
% 把block列表组装完毕
all_blk_type = {};
for i = 2:length(Discrete_blocks)
    all_blk_type{end+1} = Discrete_blocks{i};
end
for i = 2:length(Continuous_blocks)
    all_blk_type{end+1} = Continuous_blocks{i};
end
for i = 2:length(Math_Operations_blocks)
    all_blk_type{end+1} = Math_Operations_blocks{i};
end
for i = 2:length(Sources_blocks)
    all_blk_type{end+1} = Sources_blocks{i};
end
% 加入if块
all_blk_type{end+1} ='simulink/Ports & Subsystems/If';
% 过滤操作
all_blk_type(strcmp(all_blk_type,'Outport'))=[];
all_blk_type(strcmp(all_blk_type,'SubSystem'))=[];
all_blk_type(strcmp(all_blk_type,'To Workspace'))=[];
all_blk_type(strcmp(all_blk_type,'From↵Workspace'))=[];
all_blk_type(strcmp(all_blk_type,'To File'))=[];
all_blk_type(strcmp(all_blk_type,'ActionPort'))=[];
all_blk_type(strcmp(all_blk_type,'S-Function'))=[];
all_blk_type(strcmp(all_blk_type,'From Function'))=[];
all_blk_type(strcmp(all_blk_type,'From↵File'))=[];
all_blk_type(strcmp(all_blk_type,'Delay'))=[];
all_blk_type = all_blk_type';
for i=1:length(all_blk_type)
    if contains(all_blk_type{i},'nzb')
        all_blk_type{i}=[];
        continue;
    end
    if contains(all_blk_type{i},'Delay')
        all_blk_type{i}=[];
        continue;
    end
    if contains(all_blk_type{i},'State-Space')
        all_blk_type{i}=[];
        continue;
    end
    if contains(all_blk_type{i},'First Order Hold')
        all_blk_type{i}=[];
        continue;
    end
    if contains(all_blk_type{i},'PID')
        all_blk_type{i}=[];
        continue;
    end
    if contains(all_blk_type{i},'Integrator')
        all_blk_type{i}=[];
        continue;
    end
    if contains(all_blk_type{i},'Derivative')
        all_blk_type{i}=[];
        continue;
    end
    if contains(all_blk_type{i},'Memory')
        all_blk_type{i}=[];
        continue;
    end
    if contains(all_blk_type{i},'Descriptor State-Space')
        all_blk_type{i}=[];
        continue;
    end
    if contains(all_blk_type{i},'Tapped')
        all_blk_type{i}=[];
        continue;
    end
    if contains(all_blk_type{i},'From')
        all_blk_type{i}=[];
        continue;
    end
    if contains(all_blk_type{i},'Editor')
        all_blk_type{i}=[];
        continue;
    end
    if contains(all_blk_type{i},'Enumerated')
        all_blk_type{i}=[];
        continue;
    end
    if contains(all_blk_type{i},'Complex')
        all_blk_type{i}=[];
        continue;
    end
    if contains(all_blk_type{i},'Find')
        all_blk_type{i}=[];
        continue;
    end
    if contains(all_blk_type{i},'Concate')
        all_blk_type{i}=[];
        continue;
    end
    if contains(all_blk_type{i},'Entity')
        all_blk_type{i}=[];
        continue;
    end
    if contains(all_blk_type{i},'Transport')
        all_blk_type{i}=[];
        continue;
    end
    if contains(all_blk_type{i},'Zero-Pole')
        all_blk_type{i}=[];
        continue;
    end
    if contains(all_blk_type{i},'Transfer')
        all_blk_type{i}=[];
        continue;
    end
    if contains(all_blk_type{i},'Descriptor State-Space')
        all_blk_type{i}=[];
        continue;
    end
end
all_blk_type(cellfun(@isempty,all_blk_type))=[];
end