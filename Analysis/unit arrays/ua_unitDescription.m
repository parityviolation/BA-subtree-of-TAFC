function desc_str = ua_unitDescription(ua_temp)
desc_str = arrayfun(@(x) sprintf('%s %d',x.expt_name,x.assign),ua_temp,'UniformOutput',0);

