<cfcomponent extends="wheelsMapping.Model">

	<cffunction name="init">
		<cfset table("photos")>
		<cfset uploadableFile(
			property="filedata"
			,destination="_uploadDir"
		)>
	</cffunction>
	
	<cffunction name="_uploadDir">
		<cfset var loc = {}>
		<cfset loc.dir = expandPath("/plugins/uploadablefiles/tests/assets/dynamic_uploads")>
		<cfset loc.dir = ListChangeDelims(loc.dir, "/", "\")>
		<cfreturn ListAppend(loc.dir, this.thepath, "/")>
	</cffunction>

</cfcomponent>