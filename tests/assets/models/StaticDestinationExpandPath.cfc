<cfcomponent extends="wheelsMapping.Model">

	<cffunction name="init">
		<cfset table("photos")>
		<cfset uploadableFile(
			property="filedata"
			,destination=expandPath("/plugins/uploadablefiles/tests/assets/uploads")
		)>
	</cffunction>

</cfcomponent>