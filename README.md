MapNotes Release Notes
====

MapNotes is an iOS app that lets users save their location and add notes about it.

Beta4 (1.04) - 9/18/2009
----
- Added nearby notes to the quick add view map 
- Changed location detection to run continuously while quick add view is up
- Changed details view to support both email and share buttons
- Notes view detail text is now blue, shows first letter when sorted A-Z

Beta3 (1.03) - 9/17/2009
----
- Reverted adding text note takes user to 'Description', now goes to 'Title' again
- Groups - Hide the all notes nave bar when in edit mode
- Do not allow zero length group names
- Photos are now stored at a higher resolution and zooming is allowed in photo view
- Display location information in Note details view
- E-Mail sharing is now available (via Sharing button)
- Groups - Can now set pin color when creating a group 
- Sorting preferences are now maintained after leaving the Notes list view

Known Issues:
- Setting an existing note Photo can cause the application to crash
- Adding a description to a note with no description set causes the Share button to move to the description table row. 

Beta2 (1.02) - 9/15/2009
----
- New Application Icon 
- Updated UI Elements Throughout
- New Note - Adding Text Note now brings user to 'Description' edit instead of 'Title'
- Notes List - Now displays Description if Title is not set
- Notes List - New cell layout, bigger thumbnail
- Notes List - Sorting by Distance disabled if user has no current location
- Notes List - Notes with no Photo have a placeholder image
- Notes List - Previous sort choice is now maintained when user returns to Notes list
- Notes List - Sort and Map buttons are now disabled when no Notes are in list
- Map View - New Images for Map Pins, Flyouts show Thumbnail
- Details - Added 'Tweet' Button (not hooked up yet) and new Delete button image
- Details - Title text now wraps instead of truncating, limited to 35 characters max.
- Details - Photo Image has new graphical style
- Details - User can no longer pan the map on Details page
- Groups - Add Note has new graphic
- Groups - Clicking a group in edit mode allows editing of group name
- Groups - Title now limited to 25 characters
- Photos are now saved to device Photos Album as well as into the Note

Resolved Issues:
- Groups view should no longer cause crashes with OS 3.0

Known Issues:
- Notes List - A-Z Sorting is not correct for notes with no Title
- Notes List - Sort order is not correctly stored / retrieved from Settings
- Details - Description text is slightly off center (vertical) when only one line
- Groups - Titles should not  be zero length or duplicates of existing groups

Beta1 (1.0) - 9/1/2009
----
- Initial Release

Known Issues: 
- Groups caused application to crash on OS 3.0 (works in OS 3.1) 