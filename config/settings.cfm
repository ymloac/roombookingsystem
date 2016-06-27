<cfscript>
//================= Room Booking System / https://github.com/neokoenig =======================--->


// Default Datasource name as set in /CFIDE/administrator | Railo admin | Lucee admin.
// If you change this before installing, ensure you update request.dsn in /install/index.cfm
set(dataSourceName="roombooking");

// Setting URL rewriting to off by default, as running wheels in a subdirectory requires more complex configuration
set(URLRewriting="off");

// Reload Password: you'll definitely want to change this to something unique.
set(reloadPassword="roombooking");

//=====================================================================
//= 	Environment-agnostic settings
//=====================================================================
set(assetQueryString=true);
set(excludeFromErrorEmail="password,hashedpassword,passwordsalt,ssn");

// valid values are "session" or "cookie"
set(flashStorage="session");

// In this app, plugins are part of the source and not designed to be distributed in zip form
set(overwritePlugins=false);
set(deletePluginDirectories=false);

// Highlight defaults
set(functionName="highlight", tag="mark");

//=====================================================================
//= 	Localisation
//=====================================================================
set(localizatorGetLocalizationFromFile=true);
set(localizatorLanguageDefault="en_GB");
// NB, not putting this in the currentuser scope on purpose.
set(localizatorLanguageSession="session.lang");

//=====================================================================
//= 	Bootstrap 3 form Defaults: this is so you can more easily build
//=		Form fields without having to append/prepend markup
//=====================================================================
set(functionName="startFormTag");
set(functionName="submitTag", class="btn btn-primary", value="Save Changes");
set(functionName="checkBox,checkBoxTag", labelPlacement="aroundRight", prependToLabel="<div class=""checkbox"">", appendToLabel="</div>", uncheckedValue="0");
set(functionName="radioButton,radioButtonTag", labelPlacement="aroundRight", prependToLabel="<div class=""radio"">", appendToLabel="</div>");
set(functionName="textField,textFieldTag,select,selectTag,passwordField,passwordFieldTag,textArea,textAreaTag,fileFieldTag,fileField",
class="form-control",
labelClass="control-label",
labelPlacement="before",
prependToLabel="<div class=""form-group"">",
prepend="",
append="</div>"  );

set(functionName="dateTimeSelect,dateSelect", prepend="<div class=""form-group"">", append="</div>", timeSeparator="", minuteStep="5", secondStep="10", dateOrder="day,month,year", dateSeparator="", separator="");

set(functionName="errorMessagesFor", class="alert alert-dismissable alert-danger"" style=""margin-left:0;padding-left:26px;");
set(functionName="errorMessageOn", wrapperElement="div", class="alert alert-danger");
set(functionName="flash", prepend="<div class=""alert""><a class=""close"" data-dismiss=""alert"">&times;</a>", append="</div>");
set(functionName="flashMessages", prependToValue="<div class=""alert alert-dismissable alert-info""><a class=""close"" data-dismiss=""alert"">&times;</a>", appendToValue="</div>");
set(functionName="paginationLinks", prepend="<ul class=""pagination"">", append="</ul>", prependToPage="<li>", appendToPage="</li>", linkToCurrentPage=true, classForCurrent="active", anchorDivider="<li class=""disabled""><a href=""##"">...</a></li>");

</cfscript>
