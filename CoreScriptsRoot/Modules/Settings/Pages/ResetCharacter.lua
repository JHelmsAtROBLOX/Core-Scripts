--[[
		Filename: ResetCharacter.lua
		Written by: jeditkacheff
		Version 1.0
		Description: Takes care of the reseting the character in Settings Menu
--]]

-------------- CONSTANTS -------------
local RESET_CHARACTER_GAME_ACTION = "ResetCharacterAction"

-------------- SERVICES --------------
local CoreGui = game:GetService("CoreGui")
local ContextActionService = game:GetService("ContextActionService")
local RobloxGui = CoreGui:WaitForChild("RobloxGui")
local GuiService = game:GetService("GuiService")

----------- UTILITIES --------------
local utility = require(RobloxGui.Modules.Settings.Utility)

------------ Variables -------------------
local PageInstance = nil
RobloxGui:WaitForChild("Modules"):WaitForChild("TenFootInterface")
local isTenFootInterface = require(RobloxGui.Modules.TenFootInterface):IsEnabled()

----------- CLASS DECLARATION --------------

local function Initialize()
	local settingsPageFactory = require(RobloxGui.Modules.Settings.SettingsPageFactory)
	local this = settingsPageFactory:CreateNewPage()

	this.DontResetCharFunc = function(name, state, input)
		if this.HubRef and (not state or state == Enum.UserInputState.Begin) then
			this.HubRef:PopMenu()
		end
	end
	
	------ TAB CUSTOMIZATION -------
	this.TabHeader = nil -- no tab for this page

	------ PAGE CUSTOMIZATION -------
	this.Page.Name = "ResetCharacter"

	local resetCharacterText =  utility:Create'TextLabel'
	{
		Name = "ResetCharacterText",
		Text = "Are you sure you want to reset your character?",
		Font = Enum.Font.SourceSansBold,
		FontSize = Enum.FontSize.Size36,
		TextColor3 = Color3.new(1,1,1),
		BackgroundTransparency = 1,
		Size = UDim2.new(1,0,0,200),
		TextWrapped = true,
		ZIndex = 2,
		Parent = this.Page
	};
	if utility:IsSmallTouchScreen() then
		resetCharacterText.FontSize = Enum.FontSize.Size24
		resetCharacterText.Size = UDim2.new(1,0,0,100)
	end

	------ Init -------
	local resetCharFunc = function()
		local player = game.Players.LocalPlayer
		if player then
			local character = player.Character
			if character then
				local humanoid = character:FindFirstChild('Humanoid')
				if humanoid then
					humanoid.Health = 0
				end
			end
		end

		if this.HubRef then
			this.HubRef:SetVisibility(false)
		end
	end

	local buttonSpacing = 20
	local buttonSize = UDim2.new(0, 200, 0, 50)
	if isTenFootInterface then
		resetCharacterText.Position = UDim2.new(0,0,0,100)
		buttonSize = UDim2.new(0, 300, 0, 80)
	end

	this.ResetCharacterButton = utility:MakeStyledButton("ResetCharacter", "Reset", buttonSize, resetCharFunc)
	this.ResetCharacterButton.NextSelectionRight = nil
	if utility:IsSmallTouchScreen() then
		this.ResetCharacterButton.Position = UDim2.new(0.5, -buttonSize.X.Offset - buttonSpacing, 1, 0)
	else
		this.ResetCharacterButton.Position = UDim2.new(0.5, -buttonSize.X.Offset - buttonSpacing, 1, -30)
	end
	this.ResetCharacterButton.Parent = resetCharacterText


	local dontResetCharacterButton = utility:MakeStyledButton("DontResetCharacter", "Don't Reset", buttonSize, this.DontResetCharFunc)
	dontResetCharacterButton.NextSelectionLeft = nil
	if utility:IsSmallTouchScreen() then
		dontResetCharacterButton.Position = UDim2.new(0.5, buttonSpacing, 1, 0)
	else
		dontResetCharacterButton.Position = UDim2.new(0.5, buttonSpacing, 1, -30)
	end
	dontResetCharacterButton.Parent = resetCharacterText

	this.Page.Size = UDim2.new(1,0,0,dontResetCharacterButton.AbsolutePosition.Y + dontResetCharacterButton.AbsoluteSize.Y)
	
	return this
end


----------- Public Facing API Additions --------------
PageInstance = Initialize()

PageInstance.Displayed.Event:connect(function()
	GuiService.SelectedCoreObject = PageInstance.ResetCharacterButton
	ContextActionService:BindCoreAction(RESET_CHARACTER_GAME_ACTION, PageInstance.DontResetCharFunc, false, Enum.KeyCode.ButtonB)
end)

PageInstance.Hidden.Event:connect(function()
	ContextActionService:UnbindCoreAction(RESET_CHARACTER_GAME_ACTION)
end)


return PageInstance