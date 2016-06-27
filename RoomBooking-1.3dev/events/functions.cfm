<cfscript>
//================= Room Booking System / https://github.com/neokoenig =======================--->

//=====================================================================
//=     Global Auth Functions
//=====================================================================
    /*
    *  @hint Get logged in user
    */
    public void function getCurrentUser() {
        user=model("user").findOne(where="id=#session.currentUser.id# AND email = '#session.currentUser.email#'");
        if(!isObject(user)){
            redirectTo(route="home", error="Sorry, we couldn't find your account..");
        }
    }

    /*
    *  @hint Basically loads all user details and permissions into session scope for easy reference
    */
    private void function _createUserInScope(required user) {
        var scope={
            id=user.id,
            firstname=user.firstname,
            lastname=user.lastname,
            email=user.email,
            role=user.role,
            apitoken=user.apitoken
        };
        session.currentuser=scope;
        redirectTo(route="home");
    }

    /*
    *  @hint Returns true if session exists / useful for simple checks
    */
    public boolean function isLoggedIn() {
        return StructKeyExists(session, "currentUser");
    }

    /*
    *  @hint Returns true if user is a specified role
    */
    public boolean function userIsInRole(required string role) {
        var r=false;
        if(isLoggedin()){
            if(structKeyExists(session.currentuser, "role") AND (session.currentUser.role EQ arguments.role)){
                r=true;
            }
        }
        return r;
    }

    /*
    *  @hint Used in filters
    */
    public void function _checkLoggedIn() {
        if(!isLoggedIn()){
            redirectTo(route="login");
        }
    }

    /*
    *  @hint Returns a list of potential roles
    */
    public void function _getRoles() {
        roles=application.rbs.roles;
    }

    /*
    *  @hint Shoves auth'd user elsewhere
    */
    public void function redirectIfLoggedIn() {
       if(isLoggedIn()){
        redirectTo(route="home");
    }
}

    /*
    *  @hint Returns the current signed in user
    */
    public struct function currentUser() {
        if ( isLoggedIn() ) {
            currentUser = model("user").findByKey(session.currentUser.id);
            return currentUser;
        }
    }

    /*
    *  @hint Signs out the user
    */
    public void function signOut() {
        if (isLoggedIn() ) {
         StructDelete(session, "currentUser");
        }
     }

    /*
    Notes on salting / hashing:
    Password is hashed using a salt
    Salt is encrypted with a unique key (AuthKey)

    So to compare a password hash, you need to decrypt the salt first

    The authKey is unique per installation; It's useful as you can invalidate all the site passwords in one go by just changing it
    */

    /*
    *  @hint Returns a semi-unique key per installation
    */
    public string function getAuthKey() {
        var authkeyLocation=expandPath("config/auth.cfm");
        var authkeyDefault=createUUID();
        if(fileExists(authkeyLocation)){
            return fileRead(authkeyLocation);
            } else {
                fileWrite(authkeyLocation, authkeyDefault);
                return authkeyDefault;
            }
        }

    /*
    *  @hint Generate an API Key
    */
    public string function _generateApiKey(){
        return hash(createUUID() & getAuthKey(), 'SHA-512');
    }

    /*
    *  @hint Create Salt using authkey
    */
    public string function createSalt() {
        return encrypt(createUUID(), getAuthKey(), 'CFMX_COMPAT');
    }

    /*
    *  @hint Get salt using authkey
    */
    public string function decryptSalt(required string salt) {
        return decrypt(arguments.salt, getAuthKey(), 'CFMX_COMPAT');
    }

    /*
    *  @hint Hash Password using SHA512
    */
    public string function hashPassword(required string password, required string salt) {
        return hash(arguments.password & arguments.salt, 'SHA-512');
    }

    /*
    *  @hint Checks a permission against permissions loaded into application scope for the user
    */
    public boolean function checkPermission(required string permission) {
        var retValue=0;
        if(_permissionsSetup() AND structKeyExists(application.rbs.permission, arguments.permission)){
            retValue = application.rbs.permission[arguments.permission][_returnUserRole()];
            if(retValue == 1){
                return true;
                } else {
                    return false;
                }
            }
        }

    /*
    *  @hint Checks a permission and redirects away to access denied, useful for use in filters etc
    */
    public void function checkPermissionAndRedirect(required string permission) {
     if(!checkPermission(arguments.permission)){
        redirectTo(route="denied", error="Sorry, you have insufficient permission to access this. If you believe this to be an error, please contact an administrator.");
        }
    }

    /*
    * @hint: Check the owner id of the event against the currently logged in user
    */
    public boolean function _checkOwnership(required struct data) {
        if(structKeyExists(event, "ownerid") && len(event.ownerid) && isloggedin()){
            if(event.ownerid == session.currentuser.id || checkPermission("editAnyBooking")){
                return true;
            } else {
                return false;
            }
        }
        return true;
    }
    /*
    * @hint: Check the owner id of the event against the currently logged in user
    */
    public void function _checkOwnershipAndRedirect(required struct event) {
        if(!_checkOwnership(event)){
            redirectTo(route="home", error="You don't have permission to edit that event");
        } 
    }

    /*
    *  @hint Checks for the relevant permissions structs in application scope
    */
    public boolean function _permissionsSetup() {
        if(structKeyExists(application, "rbs") AND structKeyExists(application.rbs, "permission")){
            return true;
            }  else {
                return false;
            }
        }

    /*
    *  @hint Looks for user role in session, returns guest otherwise
    */
    public string function _returnUserRole() {
        if(_permissionsSetup() AND isLoggedIn() AND structKeyExists(session.currentuser, "role")){
            return session.currentuser.role;
            } else {
                return "guest";
            }
        }

    /*
    *  @hint Used to redirect away in demo mode
    */
    public void function denyInDemoMode() {
        if(application.rbs.setting.isdemomode){
            redirectTo(route="home", error="Disabled in Demo Mode");
        }
    }

