<cfcomponent extends="wheelsMapping.Model">

	<cffunction name="init">
		<cfset table("tags")>
		<cfset uploadableFile(
			property="description"
			,destination=expandPath("/plugins/uploadablefiles/tests/assets/uploads")
		)>
	</cffunction>

</cfcomponent>