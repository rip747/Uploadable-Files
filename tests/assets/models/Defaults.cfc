<cfcomponent extends="wheelsMapping.Model">

	<cffunction name="init">
		<cfset table("tags")>
		<cfset uploadableFile(
			property="description"
		)>
	</cffunction>

</cfcomponent>