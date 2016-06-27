<!---================= Room Booking System / https://github.com/neokoenig =======================--->
<!--- Room Booking Confirmation--->
<cfparam name="event">
<cfoutput>
#includePartial("/common/email/header")#
<p style="Margin-top: 0;color: ##565656;font-family: sans-serif;font-size: 16px;line-height: 25px;Margin-bottom: 24px">Dear #event.contactname#,</p>
<p style="Margin-top: 0;color: ##565656;font-family: sans-serif;font-size: 16px;line-height: 25px;Margin-bottom: 24px">
<cfswitch expression="#event.status#">
	<cfcase value="approved">
		Your booking has been <strong>confirmed</strong>.
	</cfcase>
	<cfcase value="pending">
		Your booking is <strong>pending administrator approval</strong>.
	</cfcase>
	<cfcase value="denied">
		Your booking has been <strong>rejected by an administrator</strong>. Sorry about that.
	</cfcase>
</cfswitch></p>
<h4 style="Margin-top: 0;color: ##565656;font-weight: 700;font-size: 24px;Margin-bottom: 18px;font-family: sans-serif;line-height: 24px">#h(event.title)#</h4>


#includePartial("/common/email/footer")#
</cfoutput>