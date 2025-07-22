# How to do multiple selection 

For example, we need to enhance scenario group form such that:
When create scenario gorups, in addition to name and description, I want user to select multiple acstor sceanrios. The UI should be similar to something like add items during shoping.


To add multi-select for actor scenarios, we need to:

1. Add a multi-select input field
2. Handle the scenario_ids parameter in the form
3. Update the form's changeset to handle scenario associations