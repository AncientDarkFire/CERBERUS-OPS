--[[
    UI Components
    CERBERUS OPS - Templates
    Versión: 2.0.0
]]

local UI = {}

function UI.drawBorder(x, y, width, height, color)
    color = color or colors.gray
    term.setBackgroundColor(color)
    
    term.setCursorPos(x, y)
    term.write("+" .. string.rep("-", width - 2) .. "+")
    
    for i = 2, height - 1 do
        term.setCursorPos(x, y + i - 1)
        term.write("|" .. string.rep(" ", width - 2) .. "|")
    end
    
    term.setCursorPos(x, y + height - 1)
    term.write("+" .. string.rep("-", width - 2) .. "+")
end

function UI.drawFilledBox(x, y, width, height, color)
    term.setBackgroundColor(color)
    for i = 0, height - 1 do
        term.setCursorPos(x, y + i)
        term.write(string.rep(" ", width))
    end
end

function UI.drawProgressBar(x, y, width, progress, filledColor, emptyColor)
    filledColor = filledColor or colors.green
    emptyColor = emptyColor or colors.gray
    
    term.setCursorPos(x, y)
    term.write("[")
    
    local filledWidth = math.floor(progress * (width - 2))
    local emptyWidth = (width - 2) - filledWidth
    
    term.setBackgroundColor(filledColor)
    term.write(string.rep(" ", filledWidth))
    term.setBackgroundColor(emptyColor)
    term.write(string.rep(" ", emptyWidth))
    term.setBackgroundColor(colors.black)
    term.write("]")
end

function UI.centerText(y, text, color)
    local width = term.getSize()
    local x = math.floor((width - #text) / 2)
    term.setCursorPos(x, y)
    term.setTextColor(color or colors.white)
    term.write(text)
end

return UI
