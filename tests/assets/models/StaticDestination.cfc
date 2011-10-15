<cfcomponent extends="wheelsMapping.Model">

	<cffunction name="init">
		<cfset var loc = {}>
		<cfset loc.destination = expandPath("/plugins/uploadablefiles/tests/assets/uploads")>
		<cfset table("tags")>
		<cfset uploadableFile(
			property="description"
			,destination=loc.destination
		)>
	</cffunction>

</cfcomponent>