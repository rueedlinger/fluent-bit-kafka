local counter = 0
local random = math.random
math.randomseed(os.time())

-- https://gist.github.com/jrus/3197011
local function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

function generate_audit_msg(tag, timestamp, record)
    counter = counter + 1
    local new_record = record
    new_record["counter"] = counter
    new_record["id"] = uuid()
    new_record["source"] = tag
    new_record["ts"] = os.date("!%Y-%m-%dT%TZ")
    return 1, timestamp, record
end