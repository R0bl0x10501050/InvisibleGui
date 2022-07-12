--// Written By: R0bl0x10501050

--// Do not copy, modify, redistribute, and/or sell.

-- -- -- -- -- -- -- -- -- --

--// Services

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")

--// Requires

--// Local Vars

local toolbar = plugin:CreateToolbar("Invisible GUI Detection")
local NewButton = toolbar:CreateButton("Open", "Open the scanning panel", "rbxassetid://4458901886")

local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,  -- Widget will be initialized in floating panel
	false,   -- Widget will be initially enabled
	false,  -- Don't override the previous enabled state
	350,    -- Default width of the floating window
	600,    -- Default height of the floating window
	350,    -- Minimum width of the floating window
	600     -- Minimum height of the floating window
)

local Widget = plugin:CreateDockWidgetPluginGui("InvisibleGUI", widgetInfo)
Widget.Title = "Invisible GUI Detection"

script.Parent:WaitForChild("ScreenGui").Frame.Parent = Widget

--// Global Vars

--// Local Functions

local function add(text: string)
	local clone = Widget.Frame.ResultsV3.DRAFT:Clone()
	clone.TextLabel.RichText = true
	clone.TextLabel.Text = text
	clone.Name = "NewWarn"
	clone.Parent = Widget.Frame.ResultsV3
	clone.Visible = true
end

-- -- -- -- -- -- -- -- -- --

--// Listeners

NewButton.Click:Connect(function()
	Widget.Enabled = not Widget.Enabled
	
	if Widget.Frame then
		for _, v in ipairs(Widget.Frame.ResultsV3:GetChildren()) do
			if v:IsA("GuiBase2d") and v.Name ~= "DRAFT" then
				v:Destroy()
			end
		end
	end
end)

--// Logic

