require "defines"

local config = require("config")

function movestack(src, dst, stack)
    stack.count = math.min(stack.count, src.get_item_count(stack.name))
    if stack.count <= 0 then return 0 end

    stack.count = dst.insert(stack)
    if stack.count <= 0 then return 0 end

    return src.remove(stack)
end

function trashexcess(player)
    local invmain = player.get_inventory(defines.inventory.player_main)
    local invtrash = player.get_inventory(defines.inventory.player_trash)

    for s = 1, player.force.character_logistic_slot_count do
        local request = player.character.get_request_slot(s)
        if request then
            local delta = player.get_item_count(request.name) - request.count
            movestack(invmain, invtrash, {name = request.name, count = delta})
        end
    end
end

script.on_event(defines.events.on_tick, function(evt)
    if evt.tick % config.trash_interval ~= 0 then return end

    for _, player in pairs(game.players) do
        if player.controller_type == defines.controllers.character then
            trashexcess(player)
        end
    end
end)
