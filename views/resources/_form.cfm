<!---================= Room Booking System / https://github.com/neokoenig =======================--->
<!--- resource Form--->
<cfoutput>
#errorMessagesFor("resource")#
<div class="row">
	<div class="col-md-4">
		#textField(objectname="resource", property="name", required="true", label=l("Name") & " *", placeholder="e.g Laptop")#
	</div>
	<div class="col-md-4">
		#textField(objectname="resource", property="description", label=l("Description"), placeholder="e.g Dell 15""")#
	</div>
	<div class="col-md-4">
		#select(objectname="resource", property="type", label=l("Grouping"), options=application.rbs.setting.resourceTypes)#
	</div>
</div>
<div class="row">
	<div class="col-md-4">

		<div class="well">
			<h4>Item Type</h4>
		#checkBox(objectname="resource", property="isunique", label=l("Unique Item"))#
		<p class="help-block">#l("Resources can exist in two states, unique or generic; A unique item can't be booked out if it's already associated with a booking going on at that time. A generic item has no such restrictions. e.g: 'My Shiny MacBook Pro' would be a unique item - there's only one of them, whereas 'Laptop' would just imply the user needs 'a laptop'")#.</p>
		</div>
	</div>
	<div class="col-md-4">
		<div class="well">
			<h4>#l("Restrict Resource to locations")#</h4>
			<p class="help-block">#l("Only allow the resource to be booked in these locations: ctrl+click to multiple select")#</p>
				#select(objectname="resource", property="restrictlocations", options=locations, label=l("Restrict to these locations"), multiple=true)#

		</div>
	</div>
	<div class="col-md-4">

	</div>
</div>
</cfoutput>