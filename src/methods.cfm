<cffunction name="uploadableFile" access="public" output="false" hint="model method to call to configure the upload">
	<cfargument name="property" type="string" required="true" hint="property that we want to upload files for">
	<cfargument name="destination" type="string" required="false" default="#expandPath(get('filePath'))#" hint="where to place the file after uploading">
	<cfargument name="message" type="string" required="false" default="Error during upload." hint="error message when an upload fails">
	<cfargument name="removeOnDelete" type="boolean" required="false" default="true" hint="removes the upload when the record is deleted">
	<cfset var loc = {}>
	
	<!--- setup class variable --->
	<cfset _uploadableFilesClassVariables()>
	<!--- inject callbacks --->
	<cfset _setupCallbacks()>
	
	<!--- get the model name for default --->
	<cfset loc.modelName = Lcase(ListLast(getMetaData(this).name, "."))>
	
	<!--- save the arguments passed in --->
	<cfset loc.args = duplicate(arguments)>
	<cfset loc.args.uploaded = false>
	<cfset loc.args.virtual = "_uf_original_#arguments.property#">
	
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
	
	<!--- 
	We need to be able to save the original value of the property in a virutal property.
	The whole point of this is because during an edit that you display the value of the
	property (like providing a link to the current file) and there are errors on the
	object, the property gets sets to an empty string.	
	 --->
	<cfset this[loc.args.virtual] = "">

</cffunction>

<cffunction name="uploadableFileFieldName" hint="call from outside your model within the controller to tell the plugin what form field to look for that doesn't follow conventions. there in no way to dynamically determine the form field name if convertions aren't followed.">
	<cfset var loc = {}>
	
	<cfloop collection="#arguments#" item="loc.i">
		<cfif StructKeyExists(variables.wheels.class._uploadableFiles, loc.i)>
			<cfset variables.wheels.class._uploadableFiles[loc.i].fileField = arguments[loc.i]>
		</cfif>
	</cfloop>
	
</cffunction>

<cffunction name="$PluginUploadableFileConfig" hint="sometimes you need to have a dynamic destination. in order to do this, we see if the destination ends with `()` and if so evaluate the method name">
	<cfargument name="key" type="string" required="true">
	<cfset var loc = {}>
	<cfset loc.config = variables.wheels.class._uploadableFiles[arguments.key]>
	<cfif Right(loc.config["destination"], 2) eq "()">
		<cfset loc.config["destination"] = evaluate(loc.config["destination"])>
	</cfif>
	<cfreturn loc.config>
</cffunction>

<cffunction name="wasUploaded" returntype="boolean" hint="tell whether an upload was performed for the property. can be used to by pass a validation during an update when a file isn't uploaded">
	<cfargument name="property" type="string" required="true">
	<cfreturn $PluginUploadableFileConfig(arguments.property).uploaded>
</cffunction>