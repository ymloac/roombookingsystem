<!---================= Room Booking System / https://github.com/neokoenig =======================--->
<!--- Add --->
<cfoutput>
#panel(title=l("Create New Event"))#
#errorMessagesFor("event")#
	#startFormTag(action="create", id="bookingform")#
		#includePartial("form")#
		<!--- If approval process is on, and user is allowed to bypass approval --->
		<cfif application.rbs.setting.approveBooking AND checkPermission("bypassApproveBooking")>
			#submitTag(id="submitBtn", value=l("Create And Auto-approve Booking"), class="btn btn-block btn-primary btn-lg submitEvent")#
		<!--- If approval process in on and user can't bypass --->
		<cfelseif application.rbs.setting.approveBooking>
			#submitTag(id="submitBtn", value=l("Request Booking"), class="btn btn-block btn-primary btn-lg submitEvent")#
		<!--- Approval process off --->
		<cfelse>
			#submitTag(id="submitBtn", value=l("Create Booking"), class="btn btn-block btn-primary btn-lg submitEvent")#
		</cfif>
	#endFormTag()#
#panelend()#
</cfoutput>
