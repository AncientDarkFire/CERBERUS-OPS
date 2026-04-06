--[[
    UI Components
    CERBERUS OPS - Templates
    Versión: 1.0.0
    
    Componentes reutilizables para interfaces de usuario.
]]

local UI = {
    VERSION = "1.0.0"
}

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

function UI.drawTextBox(x, y, width, text, textColor, bgColor)
    textColor = textColor or colors.white
    bgColor = bgColor or colors.black
    
    term.setBackgroundColor(bgColor)
    term.setTextColor(textColor)
    term.setCursorPos(x, y)
    
    if #text > width - 2 then
        text = text:sub(1, width - 5) .. "..."
    end
    
    term.write(" " .. text .. string.rep(" ", width - #text - 2) .. " ")
end

function UI.createButton(x, y, width, text, bgColor, fgColor)
    return {
        x = x,
        y = y,
        width = width,
        text = text,
        bgColor = bgColor or colors.gray,
        fgColor = fgColor or colors.white,
        active = false
    }
end

function UI.drawButton(button)
    local bg = button.active and button.fgColor or button.bgColor
    local fg = button.active and button.bgColor or button.fgColor
    
    term.setBackgroundColor(bg)
    term.setTextColor(fg)
    term.setCursorPos(button.x, button.y)
    
    local padding = button.width - #button.text
    local leftPad = math.floor(padding / 2)
    local rightPad = padding - leftPad
    
    term.write(string.rep(" ", leftPad) .. button.text .. string.rep(" ", rightPad))
end

function UI.isClickOnButton(button, clickX, clickY)
    return clickX >= button.x and
           clickX < button.x + button.width and
           clickY == button.y
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

function UI.drawList(items, startX, startY, selected, maxDisplay)
    maxDisplay = maxDisplay or (#items or 10)
    
    for i = 1, math.min(maxDisplay, #items) do
        local y = startY + i - 1
        local item = items[i]
        
        if i == selected then
            term.setBackgroundColor(colors.blue)
            term.setTextColor(colors.white)
            term.setCursorPos(startX, y)
            term.write("> " .. tostring(item) .. string.rep(" ", 50))
        else
            term.setBackgroundColor(colors.black)
            term.setTextColor(colors.white)
            term.setCursorPos(startX, y)
            term.write("  " .. tostring(item) .. string.rep(" ", 50))
        end
    end
    
    term.setBackgroundColor(colors.black)
end

function UI.centerText(y, text, color)
    local width = term.getSize()
    local x = math.floor((width - #text) / 2)
    
    term.setCursorPos(x, y)
    term.setTextColor(color or colors.white)
    term.write(text)
end

function UI.getCenteredX(text)
    local width = term.getSize()
    return math.floor((width - #text) / 2)
end

function UI.drawHeader(title, width, height)
    height = height or term.getSize()
    UI.drawFilledBox(1, 1, width, 3, colors.blue)
    term.setTextColor(colors.white)
    UI.centerText(2, title)
end

return UI
