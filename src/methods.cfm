<cffunction name="uploadableFile" access="public" output="false" hint="model method to call to configure the upload">
	<cfargument name="property" type="string" required="true" hint="property that we want to upload files for">
	<cfargument name="destination" type="string" required="false" default="#expandPath(get('filePath'))#" hint="where to place the file after uploading">
	<cfargument name="message" type="string" required="false" default="Error during photo upload." hint="error message when an upload fails">
	<cfset var loc = {}>
	
	<!--- setup class variable --->
	<cfset _uploadableFilesClassVariables()>
	<!--- inject callbacks --->
	<cfset _setupCallbacks()>
	
	<!--- get the model name for default --->
	<cfset loc.modelName = Lcase(ListLast(getMetaData(this).name, "."))>
	
	<!--- save the arguments passed in --->
	<cfset loc.args = duplicate(arguments)>
	
	<!--- setup container for property --->
	<cfset variables.wheels.class._uploadableFiles[arguments.property] = {}>
	
	<!--- 
	by default, the form fieldname is modelName[property]
	you can over write this using uploadableFileFieldName()
	 --->
	<cfset variables.wheels.class._uploadableFiles[arguments.property].fileField = "#loc.modelName#[#arguments.property#]">
	
	<!--- append all argument to the class variable --->
	<cfset structDelete(loc.args, "property", false)>
	<cfset structAppend(variables.wheels.class._uploadableFiles[arguments.property], loc.args)>

</cffunction>

<cffunction name="uploadableFileFieldName" hint="call from outside your model within the controller to tell the plugin what form field to look for that doesn't follow conventions. there in no way to dynamically determine the form field name if convertions aren't followed.">
	<cfset var loc = {}>
	
	<cfloop collection="#arguments#" item="loc.i">
		<cfif StructKeyExists(variables.wheels.class._uploadableFiles, loc.i)>
			<cfset variables.wheels.class._uploadableFiles[loc.i].fileField = arguments[loc.i]>
		</cfif>
	</cfloop>
	
</cffunction>