//=====================================================================
//=     Short codes callbacks for custom templating
//=====================================================================
     
    /*
    *  @hint Render a  field
    */
    
      function field_callback(attr) {
        var result="";
        var path="#application.wheels.webPath#/#application.wheels.viewPath#/shortcodes/field.cfm";
        savecontent variable="result" {
         include path;
     }
     return result;
    }

    /*
    *  @hint Render a  field
    */
      function output_callback(attr) {
        var result="";
        var path="#application.wheels.webPath#/#application.wheels.viewPath#/shortcodes/output.cfm";
        savecontent variable="result" {
         include path;
     }
     return result;
    }
 

//=====================================================================
//=     Language switcher
//=====================================================================
    /*
    *  @hint
    */
    public string function getCurrentLanguage() {
        if(structKeyExists(session, "lang") AND len(session.lang)){
            return session.lang;
            } else {
                return "en_GB";
            }
        }

//=====================================================================
//=     Various Utils
//=====================================================================
  /*
    *  @hint Get IP
    */
    public string function getIPAddress() {
        var result="127.0.0.1";
        var myHeaders = GetHttpRequestData();
        if(structKeyExists(myHeaders, "headers") AND structKeyExists(myHeaders.headers, "x-forwarded-for")){
            result=myHeaders.headers["x-forwarded-for"];
        }
        return result;
    }
    /*
    *  @hint I know this is stupid, but it's a hack with the way I'm doing the settings in the db
    */
    public string function returnStringFromBoolean(required boo) {
        if(arguments.boo){
            return "true";
            } else {
                return "false";
            }
        }

