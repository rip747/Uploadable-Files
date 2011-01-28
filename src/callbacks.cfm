<cffunction name="_UFuploadFile" returntype="void" output="false" hint="this will perform the file upload">
	<cfset var loc = {}>
	
	<!--- loop through and upload each file --->
	<cfloop collection="#variables.wheels.class._uploadableFiles#" item="loc.i">
		<!--- only upload if the property has a value. --->
		<cfif len(this[loc.i])>
			<!--- perform the upload and catch any errors --->
			<cfset loc.ret = _uploadFile(argumentCollection=variables.wheels.class._uploadableFiles[loc.i])>
			<cfif IsStruct(loc.ret)>
				<cfset this[loc.i] = loc.ret.serverfile>
			<cfelse>
				<cfset addError(property="#loc.i#", message="#variables.wheels.class._uploadableFiles[loc.i].message#")>
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

<cffunction name="_setupCallbacks" returntype="void" output="false">
	<cfset var loc = {}>

	<cfset $registerCallback("beforeValidation", "_UFuploadFile")>
	<cfset $registerCallback("beforeSave", "_UFRemoveProperties")>
	<cfset $registerCallback("afterSave", "_UFReaddProperties")>
	
</cffunction>