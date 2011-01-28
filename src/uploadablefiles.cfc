<cfcomponent output="false" mixin="model">

	<cffunction name="init" returntype="any" access="public" output="false">
		<cfset this.version = "1.1.1">
		<cfreturn this>
	</cffunction>
	
	<cfinclude template="config.cfm">
	<cfinclude template="methods.cfm">
	<cfinclude template="callbacks.cfm">
	<cfinclude template="upload.cfm">

</cfcomponent>