//=====================================================================
//=     Logging
//=====================================================================
    /*
    *  @hint Quick way to add a logline
    */
    public void function addlogline() {
        // NB, external auth won't log non numeric userids.
        if(isLoggedIn() && isnumeric(session.currentuser.id)){
            arguments.userid=session.currentuser.id;
        }
        arguments.ipaddress=getIPAddress();
        l=model("logfile").create(arguments);
    }
    /*
    *  @hint Log the flash via filter
    */
    public void function logFlash() {
        if(structkeyexists(session,"flash")){
            if(structkeyexists(session.flash, "error")){
                addLogLine(message=session.flash.error, type="error");
            }
            if(structkeyexists(session.flash, "success")){
                addLogLine(message=session.flash.success, type="success");
            }
        }
    }

    /**
 * Combines structFindKey() and structFindValue()
 * v1.0 by Adam Cameron
 * v1.01 by Adam Cameron (fixing logic error in scope-handling)
 *
 * @param struct     Struct to check (Required)
 * @param key    Key to find (Required)
 * @param value      Value to find for key (Required)
 * @param scope      Whether to find ONE (default) or ALL matches (Optional)
 * @return Returns an array as per structFindValue()
 * @author Adam Cameron (dac.cfml@gmail.com)
 * @version 1.01, September 9, 2013
 */
 public array function structFindKeyWithValue(required struct struct, required string key, required string value, string scope="ONE"){
    if (!isValid("regex", arguments.scope, "(?i)one|all")){
        throw(type="InvalidArgumentException", message="Search scope #arguments.scope# must be ""one"" or ""all"".");
    }
    var keyResult = structFindKey(struct, key, "all");
    var valueResult = [];
    for (var i=1; i <= arrayLen(keyResult); i++){
        if (keyResult[i].value == value){
            arrayAppend(valueResult, keyResult[i]);
            if (scope == "one"){
                break;
            }
        }
    }
    return valueResult;
}

</cfscript>


<!---================================ Cookies ======================================--->
<!--

    Cookie:RBS_UN : The Username (string)
        Request: request.cookie.username

        Keep this in tag form as for some reason I can never really get this to work in script form.
    --->
    <cffunction name="setCookieRememberUsername" hint="Sets a cookie which remembers the login">
        <cfargument name="username">
        <cfcookie name = "RBS_UN" expires="360" value="#arguments.username#" httpOnly="true">
            <cfset addlogline(message="#arguments.username# used cookie remember email", type="Cookie")>
        </cffunction>

        <Cffunction name="setCookieForgetUsername" hint="Remove the username cookie">
           <cfcookie  name = "RBS_UN" expires = "NOW"  httpOnly="true">
            <cfset addlogline(message="Cookie remember email removed", type="Cookie")>
        </Cffunction>


<cfif listFirst(server.coldfusion.productVersion) LTE "10">
    <!---
 Backport of QueryExecute in CF11 to CF9 &amp; CF10

 @param sql_statement    SQL. (Required)
 @param queryParams      Struct of query param values. (Optional)
 @param queryOptions     Query options. (Optional)
 @return Returns a query.
 @author Henry Ho (henryho167@gmail.com)
 @version 1, September 22, 2014
--->
<cffunction name="QueryExecute" output="false"
hint="
* result struct is returned to the caller by utilizing URL scope (no prefix needed) *
https://wikidocs.adobe.com/wiki/display/coldfusionen/QueryExecute">
<cfargument name="sql_statement" required="true">
<cfargument name="queryParams"  default="#structNew()#">
<cfargument name="queryOptions" default="#structNew()#">

<cfset var parameters = []>

