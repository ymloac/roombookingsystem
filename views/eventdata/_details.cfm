<!---================= Room Booking System / https://github.com/neokoenig =======================--->
<cfoutput>
<cfparam name="resources">
<cfif application.rbs.setting.approveBooking>

	<!--- Notification of status --->
	<cfif event.status EQ "denied">
		<div class="alert alert-danger">
			<strong><i class="glyphicon glyphicon-remove"></i> #l("Denied")#</strong> #l("This booking has been denied")#.
		</div>
	</cfif>

	<cfif event.status EQ "pending">
		<div class="alert alert-warning">
			<strong><i class="glyphicon glyphicon-warning-sign"></i> #l("Pending Approval")#</strong> #l("This booking is pending approval from an administrator")#.
		</div>

		<!--- Approvals--->
		<cfif checkPermission("allowApproveBooking")>
			<div class="btn-group btn-group-justified">
				#linkTo(action="approve", key=event.eventid, text="<span class='glyphicon glyphicon-ok'></span> " & l("Approve?"), controller="bookings", class="btn btn-success btn-sm")#
				#linkTo(action="deny", key=event.eventid, text="<span class='glyphicon glyphicon-remove'></span> " & l("Deny"), controller="bookings", class="btn btn-danger btn-sm")#
				#linkTo(action="deny", key=event.eventid, text="<span class='glyphicon glyphicon-trash'></span> " & l("Deny & Delete"), controller="bookings", class="btn btn-danger btn-sm", params="delete=1")#
			</div> 
		</cfif>
	</cfif> 
</cfif>

<!--- Editing --->
<cfif checkPermission("allowRoomBooking")> 
 	<div class="btn-group btn-group-justified">
		#linkTo(action="edit", key=event.eventid, text="<span class='glyphicon glyphicon-pencil'></span> " & l("Edit"), controller="bookings", class="btn btn-info btn-sm")#
		#linkTo(action="clone", key=event.eventid, text="<span class='glyphicon glyphicon-repeat'></span> " & l("Clone"), controller="bookings", class="btn btn-warning btn-sm")#
		<!--- Repeat Controls --->
		<cfif len(event.type) && structkeyExists(params, "instanceDate")> 
		#linkTo(action="addexception", key=event.eventid, params="exceptiondate=#dateFormat(params.instanceDate, 'yyyy-mm-dd')#", text="<span class='glyphicon glyphicon-trash'></span> " & l("Delete Instance"), controller="bookings", class="btn btn-danger btn-xs", confirm="Are you sure?")#

		#linkTo(action="delete", key=event.eventid, text="<span class='glyphicon glyphicon-trash'></span> " & l("Delete All"), controller="bookings", class="btn btn-danger btn-sm", confirm="Are you sure?")#
		<cfelse>
			#linkTo(action="delete", key=event.eventid, text="<span class='glyphicon glyphicon-trash'></span> " & l("Delete"), controller="bookings", class="btn btn-danger btn-sm", confirm="Are you sure?")#
		</cfif> 
	</div> 
</cfif>
<cfif checkPermission("viewRoomBooking")>
<cfif structKeyExists(application.rbs.templates, "event") AND structKeyExists(application.rbs.templates.event, "output")>
	 #processShortCodes(application.rbs.templates.event.output)#
<cfelse>
	<!--- Default Template--->
	<cfsavecontent variable="eventTemplate">
		<h4>[output id="title"]</h4>
		<div class="row">
			<div class="col-sm-2">
				<p><strong>From</strong></p>
			</div>
			<div class="col-sm-10">
				[output id="startsat"]
			</div>
		</div>

		<div class="row">
			<div class="col-sm-2">
				<p><strong>To</strong></p>
			</div>
			<div class="col-sm-10">
				[output id="endsat"]
			</div>
		</div>

		<div class="row">
			<div class="col-sm-2">
				<p><strong>Location</strong></p>
			</div>
			<div class="col-sm-10">
				[output   id="name" append=","] [output id="description"] ([output id="layoutstyle"] style)
			</div>
		</div>

		<div class="row">
			<div class="col-sm-2">
				<p><strong>Status</strong></p>
			</div>
			<div class="col-sm-10">
				[output   id="status"]
			</div>
		</div>

		<p>[output label="Contact" id="contactname"] [output id="contactemail" prepend="(", append=")"] [output id="contactno" prepend="(", append=")"]</p>

		[output id="eventdescription", prepend="<div class='well'>", append="</div>"]

	</cfsavecontent>
	#processShortCodes(eventTemplate)#
</cfif>

<!---================= Resources =================--->
	<cfif application.rbs.setting.allowResources AND len(event.resourceid)>
	<hr />
	<h4>#l("Requested Resources")#:</h4>
		<cfloop query="event">
			<cfloop query="resources">
				<cfif event.resourceid EQ resources.id[currentrow]>
					<p><strong>#h(name)#</strong><br /><small>#h(description)#</small></p>
				</cfif>
			</cfloop>
		</cfloop>
	</cfif>



<cfelse>
	<p>#l("You're not allowed to view the booking details")#</p>
</cfif></cfoutput>
