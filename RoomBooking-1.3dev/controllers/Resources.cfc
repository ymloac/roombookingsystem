//================= Room Booking System / https://github.com/neokoenig =======================--->
component extends="Controller" hint="Resources Controller"
{
	/*
	 * @hint Constructor.
	 */
	public void function init() {
		// Permission filters
		super.init();

		// Permissions
		filters(through="checkPermissionAndRedirect", permission="accessresources");
		filters(through="_checkResourcesAdmin");
		filters(through="_isValidAjax", only="check");

		// Data
		filters(through="_getresources", only="index");
		filters(through="_getLocations");

		// Verification
		verifies(only="view,edit,update,delete", params="key", paramsTypes="integer", route="home", error="Sorry, that event can't be found");
 
		// Format
		provides("html,json");
	}

/******************** Public***********************/
	/*
	 * @hint Add Resource
	*/
	public void function add() {
		resource=model("resource").new();
	}

	/*
	 * @hint Create Resource
	*/
	public void function create() {
		if(structkeyexists(params, "resource")){
	    	resource = model("resource").new(params.resource);
			if ( resource.save() ) {
				redirectTo(action="index", success="resource successfully created");
			}
	        else {
				renderPage(action="add", error="There were problems creating that resource");
			}
		}
	}

	/*
	 * @hint Edit Resource
	*/
	public void function edit() {
		resource=model("resource").findOne(where="id = #params.key#");
	}

	/*
	 * @hint Update Resource
	*/
	public void function update() {
		if(structkeyexists(params, "resource")){
	    	resource = model("resource").findOne(where="id = #params.key#");
			resource.update(params.resource);
			if ( resource.save() )  {
				redirectTo(action="index", success="resource successfully updated");
			}
	        else {
				renderPage(action="edit", error="There were problems updating that resource");
			}
		}
	}

	/*
	 * @hint Delete Resource
	*/
	public void function delete() {
    	resource = model("resource").findOne(where="id = #params.key#");
		if ( resource.delete() )  {
			redirectTo(action="index", success="resource successfully deleted");
		}
        else {
			redirectTo(action="index", error="There were problems deleting that resource");
		}
	}

/******************** Private *********************/
	/*
	 * @hint
	*/
	public void function _checkResourcesAdmin() {
		if (!application.rbs.setting.allowResources){
			redirectTo(route="home", error="Facility to add/edit resources has been disabled");
		}
	}
/******************** Ajax/Remote/Misc*************/
	/*
	 * @hint Bit of a hack, but a quick lookup to see if a resource is already booked
	*/
	public void function check() {
		param name="params.format" default="json";
		if(structKeyExists(params, "start")
			AND structKeyExists(params, "end")
			AND structKeyExists(params, "id") ){
		// We need to not check the eventid if editing, but still need it for cloning + adding
		if(structKeyExists(params, "referrer") && params.referrer != "clone"){
  			params.excludeeventid=params.id;
		}
		// Override empty eventid 
		if(structKeyExists(params, "eventid") && !isNumeric(params.eventid)){
			params.eventid=0;
		}
		params.resourceid=params.id;
  		var loc={};
  			// get all for that day, including infinite repeats, excluding the current event if editing
  			loc.events=getEventsForRange(excludestatus="denied", start=dateFormat(params.start, "YYYY-MM-DD"), end=dateFormat(params.end, "YYYY-MM-DD") & " 23:59");
  			// generate repeats etc
  			loc.eventsArray=parseEventsForCalendar(events=getEventsForRange(), viewPortStartDate=dateFormat(params.start, "YYYY-MM-DD"), viewPortEndDate=end=dateFormat(params.end, "YYYY-MM-DD") & " 23:59");
			eCheck=[];
  	 		for(potentialClash in loc.eventsArray){
  	 			var allow=0;
  	 			if(len(potentialClash.type)){
  	 				if(isTimeClash(start1=params.start,end1=params.end,start2=potentialClash.repeat.start,end2=potentialClash.repeat.end)){
  	 					 allow=1;
  	 				}
  	 			} else {
  	 				if(isTimeClash(start1=params.start,end1=params.end,start2=potentialClash.start,end2=potentialClash.end)){
  	 					allow=1;
  	 				}
  	 			}
	  	 		// Skip All Day events if in settings
  	 			if(!application.rbs.setting.includeAllDayEventsinConcurrency && potentialClash.allDay){
  	 				allow=0;
  	 			}
  	 			if(allow){
  	 				arrayAppend(eCheck, potentialClash);
  	 			}
  	 		}
			renderWith(eCheck);
		} else{
			renderWith(params);
		}
	}
	/*public void function checkavailability() {
		param name="params.format" default="json"; 
		param name="params.id" default="" type="numeric";
		param name="params.eventid" default=0 type="any";
		param name="params.start" default="" type="string";
		param name="params.end" default="" type="string";
		params.resourceid = params.id;
		structDelete(params, "location");
		var loc={};
		var response={};
		// get all for that day, including infinite repeats, excluding the current event if editing
  			loc.events=getEventsForRange(resourceid=params.resourceid, excludestatus="denied", start=dateFormat(params.start, "YYYY-MM-DD"), end=dateFormat(params.end, "YYYY-MM-DD") & " 23:59");
  			response.eventsArray=parseEventsForCalendar(events=loc.events, viewPortStartDate=dateFormat(params.start, "YYYY-MM-DD"), viewPortEndDate=end=dateFormat(params.end, "YYYY-MM-DD") & " 23:59");
	 		response.events=loc.events;
	 		response.params=params;
		renderWith(response);
		 
		if(!isDate(params.end)){
			params.end=dateAdd("h", 1, params.start);
		}
		// Check for any events which may have booked the unique resource in the given timeframe, excluding the event itself
		// Repeat events?
		checkEvent=model("event").findAll(
			where="startsat <= '#params.start#' AND endsat >= '#params.end#' AND id != #params.eventid# AND resourceid = #params.id#",
			include="eventresources");
		// Check for events with an All Day flag which might have incorrect timings set; this shouldn't affect events which span multiple days, as the above check (should) pick them up;
			tempstart=dateFormat(params.start, "yyyy-mm-dd") & ' ' & timeFormat(params.start, "00:00");
			tempend=dateFormat(params.end, "yyyy-mm-dd") & ' ' & timeFormat(params.end, "23:59");
		checkEvent2=model("event").findAll(
			where="startsat >= '#tempstart#' AND endsat <= '#tempend#' AND id != #params.eventid# AND allday=1 AND resourceid=#params.id#",
			include="eventresources");

		
		*/
 
}