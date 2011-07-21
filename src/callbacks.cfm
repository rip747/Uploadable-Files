<cffunction name="_UFuploadFile" returntype="void" output="false" hint="this will perform the file upload">
	<cfset var loc = {}>

	<!--- loop through and upload each file --->
	<cfloop collection="#variables.wheels.class._uploadableFiles#" item="loc.i">
		
		<cfset loc.args = $PluginUploadableFileConfig(loc.i)>
		
		<!--- only upload if the property has a value. --->
		<cfif len(this[loc.i])>
		
			<!--- perform the upload and catch any errors --->
			<cfset loc.ret = _uploadFile(argumentCollection=loc.args)>
			<cfif !StructIsEmpty(loc.ret)>
				<cfset this[loc.i] = loc.ret.serverfile>
				<cfset variables.wheels.class._uploadableFiles[loc.i].uploaded = true>
			<cfelse>
				<cfset addError(property="#loc.i#", message="#loc.args.message#")>
				<cfset this[loc.i] = "">
			</cfif>
			
		<cfelse>
		
			<cfif StructKeyExists(this, loc.args.virtual)>
				<cfset this[loc.i] = this[loc.args.virtual]>
			</cfif>

		</cfif>
	</cfloop>

</cffunction>

<cffunction name="_UFRemoveProperties" hint="this prevents your property from being set to null when updating a record and not uploading a file">
	<cfset var loc = {}>

	<!--- loop through the properties we handle --->
	<cfloop collection="#variables.wheels.class._uploadableFiles#" item="loc.i">
		<cfif !len(this[loc.i])>
			<cfset structDelete(this, loc.i, false)>
		</cfif>
	</cfloop>

</cffunction>

<cffunction name="_UFReaddProperties" hint="need to readd the property back after saving">
	<cfset var loc = {}>

	<!--- loop through the properties we handle --->
	<cfloop collection="#variables.wheels.class._uploadableFiles#" item="loc.i">
		<cfif !StructKeyExists(this, loc.i)>
			<cfset this[loc.i] = "">
		</cfif>
	</cfloop>

</cffunction>

<cffunction name="_UFDeleteUpload" hint="deletes the upload when the record is deleted">
	<cfset var loc = {}>

	<!--- loop through the properties we handle --->
	<cfloop collection="#variables.wheels.class._uploadableFiles#" item="loc.i">
		<cfset loc.config = $PluginUploadableFileConfig(loc.i)>
		<cfif loc.config["removeOnDelete"]>
			<cfif StructKeyExists(this, loc.i) AND len(this[loc.i])>
				<cfset loc.theFile = listappend(loc.config["destination"], this[loc.i], "\/")>
				<cfif FileExists(loc.theFile)>
					<cffile action="delete" file="#loc.theFile#">
				</cfif>
			</cfif>
		</cfif>
	</cfloop>

</cffunction>

<cffunction name="_UFSetVirtualProperty">
	<cfset var loc = {}>

 	<!--- loop through the properties we handle --->
	<cfloop collection="#variables.wheels.class._uploadableFiles#" item="loc.i">
		<cfif StructKeyExists(arguments, loc.i)>
			<cfset this[variables.wheels.class._uploadableFiles[loc.i].virtual] = arguments[loc.i]>
		</cfif>
	</cfloop>

</cffunction>

<cffunction name="_setupCallbacks" returntype="void" output="false">
	<cfset var loc = {}>

	<cfset beforeValidation("_UFuploadFile")>
	<cfset beforeSave("_UFRemoveProperties")>
	<cfset afterSave("_UFReaddProperties")>
	<cfset afterDelete("_UFDeleteUpload")>
	<cfset afterFind("_UFSetVirtualProperty")>
	
</cffunction>