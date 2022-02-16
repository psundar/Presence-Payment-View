# Client Project Payment Management

This code creates a lwc to manage project payments by clients. This code is part of a coding assignment.

## Data Modal

###Standard Objects
1. Contact

###Custom Objects
1. Project
2. Presence Payment
3. Payments to Projects junction object

## How to use

The following are the steps to use app,

1. The lwc is added as a custom Tab called "Presence Payments View" under service app. 
2. Contacts and Projects are added through standard record pages.
3. Data for Presence Payments and Payments to projects are added through the custom lwc.
4. To add payments to projects. First add parent payment information by clicking the "Add Payment" button. Then add individual payments to projects using "Add Payments to Projects" button.
5. Only the payment information is editable. Use inline edit.
6. To delete a payment to project, click the row action button at the end of payment information and select 'Delete' action.