Widget.Frame.TextButton.MouseButton1Click:Connect(function()
	for _, v in ipairs(Widget.Frame.ResultsV3:GetChildren()) do
		if v:IsA("GuiBase2d") and v.Name ~= "DRAFT" then
			v:Destroy()
		end
	end
	
	local inst = Selection:Get()[1]
	
	if not inst then
		add("Select an instance first (none currently selected)")
	end
	
	if not inst:IsA("GuiBase2d") then
		add("Select a valid instance first (must be a UI object)")
	end
	
	-- No SurfaceGui/BillboardGui support yet :(
	if inst:GetFullName():match("^StarterGui.*") == nil then
		add("Selected instance must be located under <b>game.StarterGui</b>")
	end
	
	if game.StarterGui.ShowDevelopmentGui == false then
		add("<b>game.StarterGui</b> has <b>ShowDevelopmentGui</b> set to <b>false</b>")
	end
	
	local parentInst = inst
	
	while parentInst and parentInst.Parent ~= game and not parentInst:IsA("ScreenGui") do
		if parentInst.Visible == false then
			add("<b>game." .. parentInst:GetFullName() .. "</b> has <b>Visible</b> set to <b>false</b>")
		end
		
		if parentInst.AbsoluteSize then
			if parentInst:IsA("Frame") then
				if parentInst.AbsoluteSize.X == 0 then
					add("<b>game." .. parentInst:GetFullName() .. "</b> has no length")
				end
				if parentInst.AbsoluteSize.Y == 0 then
					add("<b>game." .. parentInst:GetFullName() .. "</b> has no height")
				end
			else
				if parentInst.AbsoluteSize.X <= 10 then
					add("<b>game." .. parentInst:GetFullName() .. "</b> has little-to-no length")
				end
				if parentInst.AbsoluteSize.Y <= 10 then
					add("<b>game." .. parentInst:GetFullName() .. "</b> has little-to-no height")
				end
			end
		end
		
		if parentInst.Parent and parentInst.Parent ~= game and not parentInst.Parent:IsA("ScreenGui") then
			local parentParentInst = parentInst.Parent
			
			local parentCorners = {
				topLeft = {parentParentInst.AbsolutePosition.X, parentParentInst.AbsolutePosition.Y},
				topRight = {parentParentInst.AbsolutePosition.X + parentParentInst.AbsoluteSize.X, parentParentInst.AbsolutePosition.Y},
				bottomLeft = {parentParentInst.AbsolutePosition.X, parentParentInst.AbsolutePosition.Y + parentParentInst.AbsoluteSize.Y},
				bottomRight = {parentParentInst.AbsolutePosition.X + parentParentInst.AbsoluteSize.X, parentParentInst.AbsolutePosition.Y + parentParentInst.AbsoluteSize.Y}
			}
			
			local childCorners = {
				topLeft = {parentInst.AbsolutePosition.X, parentInst.AbsolutePosition.Y},
				topRight = {parentInst.AbsolutePosition.X + parentInst.AbsoluteSize.X, parentInst.AbsolutePosition.Y},
				bottomLeft = {parentInst.AbsolutePosition.X, parentInst.AbsolutePosition.Y + parentInst.AbsoluteSize.Y},
				bottomRight = {parentInst.AbsolutePosition.X + parentInst.AbsoluteSize.X, parentInst.AbsolutePosition.Y + parentInst.AbsoluteSize.Y}
			}
			
			local viewportGui = game.StarterGui:FindFirstChildOfClass("ScreenGui")
			if not viewportGui then
				viewportGui = Instance.new("ScreenGui")
				viewportGui.Name = "InvisibleGui_TestViewport"
				viewportGui.Parent = game.StarterGui
			end
			local viewportSize = viewportGui.AbsoluteSize
			
			if childCorners.topLeft[1] < 0 and childCorners.topRight[1] < 0 and childCorners.bottomLeft[1] < 0 and childCorners.bottomRight[1] < 0 then
				add("<b>game." .. parentInst:GetFullName() .. "</b> corners are too far left (below 0)")
			elseif childCorners.topLeft[1] > viewportSize.X and childCorners.topRight[1] > viewportSize.X and childCorners.bottomLeft[1] > viewportSize.X and childCorners.bottomRight[1] > viewportSize.X then
				add("<b>game." .. parentInst:GetFullName() .. "</b> corners are too far right (above max)")
			end
			if childCorners.topLeft[2] < 0 and childCorners.topRight[2] < 0 and childCorners.bottomLeft[2] < 0 and childCorners.bottomRight[2] < 0 then
				add("<b>game." .. parentInst:GetFullName() .. "</b> corners are too far up (below 0)")
			elseif childCorners.topLeft[2] > viewportSize.Y and childCorners.topRight[2] > viewportSize.Y and childCorners.bottomLeft[2] > viewportSize.Y and childCorners.bottomRight[2] > viewportSize.Y then
				add("<b>game." .. parentInst:GetFullName() .. "</b> corners are too far down (above max)")
			end
			
			if parentInst.Parent and parentInst.Parent:IsA("GuiBase2d") and parentInst.Parent.ClipsDescendants == true then
				for k, v in pairs(parentCorners) do
					if childCorners.topLeft[1] < v[1] and childCorners.topRight[1] < v[1] and childCorners.bottomLeft[1] < v[1] and childCorners.bottomRight[1] < v[1] then
						add("<b>game." .. parentInst:GetFullName() .. "</b> corners are too far left and <b>game." .. parentParentInst:GetFullName() .. "</b> has <b>ClipsDescendants</b> set to <b>true</b>")
					elseif childCorners.topLeft[1] > v[1] and childCorners.topRight[1] > v[1] and childCorners.bottomLeft[1] > v[1] and childCorners.bottomRight[1] > v[1] then
						add("<b>game." .. parentInst:GetFullName() .. "</b> corners are too far right and <b>game." .. parentParentInst:GetFullName() .. "</b> has <b>ClipsDescendants</b> set to <b>true</b>")
					end
					if childCorners.topLeft[2] < v[2] and childCorners.topRight[2] < v[2] and childCorners.bottomLeft[2] < v[2] and childCorners.bottomRight[2] < v[2] then
						add("<b>game." .. parentInst:GetFullName() .. "</b> corners are too far up and <b>game." .. parentParentInst:GetFullName() .. "</b> has <b>ClipsDescendants</b> set to <b>true</b>")
					elseif childCorners.topLeft[2] > v[2] and childCorners.topRight[2] > v[2] and childCorners.bottomLeft[2] > v[2] and childCorners.bottomRight[2] > v[2] then
						add("<b>game." .. parentInst:GetFullName() .. "</b> corners are too far down and <b>game." .. parentParentInst:GetFullName() .. "</b> has <b>ClipsDescendants</b> set to <b>true</b>")
					end
				end
			end
		end
		
		parentInst = parentInst.Parent
	end
end)
