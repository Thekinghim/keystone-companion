local _, KeystoneCompanion = ...

KeystoneCompanion.widgets = KeystoneCompanion.widgets or {}

-- maybe use this file for mixins later that add basic functionality to all custom frame templates
KeystoneCompanion.widgets.Base = {}

---@param ... table
---@return table
KeystoneCompanion.widgets.Base.mixTables = function(...)
    local mixed = {}
    for _, tbl in pairs({ ... }) do
        if type(tbl) == "table" then
            Mixin(mixed, tbl)
        end
    end
    return mixed
end
