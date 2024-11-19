function [sys,x0,str,ts,simStateCompliance] = recoverfunction(t,x,u,flag)

switch flag,

    case 0,
        [sys,x0,str,ts,simStateCompliance]=mdlInitializeSizes;

    case 1,
        sys=mdlDerivatives(t,x,u);

    case 2,
        sys=mdlUpdate(t,x,u);

    case 3,
        sys=mdlOutputs(t,x,u);

    case 4,
        sys=mdlGetTimeOfNextVarHit(t,x,u);


    case 9,
        sys=mdlTerminate(t,x,u);

    otherwise
        DAStudio.error('Simulink:blocks:unhandledFlag', num2str(flag));

end

    function [sys,x0,str,ts,simStateCompliance]=mdlInitializeSizes

        sizes = simsizes;

        sizes.NumContStates  = 0;
        sizes.NumDiscStates  = 0;
        sizes.NumOutputs     = 1;
        sizes.NumInputs      = 1;
        sizes.DirFeedthrough = 1;
        sizes.NumSampleTimes = 1;

        sys = simsizes(sizes);
        x0  = [];
        str = [];
        ts  = [0 0];
        simStateCompliance = 'UnknownSimState';
    end

    function sys=mdlDerivatives(t,x,u)

        sys = [];
    end

    function sys=mdlUpdate(t,x,u)

        sys = [];

    end
    function sys=mdlOutputs(t,x,u)
        sys = evalin('base','demo');
        %     if u<1
        %         sys = 3 * sqrt(u);
        %     elseif  u>=1 && u<3
        %         sys = 3;
        %     elseif  u>=3 && u<4
        %         sys = 3 -(u-3)^2;
        %     elseif  u>=4 && u<5
        %         sys = 2;
        %     elseif  u>=5 && u<6
        %         sys = 2 -(u-5)^2;
        %     else
        %         sys = 1;
        %     end
    end

    function sys=mdlGetTimeOfNextVarHit(t,x,u)

        sampleTime = 1;
        sys = t + sampleTime;
    end
    function sys=mdlTerminate(t,x,u)

        sys = [];

    end
end