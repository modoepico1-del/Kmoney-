-- ══════════════════════════════════════
--  ANTI RAGDOLL AVANZADO
-- ══════════════════════════════════════

local antiRagdollOn = false
local antiRagdollLabel, antiRagdollTrack, antiRagdollThumb = makeOptionRow(ContentArea, "ANTI RAGDOLL", 172)

local antiRagdollMode = nil
local ragdollConnections = {}
local cachedCharData = {}

local function cacheCharacterData()
    local char = me.Character
    if not char then return false end
    local hum  = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return false end
    cachedCharData = {
        character        = char,
        humanoid         = hum,
        root             = root,
        originalWalkSpeed = hum.WalkSpeed,
        originalJumpPower = hum.JumpPower,
        isFrozen         = false
    }
    return true
end

local function disconnectAllRagdoll()
    for _, conn in ipairs(ragdollConnections) do
        if typeof(conn) == "RBXScriptConnection" then
            pcall(function() conn:Disconnect() end)
        end
    end
    ragdollConnections = {}
end

local function isRagdolled()
    if not cachedCharData.humanoid then return false end
    local hum   = cachedCharData.humanoid
    local state = hum:GetState()
    if state == Enum.HumanoidStateType.Physics
    or state == Enum.HumanoidStateType.Ragdoll
    or state == Enum.HumanoidStateType.FallingDown then
        return true
    end
    local endTime = me:GetAttribute("RagdollEndTime")
    if endTime then
        local now = workspace:GetServerTimeNow()
        if (endTime - now) > 0 then return true end
    end
    return false
end

local function removeRagdollConstraints()
    if not cachedCharData.character then return end
    for _, descendant in ipairs(cachedCharData.character:GetDescendants()) do
        if descendant:IsA("BallSocketConstraint") or
           (descendant:IsA("Attachment") and descendant.Name:find("RagdollAttachment")) then
            pcall(function() descendant:Destroy() end)
        end
    end
end

local function forceExitRagdoll()
    if not cachedCharData.humanoid or not cachedCharData.root then return end
    local hum  = cachedCharData.humanoid
    local root = cachedCharData.root
    pcall(function()
        local now = workspace:GetServerTimeNow()
        me:SetAttribute("RagdollEndTime", now)
    end)
    if hum.Health > 0 then
        hum:ChangeState(Enum.HumanoidStateType.Running)
    end
    root.Anchored = false
    root.AssemblyLinearVelocity  = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
end

local function antiRagdollLoop()
    while antiRagdollMode do
        task.wait()
        if isRagdolled() then
            removeRagdollConstraints()
            forceExitRagdoll()
        end
        local cam = workspace.CurrentCamera
        if cam and cachedCharData.humanoid then
            if cam.CameraSubject ~= cachedCharData.humanoid then
                cam.CameraSubject = cachedCharData.humanoid
            end
        end
    end
end

local function toggleAntiRagdoll(enable)
    if enable then
        disconnectAllRagdoll()
        if not cacheCharacterData() then return end
        antiRagdollMode = "v1"
        local charConn = me.CharacterAdded:Connect(function()
            task.wait(0.5)
            if antiRagdollMode then cacheCharacterData() end
        end)
        table.insert(ragdollConnections, charConn)
        task.spawn(antiRagdollLoop)
    else
        antiRagdollMode = nil
        disconnectAllRagdoll()
        cachedCharData = {}
    end
end

antiRagdollTrack.MouseButton1Click:Connect(function()
    antiRagdollOn = not antiRagdollOn
    if antiRagdollOn then
        toggleOn(antiRagdollLabel, antiRagdollTrack, antiRagdollThumb)
        toggleAntiRagdoll(true)
    else
        toggleOff(antiRagdollLabel, antiRagdollTrack, antiRagdollThumb)
        toggleAntiRagdoll(false)
    end
end)
