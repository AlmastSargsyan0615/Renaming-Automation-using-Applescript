
set the_folder to choose folder with prompt "Choose a directory:"
set filter_words to {"(Clean Single)", "(WeMaster)", "(WeMaster Clean Single)", "  "} -- Add your filter words here
set all_Files_List to {}
set all_Folders_List to {}
set cleanList to {}
set allFilesList to {}

getAllFilesOfFolder(the_folder, allFilesList)

on getAllFilesOfFolder(rfolder, filesList)
	tell application "System Events"
		-- Get all files in the folder
		set folderFiles to files of rfolder
		repeat with fileItem in folderFiles
			set end of filesList to POSIX path of (fileItem as alias)
		end repeat
		
		-- Get all subfolders in the folder
		set subFolders to folders of rfolder
		repeat with subFolder in subFolders
			-- Recursively call the function for subfolders
			my getAllFilesOfFolder(subFolder, filesList)
		end repeat
	end tell
end getAllFilesOfFolder

-- Export all files to a text file
set exportFilePath to (choose file name with prompt "Choose where to save the file" default name "file_list.txt")
set fileHandle to open for access exportFilePath with write permission
repeat with fileItem in allFilesList
	write fileItem & linefeed to fileHandle as text
end repeat
close access fileHandle


get_All_Files_and_Folders_of_Folder(the_folder, all_Files_List, all_Folders_List)

-- Rename files and folders after removing filter words
repeat with file_path in all_Files_List
	set result_temp to my removeFilterWordsAndRename(file_path, filter_words)
	if result_temp is not "" then
		set end of cleanList to result_temp
	end if
end repeat

repeat with folder_path in all_Folders_List
	my removeFilterWordsAndRename(folder_path, filter_words)
end repeat

writeListToFile(cleanList, "CleanedList.txt")

on get_All_Files_and_Folders_of_Folder(the_folder, all_Files_List, all_Folders_List)
	tell application "System Events"
		-- Get all files in the folder
		set files_list to files of the_folder
		repeat with file_ref in files_list
			set end of all_Files_List to file_ref
		end repeat
		
		-- Get all subfolders in the folder
		set sub_folders_list to folders of the_folder
		repeat with folder_ref in sub_folders_list
			set end of all_Folders_List to folder_ref
			-- Recursively call the function for subfolders
			my get_All_Files_and_Folders_of_Folder(folder_ref, all_Files_List, all_Folders_List)
		end repeat
	end tell
end get_All_Files_and_Folders_of_Folder

-- Function to remove filter words from a file or folder name and rename
on removeFilterWordsAndRename(item_ref, filter_words)
	set temp to ""
	tell application "System Events"
		
		set item_name to name of item_ref
		set item_extension to name extension of item_ref
		if item_extension is not "" then
			set item_name to text 1 thru -((count item_extension) + 2) of item_name
		end if
		-- Remove filter words from the item name
		repeat with filter_word in filter_words
			if item_name contains filter_word then
				set item_name to my removeFilterWordFromString(item_name, filter_word)
			end if
		end repeat
		-- Check if the new name is empty
		if item_name is "" then
			set item_name to "Untitled"
		end if
		-- Construct the new name with extension
		set original_name to item_name
		set counter to 1
		set new_name to item_name
		--display dialog (name of files of (container of item_ref) as text)
		
		
		repeat
			-- Get the names of files in the directory as text
			set file_names_text to (name of files of (container of item_ref) as text)
			
			-- Count the number of occurrences of the special text
			set occurrences_count to 0
			set AppleScript's text item delimiters to new_name
			set textItems to text items of file_names_text
			set AppleScript's text item delimiters to ""
			repeat with currentItem in textItems
				if currentItem is equal to new_name then
					set occurrences_count to occurrences_count + 1
				end if
			end repeat
			if occurrences_count is less than 2 then
				exit repeat
			else
				set new_name to original_name & "_" & counter
				set counter to counter + 1
			end if
		end repeat
		if item_extension is not "" then
			set new_name to new_name & "." & item_extension
		end if
		-- Rename the item
		try
			set olderName to name of item_ref as text
			set name of item_ref to new_name
			if olderName is not new_name then
				set temp to olderName & "     =====>     " & new_name
			end if
		on error errMsg
			display dialog errMsg
		end try
	end tell
	--display dialog temp
	return temp
end removeFilterWordsAndRename

on writeListToFile(theList, fileName)
	set filePath to ((path to desktop as text) & fileName) as text
	set fileRef to open for access filePath with write permission
	try
		repeat with listItem in theList
			write listItem & linefeed to fileRef as text
		end repeat
		display dialog "List successfully written to file."
	on error errMsg
		display dialog "Error: " & errMsg
	end try
	close access fileRef
end writeListToFile


-- Function to remove a filter word from a string
on removeFilterWordFromString(theString, filterWord)
	set AppleScript's text item delimiters 

to filterWord
	set theStringItems to text items of theString
	set AppleScript's text item delimiters to ""
	set newString to theStringItems as text
	return newString
end removeFilterWordFromString


on countOccurrencesInFileNames(item_ref, special_text)
	-- Get the names of files in the directory as text
	set file_names_text to (name of files of (container of item_ref) as text)
	
	-- Count the number of occurrences of the special text
	set occurrences_count to 0
	set AppleScript's text item delimiters to special_text
	set textItems to text items of file_names_text
	set AppleScript's text item delimiters to ""
	repeat with currentItem in textItems
		if currentItem is equal to special_text then
			set occurrences_count to occurrences_count + 1
		end if
	end repeat
	
	-- Return the count of occurrences
	return occurrences_count
end countOccurrencesInFileNames
