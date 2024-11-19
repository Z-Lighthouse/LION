% 屏蔽警告
warning("off");
% 从最近的emi_report中获取到记录
l = logging.getLogger('emi_report');
f = fopen('expset/cresult.txt','w');
fwrite(f,'modelName  ');
fwrite(f,'deadblock_num  ');
fwrite(f,'liveblock_num  ');
fprintf(f,'\r\n');

report_loc = utility.get_latest_directory(emi.cfg.REPORTS_DIR);
if isempty(report_loc)
    l.warn('No direcotry found in %s', emi.cfg.REPORTS_DIR);
    return;
end
result_list = dir(report_loc);
resultNum={result_list.name};
% 设置需要记录的数据
% 1.成功生成变体数量
create_num = 0;
% 2.活区块数量
all_liveblock_num = 0;
% 3.死区块数量
all_deadblock_num = 0;
% 循环
for i = 1:(length(resultNum)-4)
    now = strcat(int2str(i),"/",int2str((length(resultNum)-4)));
    % 计数器
    disp(now);
    % 初始化参数
    deadblock_num = 0;
    liveblock_num = 0;
    try
        loc = strcat(report_loc,'/',int2str(i));
        list = dir(fullfile(loc,'*test.slx'));
        filename={list.name};
        % 计算成功生成变体的数量
        if numel(filename) == 0
            continue
        else
            create_num = create_num + 1;
        end
        % 运行并收集模型中活块和死块的数量
        slx_name = strcat(loc,'/',filename{1});
        load_system(slx_name);
        testObj = cvtest(slx_name);
        data = cvsim(testObj);
        blocks = find_system("Type","block");
        for num=1:length(blocks)
            cur_blk = blocks{num};
            cov = executioninfo(data, cur_blk);
            % 的确存在cov为空的情况，是按活块来算的
            if isempty(cov)
                liveblock_num = liveblock_num + 1;
                continue;
            else
                % 判断活死块
                percent_cov = 100 * cov(1) / cov(2);
                if percent_cov == 0
                    deadblock_num = deadblock_num + 1;
                else
                    liveblock_num = liveblock_num + 1;
                end
            end
        end
        % 关闭系统
        close_system(slx_name);
        % 录入File
        fwrite(f,filename{1});
        fprintf(f,'  ');
        fwrite(f,int2str(deadblock_num));
        fprintf(f,'  ');
        fwrite(f,int2str(liveblock_num));
        fprintf(f,'  ');
        fprintf(f,'\r\n');
    catch e
        disp(e.message);
    end
    all_liveblock_num = all_liveblock_num+ liveblock_num;
    all_deadblock_num = all_deadblock_num +deadblock_num;
end
% 录入File

fwrite(f,int2str(create_num));
fprintf(f,'  ');
fwrite(f,int2str(all_deadblock_num));
fprintf(f,'  ');
fwrite(f,int2str(all_liveblock_num));
fprintf(f,'  ');
fprintf(f,'\r\n');
fclose(f);