<cfif isArray(queryParams)>
    <cfloop array="#queryParams#" index="local.param">
        <cfif isSimpleValue(param)>
            <cfset arrayAppend(parameters, {value=param})>
            <cfelse>
                <cfset arrayAppend(parameters, param)>
            </cfif>
        </cfloop>
        <cfelseif isStruct(queryParams)>
            <cfloop collection="#queryParams#" item="local.key">
                <cfif isSimpleValue(queryParams[key])>
                    <cfset arrayAppend(parameters, {name=local.key, value=queryParams[key]})>
                    <cfelse>
                        <cfset var parameter = {name=key}>
                        <cfset structAppend(parameter, queryParams[key])>
                        <cfset arrayAppend(parameters, parameter)>
                    </cfif>
                </cfloop>
                <cfelse>
                    <cfthrow message="unexpected type for queryParams">
                </cfif>

                <cfif structKeyExists(queryOptions, "result")>
                    <!--- strip scope, not supported --->
                    <cfset queryOptions.result = listLast(queryOptions.result, '.')>
                </cfif>

                <cfset var executeResult = new Query(sql=sql_statement, parameters=parameters, argumentCollection=queryOptions).execute()>

                <cfif structKeyExists(queryOptions, "result")>
                    <!--- workaround for passing result struct value out to the caller by utilizing URL scope (no prefix needed) --->
                    <cfset URL[queryOptions.result] = executeResult.getPrefix()>
                </cfif>

                <cfreturn executeResult.getResult()>
            </cffunction>
        </cfif>

        <cfscript>
        // Date Functions refactor



        /**
            *  @hint The main events query. The Where clause is a little... silly.
        */
        public query function getEventsForRange() {
            param name="params.start"  default="#now()#";
            param name="params.end"    default="#dateAdd('m', 1, now())#";
            param name="params.type"   default="";
            param name="params.status" default="";
            param name="params.building" default="";
            param name="params.location" default=""; 
            param name="params.q" default="";
            param name="params.excludeeventid" default="";  
            param name="params.excludestatus" default="";    
            param name="params.key" default="";
            param name="params.resourceid" default="";

            var loc={
                allEvents      = "",
                start          = params.start,
                end            = params.end,
                type           = params.type,
                status         = params.status,
                building       = params.building,
                location       = params.location,
                q              = params.q,
                excludeeventid = params.excludeeventid,
                excludestatus  = params.excludestatus,
                key            = params.key,
                resourceid     = params.resourceid,
                includeModel   = "location,eventexceptions"
            }  
            // Allow args scope to override params
            for(item in arguments){
                loc[item]=arguments[item];
            } 
 
            loc.viewPortStartDate=createDateTime(year(loc.start), month(loc.start), day(loc.start), hour(loc.start),minute((loc.start)),00);
            loc.viewPortEndDate=createDateTime(year(loc.end), month(loc.end), day(loc.end), hour(loc.end),minute((loc.end)),00);
            loc.wc="(((startsat >= '#loc.viewPortStartDate#' AND endsat <= '#loc.viewPortEndDate#') AND type IS NULL) 
                OR ((startsat >= '#loc.viewPortStartDate#' AND endsat >= '#loc.viewPortEndDate#' AND startsat < '#loc.viewPortEndDate#') AND type IS NULL) 
                OR ((startsat < '#loc.viewPortStartDate#' AND endsat < '#loc.viewPortEndDate#' AND endsat > '#loc.viewPortStartDate#') AND type IS NULL) 
                OR ((startsat < '#loc.viewPortStartDate#' AND endsat > '#loc.viewPortEndDate#') AND type IS NULL) 
                OR (repeatstartsat < '#loc.viewPortEndDate#' AND isnever = 1 AND type IS NOT NULL) 
                OR (repeatstartsat < '#loc.viewPortEndDate#' AND repeatendsat > '#loc.viewPortStartDate#' AND type IS NOT NULL) 
                OR (repeatstartsat < '#loc.viewPortEndDate#' AND repeatendsafter IS NOT NULL AND type IS NOT NULL)) ";

                // Allows us to pull events either by single location or by whole building
                if(loc.type EQ "building"){
                    loc.building=loc.key;
                } else if(loc.type EQ "location"){ 
                    loc.location=loc.key;
                }  
                if(len(loc.building)){
                    loc.wc = loc.wc & " AND building = '#loc.building#'";  
                }
                if(len(loc.location)){
                    loc.wc = loc.wc & " AND locationid = #loc.location#";
                }
                if(len(loc.status) && !len(loc.excludestatus)){
                    loc.wc = loc.wc & " AND status = '#loc.status#'";
                }
                if(len(loc.excludestatus)){ 
                    loc.wc = loc.wc & " AND status != '#loc.status#'";
                }
                if(len(loc.q) GT 2 && len(loc.q) LT 50){
                    loc.wc = loc.wc & " AND title LIKE '%#loc.q#%'";
                }
                // Useful for when we don't want to include the current event: i.e, in concurrency checks
                if(len(loc.excludeeventid) && isNumeric(loc.excludeeventid)){
                    loc.wc = loc.wc & " AND id != #loc.excludeeventid#";
                }
                // Used when checking against a specific resource
                if(structKeyExists(loc, "resourceid") && isNumeric(loc.resourceid)){
                    loc.includeModel=listAppend(loc.includeModel, "eventresources");
                    loc.wc = loc.wc & " AND resourceid = #loc.resourceid#";
                } 
                loc.events=model("event").findAll(
                    select="events.id,
                    events.title,
                    events.startsat,
                    events.endsat,
                    events.allday,
                    events.url,
                    events.className,
                    events.description,
                    events.locationid,
                    events.contactname,
                    events.contactno,
                    events.contactemail,
                    events.layoutstyle,
                    events.createdat,
                    events.updatedat,
                    events.deletedat,
                    events.status,
                    events.type,
                    events.isNever,
                    events.repeatstartsat,
                    events.repeatendsat,
                    events.repeatendsAfter,
                    events.repeatEvery,
                    events.repeatOn,
                    events.repeatby,
                    (TIMESTAMPDIFF(MINUTE, events.startsat, events.endsat)) AS duration,
                    locations.name,
                    locations.description AS locationdescription,
                    locations.class,
                    locations.colour,
                    locations.building,
                    GROUP_CONCAT(eventexceptions.exceptiondate) as exceptions", 
                    where=loc.wc,
                    include=loc.includeModel,
                    group="events.id",
                    order="startsat ASC");   
                
            return loc.events;
        }

     /*
    *  @hint For each event in the query calculate repeat dates and return appropriate array of events for renderwith()
    */
    public array function parseEventsForCalendar(required query events, required date viewPortStartDate, required date viewPortEndDate) {
        var r=[]; 
        var c=1;
        var rEvents="";
        var maxrows=10000;
        if(structKeyExists(params, "maxrows") && isNumeric(params.maxrows)){
            maxrows=params.maxrows;
        }
        for(event in events){
          if(c <= maxrows){  
            if(len(event.type)){ 
                repeatingevents=generateRepeatingEvents(event, viewPortStartDate, viewPortEndDate);
                // We'll get an array of events back, so we need to add them to the main events array
                for(repeatingevent in repeatingevents){   
                    r[c]["id"]            =   event.id;
                    r[c]["title"]         =   event.title;
                    r[c]["locationid"]    =   event.locationid; 
                    r[c]["class"]         =   event.class;
                    r[c]["start"]         =   _f_d(repeatingevent.start);
                    r[c]["end"]           =   _f_d(repeatingevent.end);
                    r[c]["allDay"]        =   event.allDay;
                    r[c]["status"]        =   event.status;
                    r[c]["type"]          =   event.type;
                    r[c]["className"]     =   event.class & ' ' & event.status & ' repeater';
                    r[c]["description"]   =   event.description;
                    r[c]["locationname"]  =   event.name;
                    r[c]["locationdescription"]  =   event.locationdescription;
                    r[c]["layoutstyle"]   =   event.layoutstyle;
                    r[c]["building"]      =   event.building;
                    r[c]["name"]          =   event.name;
                    r[c]["event"]         =   event;
                    r[c]["repeat"]        =   repeatingevent;
                    c++;
                }  
            } else {
                // Normal event, skip the repeat logic
                r[c]["id"]           =   event.id;
                r[c]["title"]        =   event.title;
                r[c]["locationid"]   =   event.locationid; 
                r[c]["class"]        =   event.class;
                r[c]["start"]        =   _f_d(event.startsat);
                r[c]["end"]          =   _f_d(event.endsat);
                r[c]["allDay"]       =   event.allDay;
                r[c]["status"]       =   event.status;
                r[c]["type"]         =   event.type;
                r[c]["className"]    =   event.class & ' ' & event.status;
                r[c]["description"]  =   event.description;
                r[c]["locationname"]  =   event.name;
                r[c]["locationdescription"]  =   event.locationdescription;
                r[c]["layoutstyle"]  =   event.layoutstyle;
                r[c]["building"]     =   event.building;
                r[c]["name"]         =   event.name;
                c++; 
            } 
          }
        }    
        return arrayOfStructsSort(r, "start");
    }

    /*
    *  @hint All Events get passed through here to check for repeat rules
    */
    public array function generateRepeatingEvents(required struct event, viewPortStartDate, viewPortEndDate) {
        var events=[];
        var repeatArguments={};
        var t=1; 
        // Doublecheck we've got a start repeater date, if not, set the event start as the repeat start date
        if(!isDate(event.repeatstartsat)){ event.repeatstartsat=event.startsat;}

        // If never, set the range end date to the end of the current viewable range
        if(isBoolean(event.isNever) AND event.isNever){
            event.repeatendsat=viewPortEndDate;
        }   

        // Check for Monthly DOW as opposed to DOM
        if(event.type == "monthly" && len(event.repeatby) && event.repeatby == "dow"){
            event.type = "monthlydow";
        }
        // Check for Weekly DOW  
        if(event.type == "weekly" && len(event.repeatOn)){
            event.type = "weeklydow";
        }
        // Create Repeat Arguments;
        repeatArguments.date        = event.startsat;
        repeatArguments.type        = event.type;
        repeatArguments.from        = event.repeatstartsat;
        if(isDate(event.repeatendsat)){
            repeatArguments.till        = event.repeatendsat;                
        }
        if(event.repeatEvery !=0 && isNumeric(event.repeatEvery)){ 
            repeatArguments.every       = event.repeatEvery;
        } else {
            repeatArguments.every       = 1;
        }
        if(event.repeatendsafter != ""){
            repeatArguments.iterations  = event.repeatendsafter;
        }
        repeatArguments.dow         = event.repeatOn;
        repeatArguments.filterstart = viewPortStartDate;
        repeatArguments.filterend   = viewPortEndDate;
        // Generate the repeating dates via plugin
        events=repeatDate(argumentCollection=repeatArguments); 
        // Remove any manual exceptions to the rule 
        if(len(event.exceptions)){
            events=removeExceptionsFromArray(events=events, exceptions=event.exceptions);
        }
        // Add Event Duration to remaining events
        events=addEventDuration(eventstart=event.startsAt, dates=events, duration=event.duration);   
        return events;
    }

    /*
    * @hint: 
    */
    public array function removeExceptionsFromArray(required array events, required string exceptions) {
        var loc={
            r=[]
        }
        for(var event in arguments.events){
            if(!listFind(arguments.exceptions, dateFormat(event, "YYYY-MM-DD")) ){
                arrayAppend(loc.r, event);
            }
        }
        return loc.r;
    }

    /*
    *  @hint Experimental date format
    */
    public string function _f_d(str) {
       return dateFormat(arguments.str, "YYYY-MM-DD") & "T" & timeFormat(arguments.str, "HH:MM:00");
   }
 

    /**
 * Sorts an array of structures based on a key in the structures.
 * 
 * @param aofS   Array of structures. (Required)
 * @param key    Key to sort by. (Required)
 * @param sortOrder      Order to sort by, asc or desc. (Optional)
 * @param sortType   Text, textnocase, or numeric. (Optional)
 * @param delim      Delimiter used for temporary data storage. Must not exist in data. Defaults to a period. (Optional)
 * @return Returns a sorted array. 
 * @author Nathan Dintenfass (nathan@changemedia.com) 
 * @version 1, April 4, 2013 
 */
