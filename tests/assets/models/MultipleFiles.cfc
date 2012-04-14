<cfcomponent extends="wheelsMapping.Model">

	<cffunction name="init">
		<cfset var loc = {}>
		<cfset loc.destination = expandPath("/plugins/uploadablefiles/tests/assets/uploads")>
		<cfset table("users")>
		
		<!--- 
		during testing, i can only substitute a single file for cffile
		since the first upload will move the file, the second one will
		always fail since the file is no longer there. for this reason
		i need to overload the action to "copy"
		 --->
		
		<cfset uploadableFile(
			property="city"
			,destination=loc.destination
			,action="copy"
		)>
		<cfset uploadableFile(
			property="zipcode"
			,destination=loc.destination
			,action="copy"
		)>
	</cffunction>

</cfcomponent>