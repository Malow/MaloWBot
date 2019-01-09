MBV_RPS_AVERAGE_PERIOD = 1
MBV_MAX_REQUESTS = 23

mbv_lastRpsUpdateTime = 0
mbv_rpsCount = 0
mbv_previousRpsCount = 0
mbv_previousPreviousRpsCount = 0
function mbv_UpdateRPS()
    if mbv_lastRpsUpdateTime + MBV_RPS_AVERAGE_PERIOD > GetTime() then
        return
    end
    mbv_lastRpsUpdateTime = GetTime()
    local value = (mbv_rpsCount + mbv_previousRpsCount + mbv_previousPreviousRpsCount) / (MBV_RPS_AVERAGE_PERIOD * 3)
    MaloWBotVisualizerFrame_RpsText:SetText("RPS: " .. math.floor(value * 100) / 100)
    mbv_previousPreviousRpsCount = mbv_previousRpsCount
    mbv_previousRpsCount = mbv_rpsCount
    mbv_rpsCount = 0
end

function mbv_OnUpdate()
    mbv_UpdateRPS()
end

function mbv_OnEvent()
    if event == "CHAT_MSG_ADDON" and arg1 == "MB" then
        mbv_NewEvent(arg4, arg2)
    end
end

function mbv_NewEvent(from, text)
    mbv_rpsCount = mbv_rpsCount + 1
    if MaloWBotVisualizerFrame.bars == nil then
        MaloWBotVisualizerFrame.bars = {}
        for i = 1, MBV_MAX_REQUESTS do
            table.insert(MaloWBotVisualizerFrame.bars, mbv_CreateBar(i * -12))
        end
    end

    for i = MBV_MAX_REQUESTS, 2, -1 do
        if MaloWBotVisualizerFrame.bars[i - 1]:IsShown() then
            MaloWBotVisualizerFrame.bars[i].leftText:SetText(MaloWBotVisualizerFrame.bars[i - 1].leftText:GetText())
            MaloWBotVisualizerFrame.bars[i]:SetStatusBarColor(MaloWBotVisualizerFrame.bars[i - 1]:GetStatusBarColor())
            MaloWBotVisualizerFrame.bars[i]:Show()
        end
    end
    MaloWBotVisualizerFrame.bars[1].leftText:SetText(from .. " - " .. text)
    local class = max_GetClass(max_GetUnitForPlayerName(from))
    MaloWBotVisualizerFrame.bars[1]:SetStatusBarColor(mbv_GetClassColor(class))
    MaloWBotVisualizerFrame.bars[1]:Show()
end

function mbv_CreateBar(yOffset)
    local bar = CreateFrame("StatusBar", nil, MaloWBotVisualizerFrame);
    bar:SetFrameStrata("MEDIUM")
    bar:SetPoint("TOP", MaloWBotVisualizerFrame, "TOP", 0, -8 + yOffset)
    bar:SetWidth(300)
    bar:SetHeight(12)
    bar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
    bar:SetStatusBarColor(0.3, 0.7, 0.3)
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(1)
    bar.bg = bar:CreateTexture(nil, "BACKGROUND")
    bar.bg:SetTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
    bar.bg:SetAllPoints(true)
    bar.bg:SetVertexColor(0.2, 0.2, 0)

    bar.leftText = bar:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    bar.leftText:SetAllPoints(true)
    bar.leftText:SetJustifyH("LEFT")
    bar.leftText:SetPoint("TOPLEFT", bar, "TOPLEFT", 3, 0)
    bar.leftText:SetTextColor(1, 1, 1, 1)
    bar.leftText:SetText("")

    bar.rightText = bar:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    bar.rightText:SetAllPoints(true)
    bar.rightText:SetJustifyH("LEFT")
    bar.rightText:SetPoint("TOPLEFT", bar, "TOPLEFT", 3, 0)
    bar.rightText:SetTextColor(1, 1, 1, 1)
    bar.rightText:SetText("")

    bar:Hide()
    return bar
end

function mbv_GetClassColor(class)
    if class == "DRUID" then
        return 1.0, 0.49, 0.04
    elseif class == "HUNTER" then
        return 0.67, 0.83, 0.45
    elseif class == "MAGE" then
        return 0.25, 0.78, 0.82
    elseif class == "PALADIN" then
        return 0.96, 0.55, 0.73
    elseif class == "PRIEST" then
        return 1.0, 1.0, 1.0
    elseif class == "ROGUE" then
        return 1.0, 0.96, 0.41
    elseif class == "WARLOCK" then
        return 0.53, 0.53, 0.93
    elseif class == "WARRIOR" then
        return 0.78, 0.61, 0.43
    end
end