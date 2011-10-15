<cfcomponent extends="wheelsMapping.Model">

	<cffunction name="init">
		<cfset table("tags")>
		<cfset uploadableFile(
			property="description"
			,nullWhenBlank=true
		)>
	</cffunction>

</cfcomponent>