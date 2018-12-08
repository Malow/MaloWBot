function mb_GetConfig()
    local config = mb_GetPersonalizedConfig()
    if config["followTarget"] == nil then
        config["followTarget"] = "Malow"
    end
    return config
end