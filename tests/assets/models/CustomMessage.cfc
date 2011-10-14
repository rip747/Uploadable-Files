<cfcomponent extends="wheelsMapping.Model">

	<cffunction name="init">
		<cfset table("photos")>
		<cfset uploadableFile(
			property="filedata"
			,message="ohhh nooo! something went wrong!"
		)>
	</cffunction>

</cfcomponent>