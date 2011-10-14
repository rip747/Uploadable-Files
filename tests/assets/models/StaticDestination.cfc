<cfcomponent extends="wheelsMapping.Model">

	<cffunction name="init">
		<cfset var loc = {}>
		<cfset loc.destination = expandPath("/plugins/uploadablefiles/tests/assets/uploads")>
		<cfset table("photos")>
		<cfset uploadableFile(
			property="filedata"
			,destination=loc.destination
		)>
	</cffunction>

</cfcomponent>