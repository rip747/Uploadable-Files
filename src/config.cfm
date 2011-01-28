<cffunction name="_uploadableFilesClassVariables" hint="create a class variable to hold the configuration">
	<cfif !StructKeyExists(variables.wheels.class, "_uploadableFiles")>
		<cfset variables.wheels.class._uploadableFiles = {}>
	</cfif>
</cffunction>