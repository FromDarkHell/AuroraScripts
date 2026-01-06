scriptTitle = "Title Update Enabler"
scriptAuthor = "FDH"
scriptVersion = 1.0
scriptDescription = "Automatically enables all cached title updates"
scriptIcon = "icon.png"
scriptPermissions = { "sql" }

MainMenu = {
    "Enable All",
    "Disable All"
}

MainMenuOption_EnableAll = 1
MainMenuOption_DisableAll = 2

-- Main entry point to script
function main()
    ResetToMainMenu()
end

-- Return to start of the application
function ResetToMainMenu()
    -- Show Main Menu
    local selectedMenuOption = ShowMainMenu()

    if selectedMenuOption == MainMenuOption_EnableAll then
        EnableAllTitleUpdates()
    elseif selectedMenuOption == MainMenuOption_DisableAll then
        DisableAllTitleUpdates()
    end
end

-- Display Main Menu and return selected option's index, or -1 if cancelled
function ShowMainMenu()
    local dialogBox = Script.ShowPopupList(scriptTitle, "Select an option", MainMenu)
    if not dialogBox.Canceled then
        return dialogBox.Selected.Key
    end
    
    return -1
end

-- Enable all title updates
function EnableAllTitleUpdates()
    -- First, clear any existing active title updates
    Sql.Execute("DELETE FROM ActiveTitleUpdates")
    
    -- Get all title updates from ContentItems.db
    local titleUpdates = Sql.ExecuteFetchRows("SELECT Id FROM TitleUpdates")
    
    if #titleUpdates == 0 then
        Script.ShowMessageBox("No Title Updates", "No title updates found in database.", "OK")
        ResetToMainMenu()
        return
    end
    
    -- Add each title update to ActiveTitleUpdates
    local successCount = 0
    for i, titleUpdate in ipairs(titleUpdates) do
        local titleUpdateId = titleUpdate.Id
        
        -- Insert into ActiveTitleUpdates table
        local success = Sql.Execute("INSERT INTO ActiveTitleUpdates (TitleUpdateId) VALUES (" .. titleUpdateId .. ")")
        
        if success then
            successCount = successCount + 1
        end
    end
    
    if successCount >= 1 then 
        local ret = Script.ShowMessageBox("Title Updates Enabled", "Successfully enabled " .. successCount .. " of " .. #titleUpdates .. " title updates.\nIn order for the changes to take effect you need to reload Aurora\nDo you want to reload Aurora now?", "No", "Yes")

		if ret.Button == 2 then
			Aurora.Restart();
		end
    else
        Script.ShowMessageBox(
            "Title Updates Enabled", 
            "Enabled " .. successCount .. " of " .. #titleUpdates .. " title updates.", 
            "OK"
        )
    end
    
    ResetToMainMenu()
end

-- Disable all title updates
function DisableAllTitleUpdates()
    -- Clear all entries from ActiveTitleUpdates
    local success = Sql.Execute("DELETE FROM ActiveTitleUpdates")
    
    if success then
        local ret = Script.ShowMessageBox("Title Updates Disabled", "All title updates have been disabled.\nIn order for the changes to take effect you need to reload Aurora\nDo you want to reload Aurora now?", "No", "Yes")

		if ret.Button == 2 then
			Aurora.Restart();
		end

    else
        Script.ShowMessageBox("Error", "Failed to disable title updates.", "OK")
    end
    
    ResetToMainMenu()
end