function arrayOfStructsSort(aOfS,key){
        //by default we'll use an ascending sort
        var sortOrder = "asc";      
        //by default, we'll use a textnocase sort
        var sortType = "textnocase";
        //by default, use ascii character 30 as the delim
        var delim = ".";
        //make an array to hold the sort stuff
        var sortArray = arraynew(1);
        //make an array to return
        var returnArray = arraynew(1);
        //grab the number of elements in the array (used in the loops)
        var count = arrayLen(aOfS);
        //make a variable to use in the loop
        var ii = 1;
        //if there is a 3rd argument, set the sortOrder
        if(arraylen(arguments) GT 2)
            sortOrder = arguments[3];
        //if there is a 4th argument, set the sortType
        if(arraylen(arguments) GT 3)
            sortType = arguments[4];
        //if there is a 5th argument, set the delim
        if(arraylen(arguments) GT 4)
            delim = arguments[5];
        //loop over the array of structs, building the sortArray
        for(ii = 1; ii lte count; ii = ii + 1)
            sortArray[ii] = aOfS[ii][key] & delim & ii;
        //now sort the array
        arraySort(sortArray,sortType,sortOrder);
        //now build the return array
        for(ii = 1; ii lte count; ii = ii + 1)
            returnArray[ii] = aOfS[listLast(sortArray[ii],delim)];
        //return the array
        return returnArray;
}
</cfscript>