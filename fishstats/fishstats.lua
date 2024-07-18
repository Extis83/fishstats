addon.name      = 'FishStats';
addon.author    = 'Extis';
addon.version   = '1.0';
addon.desc      = 'Displays fishing statistics in a separate window.';
addon.link      = 'https://github.com/Extis83/FishStats';

require('common');
local fonts = require('fonts');
local settings = require('settings');

local defaults = T{
    Font = T{
        visible = true,
        font_family = 'Arial',
        font_height = 16,
        color = 0xFFFFFFFF,
        position_x = 1,
        position_y = 1,
        background = T{
            visible = true,
            color = 0x80000000,
        }
    },
}

local state = {
    Active = false,
    StartTime = 0,  -- Tracks the time when the statistics window first appears
    Settings = settings.load(defaults),
    Casts = 0,
    Fish = 0,
    PercentFish = 0,
    Monsters = 0,
    Items = 0,
    Nothing = 0,
    FishPerHour = 0,
    LastActionTime = 0,  -- Tracks the time of the last valid fishing action
};

local hookMessages = {
    { message='Something caught the hook!!!', hook='Fish' },
    { message='Something caught the hook!', hook='Fish' },
    { message='You feel something pulling at your line.', hook='Item' },
    { message='Something clamps onto your line ferociously!', hook='Monster' },
    { message='You didn\'t catch anything.', hook='Nothing' },
};

settings.register('settings', 'settings_update', function (s)
    if (s ~= nil) then
        state.Settings = s;
    end

    settings.save();
end);

ashita.events.register('load', 'load_cb', function ()
    state.Font = fonts.new(state.Settings.Font);
end);

ashita.events.register('unload', 'unload_cb', function ()
    if (state.Font ~= nil) then
        state.Font:destroy();
        state.Font = nil;
    end
end);

ashita.events.register('text_in', 'FishStats_HandleText', function (e)
    if (e.injected == true) then
        return;
    end
    
    local incrementCasts = false;

    for _, entry in ipairs(hookMessages) do
        if (string.match(e.message, entry.message) ~= nil) then
            state.Casts = state.Casts + 1;
            incrementCasts = true;

            state.Active = true;  -- Set active to true on any fishing-related message
            if (state.Casts == 1) then
                state.StartTime = os.clock();  -- Start time is set on first cast
            end
            state.LastActionTime = os.clock(); -- Update last action time

           
            if entry.hook == 'Fish' then
                state.Fish = state.Fish + 1;
            elseif entry.hook == 'Monster' then
                state.Monsters = state.Monsters + 1;
            elseif entry.hook == 'Item' then
                state.Items = state.Items + 1;
            elseif entry.hook == 'Nothing' then
                state.Nothing = state.Nothing + 1;
            end

            if state.Casts > 0 then
                state.PercentFish = (state.Fish / state.Casts) * 100;
            end

            local elapsedTimeHours = (os.clock() - state.StartTime) / 3600;
            if elapsedTimeHours > 0 then
                state.FishPerHour = state.Fish / elapsedTimeHours;
            end

            break;
        end
    end
end);

ashita.events.register('d3d_present', 'FishStats_HandleRender', function ()
    local positionX = state.Font.position_x;
    local positionY = state.Font.position_y;
    if (positionX ~= state.Settings.Font.position_x) or (positionY ~= state.Settings.Font.position_y) then
        state.Settings.Font.position_x = positionX;
        state.Settings.Font.position_y = positionY;
        settings.save();        
    end

    -- Calculate elapsed time
    local elapsedTime = os.clock() - state.StartTime;
    local hours = math.floor(elapsedTime / 3600);
    local minutes = math.floor((elapsedTime % 3600) / 60);
    local seconds = math.floor(elapsedTime % 60);

    -- Check if window should be visible
    if state.Active and state.Casts > 0 and (os.clock() - state.LastActionTime <= 60) then
        state.Font.text = string.format(
            'Elapsed Time: %02d:%02d:%02d\nCasts: %d\nFish: %d\nPercent Fish: %.2f%%\nEstimated Fish per hour: %.2f\nMonsters: %d\nItems: %d\nNothing: %d\nTo clear type: /fishstats reset',
            hours, minutes, seconds, state.Casts, state.Fish, state.PercentFish, state.FishPerHour, state.Monsters, state.Items, state.Nothing
        );
        state.Font.visible = true;
    else
        state.Font.visible = false;
    end
end);

ashita.events.register('command', 'FishStats_CommandHandler', function (e)
    local args = e.command:args();
    if #args > 0 and args[1] == '/fishstats' then
        e.blocked = true;

        if #args == 2 and args[2] == 'reset' then
            state.Casts = 0;
            state.Fish = 0;
            state.Monsters = 0;
            state.Items = 0;
            state.Nothing = 0;
            state.PercentFish = 0;
            state.StartTime = 0;  -- Reset start time to 0
            state.FishPerHour = 0;
            state.Active = false; -- Ensure to set Active to false on reset
            state.LastActionTime = 0; -- Reset last action time
            
            print('Fishing statistics reset.');
        else
            print('Invalid command. Usage: /fishstats reset');
        end
    end
end);
