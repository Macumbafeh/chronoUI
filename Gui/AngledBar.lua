local Gui = chronoUI.Gui or {};
local AngledBar = Gui.AngledBar or {};
Gui.AngledBar = AngledBar;
chronoUI.Gui = Gui;

-- The size of the bar textures
local barWidth = 512;
-- The size of the small bar textures
local smallBarWidth = 438;

-- Creates an AngledBar and writes it to self.frame
-- name: The name of the AngledBar. Must be set if the user can place this frame
local function AngledBar_Create(self, name, creationParams)
    local foregroundColor = creationParams.foregroundColor;
    local backgroundColor = creationParams.backgroundColor;
    if creationParams.invertColors then
        foregroundColor = creationParams.backgroundColor;
        backgroundColor = creationParams.foregroundColor;
    end
    
    local barHeight = creationParams.barHeight;
    
    local f = Gui.makeFrame("Frame", barWidth, barHeight + 10, name, UIParent);
    f:SetMovable(true);
    f:SetFrameStrata("BACKGROUND");
    f:RegisterForDrag("LeftButton");
    f:SetScript("OnDragStart", f.StartMoving);
    f:SetScript("OnDragStop", f.StopMovingOrSizing);
    self.frame = f;
    
    local barTexture = creationParams.barTexture;
    local overlayTexture = creationParams.borderTexture;
    
    if creationParams.isShort then
        barTexture = barTexture.."-short";
        overlayTexture = overlayTexture.."-short";
    end
    
    if creationParams.flipBar then
        barTexture = barTexture.."-flipped";
        overlayTexture = overlayTexture.."-flipped";
    end

    
    f.background = Gui.makeTexture(self.frame, "BACKGROUND", barWidth, barHeight, barTexture, backgroundColor);
    f.background:SetPoint("CENTER", f);
    
    f.overlay = Gui.makeTexture(self.frame, "OVERLAY", barWidth, barHeight, overlayTexture, backgroundColor);
    f.overlay:SetPoint("RIGHT", f);
    f.overlay:SetVertexColor(0, 0, 0, 1);
    
    f.bar = Gui.makeTexture(self.frame, "BORDER", barWidth, barHeight, barTexture, backgroundColor);
    f.bar:SetPoint("RIGHT", f.background);
    f.bar:SetVertexColor(unpack(foregroundColor));
end

-- Creates and returns a new AngledBar
-- name: The name of the AngledBar. Must be set if the user can place this frame
-- creationParams.foregroundColor: The color of the foreground. Defaults to 0.129|0.129|0.129|1.000 (rgba)
-- creationParams.backgroundColor: The color of the background. Defaults to 0.498|0.000|0.000|1.000 (rgba)
-- creationParams.invertColors: Inverts the colors of the forground and the background. Defaults to false
-- creationParams.leftToRight: The bar grows from left to right. Defaults to false
-- creationParams.flipBar: Flips the bar horizontally. Defaults to false
-- creationParams.isShort: Uses the shorter bar texture if set. Defaults to false
-- creationParams.barTexture: The texture used for the bar. Defaults to "hp-bar"
-- creationParams.borderTexture: The texture used for the border. Defaults to "hp-bar-border"
-- creationParams.barHeight: The height of the bar. Defaults to 32
-- creationParams.enabled: Should this frame be shown? Defaults to true
function AngledBar:new(name, creationParams)
    local creationParams = creationParams or {};
    creationParams.foregroundColor = creationParams.foregroundColor or {0.129, 0.129, 0.129, 1.000};
    creationParams.backgroundColor = creationParams.backgroundColor or {0.498, 0.000, 0.000, 1.000};
    creationParams.barTexture = creationParams.barTexture or "hp-bar";
    creationParams.borderTexture = creationParams.borderTexture or "hp-bar-border";
    creationParams.barHeight = creationParams.barHeight or 32;
    
    local object = {
        leftToRightGrowth = creationParams.leftToRight,
        isShort = creationParams.isShort,
    };
    
    setmetatable(object, self);
    self.__index = self;
    
    AngledBar_Create(object, name, creationParams);
    
    if creationParams.enabled == false then
        object.frame:Hide();
    end
    
    return object;
end

-- Moves the bar to the given percentage
function AngledBar:SetBarPercentage(pct)
    local width = barWidth;
    local missing = 0;
    
    if self.isShort then
        width = smallBarWidth;
        missing = (barWidth - smallBarWidth) / barWidth;
    end
    
    local relativeWidth = width / barWidth;
    local newWidth = relativeWidth * (100 - pct) / 100 + missing;
    
    if self.leftToRightGrowth then
        newWidth = relativeWidth * pct / 100 + missing;
    end
    
    self.frame.bar:SetTexCoordModifiesRect(true);
    self.frame.bar:SetTexCoord(0, newWidth, 0, 1);
end

function AngledBar:ToggleDrag()
    if self.dragging then
        self.dragging = false;
        self.frame:SetBackdrop(nil);
        self.frame:EnableMouse(false);
    else
        self.dragging = true;
        self.frame:SetBackdrop( { 
            bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 16, 
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        });
        
        self.frame:SetBackdropColor(0,0,0,1);
        self.frame:EnableMouse(true);
    end
end
