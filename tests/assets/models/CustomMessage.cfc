<cfcomponent extends="wheelsMapping.Model">

	<cffunction name="init">
		<cfset table("tags")>
		<cfset uploadableFile(
			property="description"
			,message="ohhh nooo! something went wrong!"
		)>
	</cffunction>

</cfcomponent>