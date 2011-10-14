<cfcomponent extends="wheelsMapping.Model">

	<cffunction name="init">
		<cfset table("photos")>
		<cfset uploadableFile(
			property="filedata"
		)>
	</cffunction>

</cfcomponent>