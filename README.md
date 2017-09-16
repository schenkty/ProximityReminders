# ProximityReminders
Treehouse TechDegree Project #11

Do you ever forget to take your keys when you leave the house? How about reminding yourself to pick up milk when close to the grocery store? You are in luck, because you now have all the skills to develop such an app! Your challenge is to develop a proximity reminder app which can remind you when you are close to a location or leaving a location.

You will need to use Core Location for geo-fencing, Core Data to save the reminders, and notifications for the reminder. A geo-fence is a virtual perimeter around a geographic area. The app should closely resemble the stock Reminders app in iOS.

The core objective is to create an app to display a local notification when entering or leaving a location. The app needs to allow the user to enter or search for a location and choose whether the reminder should be set for leaving or entering the location. For example, one should be able to set a reminder to pick up milk when close to a grocery store.

Remember that if you put enough effort into the user experience and design of the app, it can serve as a portfolio piece. Don't forget to architect the app with readable and maintainable code.

At a minimum, your app should include the following features:

 - A basic master-detail view architecture
 - Ability to create reminders
 - Ability to edit and/or delete existing reminders
 - Geo-fence a reminder to a location so that you can display an alert notification when leaving or entering the location


The app should include the following features:

A basic master-detail view architecture

Ability to create reminders

Ability to edit and/or delete existing reminders

Geo-fence a reminder to a location so that you can display an alert notification when leaving or entering the location

The main screen should be implemented as a table view with reminders, and the user can tap to add a new reminder.

When adding a reminder, the user can add/search for a location and associate it with the reminder. The user can then choose to be reminded when leaving or entering the location.

When the user is about to enter or leave the location they must be presented with a location notification of the reminder.


Extra Credit

To get an "exceeds" rating, you can expand on the project in the following ways:

 - When creating a reminder, add the ability to add or search for a location and associate it with the reminder (check out the workflow of doing this in the stock Reminder app ).
 - The location associated with the reminder can be displayed on a map.
 - A geo-fenced circle will be displayed around the location. The circle should have a diameter of 50 meters.
