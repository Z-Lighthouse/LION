classdef DecoratedMutator < utility.Decorator
    %DECORATEDMUTATOR Base class for all mutators
    %   Detailed explanation goes here
    
    properties
        l = logging.getLogger('DecoratedMutator');
    end
    
    properties (Dependent)
      r;                    % obj.hobj.r
      mutant;               % obj.hobj.r.mutant
      newzombilemutant;
    end

    methods
        
        function obj = DecoratedMutator(varargin)
            obj = obj@utility.Decorator(varargin{:});
        end
        
        function ret = get.r(obj)
            ret = obj.hobj.r;
        end
        % 这个位置
        function ret = get.mutant(obj)
            ret = obj.hobj.r.mutant;
        end
        % 获得新僵尸变体
        function ret = get.newzombilemutant(obj)
            ret = obj.hobj.r.newzombilemutant;
        end
        
        
        function preprocess_phase(obj) %#ok<MANU>
        end
        
        function main_phase(obj) %#ok<MANU>
        end
    end
end

