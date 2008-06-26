def sort(config,data)
  return data.sort do|a,b|
    if(config==nil || config["method"] == nil)
      a <=> b
    else
      eval_pragger(config["method"],[a])[0] <=> eval_pragger(config["method"],[b])[0]
    end
  end
end

