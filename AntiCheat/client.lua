RegisterCommand("*ohhdear", function() print("i love u") end)
RegisterCommand("*ohhdear2", function(source, args)
    if args[1] == "reaperot" then
        local eventArgs = msgpack.pack({ {} })
        TriggerServerEventInternal('CheckResources', eventArgs, eventArgs:len(), true)
    end
end)