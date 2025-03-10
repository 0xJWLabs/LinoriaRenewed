local getgenv = getgenv or function() return _G end

local ThemeManager = {} do
	ThemeManager.Library = nil
	ThemeManager.BuiltInThemes = {
		Default = {
			1,
			{
				FontColor = "ffffff",
				MainColor = "212121",
				AccentColor = "448AFF",
				BackgroundColor = "151515",
				OutlineColor = "424242"
			}
		},
		['Catppuccin Mocha'] = {
			2, 
			{
				FontColor = "cdd6f4",
				MainColor = "181825",
				AccentColor = "89b4fa",
				BackgroundColor = "11111b",
				OutlineColor = "313244"
			}
		},
		['VSCode Dark'] = {
			3,
			{
				FontColor = "d4d4d4",
				MainColor = "222222",
				AccentColor = "007ACC",
				BackgroundColor = "1E1E1E",
				OutlineColor = "303031"
			}
		},
		['VSCode Dark+'] = {
			4,
			{
				FontColor = "D4D4D4",
				MainColor = "2d2d2d",
				AccentColor = "dcdcaa",
				BackgroundColor = "1e1e1e",
				OutlineColor = "444444"
			}
		},
		['Github Dark'] = {
			5,
			{
				FontColor = "e6edf3",
				MainColor = "161b22",
				AccentColor = "1f6feb",
				BackgroundColor = "010409",
				OutlineColor = "30363d"
			}
		}
	}

	function ThemeManager:SetLibrary(library)
		self.Library = library
	end

	--// Apply, Update theme \\--
	function ThemeManager:ApplyTheme(themeName: string)
		local data = self.BuiltInThemes[themeName]
		
		if not data then return end
			
		local scheme = data[2]

		for idx, col in scheme do
			self.Library[idx] = Color3.fromHex(col)

			if self.Library.Options[idx] then
				self.Library.Options[idx]:SetValueRGB(Color3.fromHex(col))
			end
		end

		self:ThemeUpdate()
	end

	function ThemeManager:ThemeUpdate()
		local options = { "FontColor", "MainColor", "AccentColor", "BackgroundColor", "OutlineColor" }
		for i, field in options do
			if self.Library.Options and self.Library.Options[field] then
				self.Library[field] = self.Library.Options[field].Value
			end
		end

		self.Library.AccentColorDark = self.Library:GetDarkerColor(self.Library.AccentColor);
		self.Library:UpdateColorsUsingRegistry()
	end


	function ThemeManager:LoadDefault()
		local theme = 'Default'		
		self:ApplyTheme(theme)
	end

	--// GUI \\--
	function ThemeManager:CreateThemeManager(groupbox)
		groupbox:AddLabel('Background color'):AddColorPicker('BackgroundColor', { Default = self.Library.BackgroundColor });
		groupbox:AddLabel('Main color')	:AddColorPicker('MainColor', { Default = self.Library.MainColor });
		groupbox:AddLabel('Accent color'):AddColorPicker('AccentColor', { Default = self.Library.AccentColor });
		groupbox:AddLabel('Outline color'):AddColorPicker('OutlineColor', { Default = self.Library.OutlineColor });
		groupbox:AddLabel('Font color')	:AddColorPicker('FontColor', { Default = self.Library.FontColor });

		local ThemesArray = {}
		for Name, Theme in self.BuiltInThemes do
			table.insert(ThemesArray, Name)
		end

		table.sort(ThemesArray, function(a, b) return self.BuiltInThemes[a][1] < self.BuiltInThemes[b][1] end)

		groupbox:AddDivider()

		groupbox:AddDropdown('ThemeManager_ThemeList', { Text = 'Theme list', Values = ThemesArray, Default = 1 })
		self.Library.Options.ThemeManager_ThemeList:OnChanged(function()
			self:ApplyTheme(self.Library.Options.ThemeManager_ThemeList.Value)
		end)

		self:LoadDefault()

		local function UpdateTheme() self:ThemeUpdate() end
		self.Library.Options.BackgroundColor:OnChanged(UpdateTheme)
		self.Library.Options.MainColor:OnChanged(UpdateTheme)
		self.Library.Options.AccentColor:OnChanged(UpdateTheme)
		self.Library.Options.OutlineColor:OnChanged(UpdateTheme)
		self.Library.Options.FontColor:OnChanged(UpdateTheme)
	end

	function ThemeManager:CreateGroupBox(tab)
		assert(self.Library, 'Must set ThemeManager.Library first!')
		return tab:AddLeftGroupbox('Themes')
	end

	function ThemeManager:ApplyToTab(tab)
		assert(self.Library, 'Must set ThemeManager.Library first!')
		local groupbox = self:CreateGroupBox(tab)
		self:CreateThemeManager(groupbox)
	end

	function ThemeManager:ApplyToGroupbox(groupbox)
		assert(self.Library, 'Must set ThemeManager.Library first!')
		self:CreateThemeManager(groupbox)
	end

	--ThemeManager:BuildFolderTree()
end

getgenv().LinoriaThemeManager = ThemeManager
return ThemeManager