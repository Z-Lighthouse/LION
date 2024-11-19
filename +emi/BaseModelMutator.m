classdef (Abstract) BaseModelMutator < handle
    %BASEMODELMUTATOR Mutates a single model to create k mutants
    %   Individual mutants are created by calling instances of
    %   BaseMutantGenerator implementations.
    % By default, does not do preprocessing. Assuming this is done by a
    % subclass.
    % Reporting:
    % During mutant genration: saving after every mutant

    properties
        result;

        exp_data;
        REPORT_DIR_FOR_THIS_MODEL;

        exp_no = []; % loop counter value of MAIN_LOOP
        model_data = []; % input

        sys;
        m_id;

        num_mutants;

        disable_saving_result = false; % e.g. during preprocessing
        dont_preprocess;

        l = logging.getLogger('emi.BaseModelMutator');

        % Aggregate data for the mutant generator

        block_data; % Data for each block

        dead;
        live;
        % 加入新僵尸块
        new_block_data;%僵尸块的
        newZombieBlock;
        compiled_types;
    end

    methods

        function obj = BaseModelMutator(exp_data, exp_no, model_data)
            % Constructor
            obj.exp_data = exp_data;

            obj.exp_data.exp_no = exp_no;
            obj.exp_no = exp_no;

            obj.model_data = model_data;

            % Whether to preprocess before mutant generation
            obj.dont_preprocess = emi.cfg.DONT_PREPROCESS;
        end

        function go(obj)

            assert(~isempty(obj.model_data));
            assert(~isempty(obj.exp_no));

            obj.save_random_number_generator_state();

            obj.init();

            if ~ obj.open_model()
                return;
            end

            original_model_backup = obj.backup_original_model();

            ret = false;

            try
                ret = obj.process_single_model(false);
            catch e
                obj.add_exception_in_result(e);
                utility.print_error(e, obj.l);
                obj.l.error('Error mutating single model!');
                % Don't rethrow or quit here... need to clean up and
                % reproduce next time (done by caller)
            end

            % Differential Testing

            try
                if ret
                    obj.run_difftest();
                end
            catch e
                obj.add_exception_in_result(e);
                utility.print_error(e, obj.l);
                obj.l.error('Error diff-testing single model!');
                % Don't rethrow or quit here... need to clean up and
                % reproduce next time (done by caller)
            end

            % Value of ret makes sense only for activities prior to
            % difftest, i.e. up to mutant creation.

            if ~ ret && emi.cfg.KEEP_ERROR_MUTANT_PARENT_OPEN
                obj.open_model(true);
            else
                obj.close_model();
            end

            obj.delete_original_backup(original_model_backup);
            % 最后要都关闭，否则不行！
            fclose('all');


        end

    end

    methods(Access = protected)

        %第一步
        function save_random_number_generator_state(~)
            if emi.cfg.RNG_SHUFFLE
                return;
            end

            % there may be a bug in this logic. we are updating the random
            % number state after every model in a list. But next time the
            % experiment would run, it would start with the first model. So
            % also save the model number?

            rng_state = rng; %#ok<NASGU>
            try
                save(emi.cfg.WS_FILE_NAME, emi.cfg.RNG_VARNAME_IN_WS, '-append');
            catch e
                obj.l.error('BaseModelMutator has something wrong with it');
            end
        end

        %第二步
        function init(obj)
            obj.model_data = table2struct(obj.model_data);
            obj.sys = obj.model_data.sys;
            obj.m_id = obj.model_data.m_id;

            obj.result = emi.ReportForModel(obj.exp_no, obj.m_id);
            obj.choose_num_mutants();

            % Open preprocessed version
            obj.load_preprocessed_version();

            % Create Directories
            obj.REPORT_DIR_FOR_THIS_MODEL = [obj.exp_data.REPORTS_BASE filesep int2str(obj.exp_no)];
            mkdir(obj.REPORT_DIR_FOR_THIS_MODEL);
        end

        %第四步
        function original_backup = backup_original_model(obj)
            original_backup = [];

            if ~ emi.cfg.DEBUG_SUBSYSTEM.isempty()
                original_backup = [obj.sys '_original'];
                obj.l.info('Keeping original model open for debugging mutants');
                save_system(obj.sys, [tempdir filesep original_backup]);
                open_system(original_backup);
            end
        end

        %最后一步
        function delete_original_backup(~, original_backup)
            if ~isempty(original_backup)
                bdclose(original_backup);
                delete([tempdir filesep original_backup '.slx']);
            end
        end

        function choose_num_mutants(obj, varargin)
            if nargin == 1
                obj.num_mutants = emi.cfg.MUTANTS_PER_MODEL;
            else
                obj.num_mutants = varargin{1};
            end
            obj.result.mutants = cell(obj.num_mutants, 1);
        end

        function add_exception_in_result(obj, e)
            obj.l.error(['Exception: ' e.identifier]);
            obj.result.exception = true;
            obj.result.exception_ob = e;
            obj.result.exception_id = e.identifier;
        end

        function load_preprocessed_version(obj)
            %%
            if ~ obj.dont_preprocess
                return
            end

            preprocessed_file_name = emi.slsf.get_pp_file(obj.sys,...
                obj.model_data.loc_input, obj.model_data.sys_ext);

            obj.sys = preprocessed_file_name;
        end

        % 第三步
        function opens = open_model(obj, varargin)
            %%
            % varargin{1}: boolean: whether to use open_system by force.

            if nargin > 1
                use_open_system = varargin{1};
            else
                use_open_system = false;
            end

            opens = true;
            addpath(obj.model_data.loc_input);

            try
                emi.open_or_load_model(obj.sys, use_open_system);
            catch e
                opens = false;
                obj.l.error('Model did not open');
                obj.add_exception_in_result(e);
            end

            obj.result.opens = opens;
            rmpath(obj.model_data.loc_input);
        end

        %第五步
        function ret = process_single_model(obj, return_after_preprocess)
            %% return_after_preprocess is set to true by ModelPreprocessor
            obj.aggregate_data_for_mutant_generator();

            ret = obj.create_mutants(return_after_preprocess);
        end

        function save_rng_before_mutant_create(obj)
            %% Saves random number state before creating each mutant

            assert(emi.cfg.MUTANTS_PER_MODEL == 1, 'Feature not available');

            seed_id = obj.m_id;  %#ok<NASGU>
            rng_state = rng;  %#ok<NASGU>

            save(...
                [obj.REPORT_DIR_FOR_THIS_MODEL filesep emi.cfg.MUTANT_RNG_FILENAME],...
                'rng_state', 'seed_id'...
                );
        end
        %第五步之后还有一个在这
        function ret = create_mutants(obj, return_after_preprocess)
            %% return_after_preprocess is set to true by ModelPreprocessor
            ret = true;

            for i=1:obj.num_mutants
                obj.open_model();

                if ~ return_after_preprocess
                    obj.save_rng_before_mutant_create();
                end

                a_mutant = emi.SimpleMutantGenerator(...
                    emi.cfg.MUTATOR_DECORATORS,...
                    i, obj.sys, obj.exp_data,...
                    obj.REPORT_DIR_FOR_THIS_MODEL,...
                    return_after_preprocess,...
                    obj.dont_preprocess,...
                    obj.block_data,...
                    obj.compiled_types,...
                    obj.dead,...
                    obj.live,...
                    obj.new_block_data,...
                    obj.newZombieBlock...
                    );

                a_mutant.go()

                obj.end_mutant_callback(a_mutant);

                obj.result.mutants{i} = a_mutant.r.get_report();

                % Saving after every mutant
                obj.save_my_result();

                if ~ a_mutant.r.is_ok
                    obj.l.error('Breaking from mutant gen loop due to error');
                    ret = false;
                    break;
                end

                delete(a_mutant);
                clear a_mutant;
            end
        end

        %第六步
        function run_difftest(obj)
            %%

            if ~ emi.cfg.RUN_DIFFTEST
                return;
            end

            obj.result.difftest_ran = true;

            obj.l.info('--- Preparing to run DIFFERENTIAL TESTING --');

            % Append baseline model before all valid mutants

            T = [{struct('sys', obj.sys, 'loc', obj.model_data.loc_input)},...
                obj.result.valid_mutants()];

            % Create Differential tester

            locs = cellfun(@(p)p.loc, T, 'UniformOutput', false);
            models = cellfun(@(p)p.sys, T, 'UniformOutput', false);

            cellfun(@addpath,locs,'UniformOutput', false);

            e = [];

            try
                dt = difftest.BaseTester(models,...
                    locs,...
                    emi.cfg.SUT_CONFIGS);

                dt.go(true, emi.cfg.COMPARATOR);

                obj.result.difftest_r = dt.r.get_report();

                delete(dt);
                clear dt;

                obj.handle_difftest_errors(models);
            catch e
                disp(e); % For debugging
            end

            cellfun(@rmpath,locs,'UniformOutput', false);

            obj.save_my_result();

            try
                Simulink.sdi.clear();
            catch me
                obj.l.error('SDI threw error during clear');
                utility.print_error(me);
            end

            if ~isempty(e)
                rethrow(e);
            end

            obj.l.info('--- DIFFTEST DONE! ---');
        end

        function handle_difftest_errors(obj, models)
            %% DiffTest error occured. Re-open models for investigation
            if obj.result.difftest_ok() || ~ emi.cfg.KEEP_ERROR_MUTANT_PARENT_OPEN
                return;
            end

            cellfun(@(p)emi.open_or_load_model(p, true), models);
        end


        function end_mutant_callback(obj, mutant) %#ok<INUSD>
            %% Do something with the mutant -- for subclasses
        end
        %死块的认定在这
        function aggregate_data_for_mutant_generator(obj)
            %% bad name aggregate. Actually fetches data before mutation
            function x = get_nonempty(x)
                x = x(rowfun(@(p) ~isempty(p) , x,...
                    'InputVariables', {'percentcov'}, 'ExtractCellContents', true,...
                    'OutputFormat', 'uniform'), :);
            end
            % 新僵尸块
            function x = get_nonemptyfornewzombile(x)
                x = x(rowfun(@(p) ~isempty(p) , x,...
                    'InputVariables', {'percent_dec_cov'}, 'ExtractCellContents', true,...
                    'OutputFormat', 'uniform'), :);
            end

            function x = remove_model_names(x)
                % remove model name from the blocks
                x(:, 'fullname') = cellfun(@(p) utility.strip_first_split(...
                    p, '/', '/') ,x{:, 'fullname'}, 'UniformOutput', false);
            end

            blocks = struct2table(obj.model_data.blocks);
            % 去除了[]的块
            blocks = get_nonempty(blocks);
            % 去除了开头的名字
            blocks = remove_model_names(blocks);
            obj.block_data = blocks;

            %             if ~iscell(blocks)
            %                 blocks = table2cell(blocks);
            %             end
            deads = cellfun(@(p) p ==0 ,blocks{:,'percentcov'});
            lives = ~deads;

            lives(1) = false; % skip the first one which is the model itself

            obj.dead = blocks(deads, :);
            obj.live = blocks(lives, :);

            % 加入新僵尸块定义
            newblocks = struct2table(obj.model_data.blocks);
            % 去除了[]的块
            newblocks = get_nonemptyfornewzombile(newblocks);
            % 去除了开头的名字
            newblocks = remove_model_names(newblocks);
            obj.new_block_data = newblocks;
            newzombileblocks = cellfun(@(p) p ~=100 ,newblocks{:,'percent_dec_cov'});
            %判断是否为空
            if ~isempty(newzombileblocks)
                newzombileblocks(1) = 0;
                obj.newZombieBlock = newblocks(newzombileblocks, :);
            end
            % compiled types
            obj.compiled_types = obj.model_data.datatypes;

        end

        function save_my_result(obj)
            %%
            if obj.disable_saving_result
                return;
            end

            modelreport = obj.result.get_report();  %#ok<NASGU>
            save([obj.REPORT_DIR_FOR_THIS_MODEL filesep...
                emi.cfg.REPORT_FOR_A_MODEL_FILENAME], emi.cfg.REPORT_FOR_A_MODEL_VARNAME);
        end


        function close_model(obj)
            %%
            emi.pause_interactive();
            bdclose(obj.sys);
        end
    end

end

