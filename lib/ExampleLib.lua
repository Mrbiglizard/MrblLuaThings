local function ExampleLib()
    local function Test()
        return true
    end
    return {Test = Test}
end
return {ExampleLib = ExampleLib}