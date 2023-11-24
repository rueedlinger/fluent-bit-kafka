local function copy_value_when_exists(record, new_record, key, default)
    if record[key]  ~= nil then
        new_record[key] = record[key]
    else
        if default ~= nil then
            new_record[key] = default
        end 
    end
end
  

function modify_kafka_message(tag, timestamp, record)
    local new_record = {}
    local audit = {}
    local meta = {}
    new_record["audit"] = audit
    new_record["meta"] = meta

    if record["payload"] ~= nil and type(record["payload"]) == "table" then
        copy_value_when_exists(record["payload"], audit, "id", nil)
        copy_value_when_exists(record["payload"], audit, "subject", "UNKNWON")
        copy_value_when_exists(record["payload"], audit, "process", "UNKNWON")
        copy_value_when_exists(record["payload"], audit, "message", nil)
        copy_value_when_exists(record["payload"], audit, "source", "UNKNWON")
        copy_value_when_exists(record["payload"], audit, "counter", nil)
        copy_value_when_exists(record["payload"], audit, "action", nil)
        -- YYYY-MM-DDTHH:mm:ss.sssZ
        copy_value_when_exists(record["payload"], audit, "ts", os.date("!%Y-%m-%dT%TZ"))
    else
        -- skip records which are not structured (json) or null
        return -1, 0, 0
    end

    local topic = record["topic"]
    local offset = record["offset"]
    local partition = record["partition"]
    meta["topic"] = topic
    meta["offset"] = offset
    meta["partition"] = partition
    meta["tag"] = tag

    -- set top level id
    if audit["id"] ~= nil then
        new_record["id"] = audit["id"]
    else
        -- fallback use kafka id
        new_record["id"] = topic ..  "-" .. partition .. "-" .. offset
    end
 
    return 1, timestamp, new_record
end
