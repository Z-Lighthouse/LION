function sys_close( sys )
%SYS_CLOSE Closes a model

if covcfg.CLOSE_MODELS
try
 bdclose(sys);
catch e
end
   
end

end

