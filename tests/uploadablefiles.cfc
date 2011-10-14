<cfcomponent extends="wheelsMapping.test">

	<cffunction name="setup">
		<cfset loc.orgApp = duplicate(application)>
		<cfset loc.assetsPath = "/plugins/uploadablefiles/tests/assets">
		<cfset loc.assetsCPath = "plugins.uploadablefiles.tests.assets">
		<cfset application.wheels.cacheQueriesDuringRequest = false>
		<cfset application.wheels.controllerPath = "#loc.assetsPath#/controllers">
		<cfset application.wheels.modelPath = "#loc.assetsPath#/models">		
		<cfset application.wheels.modelComponentPath = "#loc.assetsCPath#.models">
		<cfset application.wheels.filePath = "#loc.assetsPath#/uploads">
		<cfset loc.imagePath = expandPath("#loc.assetsPath#/images/win8.jpg")>
		<cfset loc.tempImagePath = getTempDirectory()>
		<cfset request.cgi.CONTENT_TYPE = "multipart/form-data">
		<cfset loc.methods = {}>
		<cfset loc.methods["__UFCFFileUpload"] = __UFCFFileUpload>
		<cffile action="copy" source="#loc.imagePath#" destination="#loc.tempImagePath#">
	</cffunction>
	
	<cffunction name="teardown">
		<cfset application = loc.orgApp>
	</cffunction>

	<cffunction name="test_default_settings">
		<cfset photo = model("Defaults").findOne()>
		<cfset photo.inject = inject>
		<cfset photo.inject(loc.methods)>
		<cfset photo.filedata = loc.imagePath>
		<cfset form["defaults[filedata]"] = loc.imagePath>
		<cfset photo.valid()>
		<cfset assert("left(photo.filedata, 4) eq 'win8'")>
		<cfset assert("photo._uf_original_filedata eq ''")>
	</cffunction>
	
	<cffunction name="test_remove_on_delete_true">
		<cftransaction>
			<cfset photo = model("Defaults").findOne()>
			<cfset photo.inject = inject>
			<cfset photo.inject(loc.methods)>
			<cfset photo.filedata = loc.imagePath>
			<cfset form["defaults[filedata]"] = loc.imagePath>
			<cfset photo.valid()>
			<cfset photo.thisclass = "defraults">
			<cfset assert("left(photo.filedata, 4) eq 'win8'")>
			<cfset assert("photo._uf_original_filedata eq ''")>
			<cfset photo.delete()>
			<cfset loc.dir = application.wheels.filePath & "/#photo.filedata#">
			<cfset loc.dir = expandPath(loc.dir)>
			<cfset assert('!FileExists(loc.dir)')>
			<cftransaction action="rollback">
		<cftransaction>
	</cffunction>
	
	<cffunction name="test_remove_on_delete_false">
		<cftransaction>
			<cfset photo = model("RemoveOnDeleteFalse").findOne()>
			<cfset photo.inject = inject>
			<cfset photo.inject(loc.methods)>
			<cfset photo.filedata = loc.imagePath>
			<cfset form["RemoveOnDeleteFalse[filedata]"] = loc.imagePath>
			<cfset photo.valid()>
			<cfset assert("left(photo.filedata, 4) eq 'win8'")>
			<cfset assert("photo._uf_original_filedata eq ''")>
			<cfset photo.delete()>
			<cfset loc.dir = application.wheels.filePath & "/#photo.filedata#">
			<cfset loc.dir = expandPath(loc.dir)>
			<cfset assert('FileExists(loc.dir)')>
			<cftransaction action="rollback">
		<cftransaction>
	</cffunction>
	
	<cffunction name="test_static_destination">
		<cfset photo = model("StaticDestination").findOne()>
		<cfset photo.inject = inject>
		<cfset photo.inject(loc.methods)>
		<cfset photo.filedata = loc.imagePath>
		<cfset form["StaticDestination[filedata]"] = loc.imagePath>
		<cfset photo.valid()>
		<cfset assert("left(photo.filedata, 4) eq 'win8'")>
		<cfset assert("photo._uf_original_filedata eq ''")>
	</cffunction>
	
	<cffunction name="test_static_destination_expandpath">
		<cfset photo = model("StaticDestinationExpandPath").findOne()>
		<cfset photo.inject = inject>
		<cfset photo.inject(loc.methods)>
		<cfset photo.filedata = loc.imagePath>
		<cfset form["StaticDestinationExpandPath[filedata]"] = loc.imagePath>
		<cfset photo.valid()>
		<cfset assert("left(photo.filedata, 4) eq 'win8'")>
		<cfset assert("photo._uf_original_filedata eq ''")>
	</cffunction>
	
	<cffunction name="test_dynamic_destination">
		<cfset photo = model("DynamicDestination").findOne()>
		<cfset photo.inject = inject>
		<cfset photo.inject(loc.methods)>
		<cfset photo.filedata = loc.imagePath>
		<cfset form["DynamicDestination[filedata]"] = loc.imagePath>
		<cfset photo.thepath = "a">
		<cfset photo.valid()>
		<cfset assert("left(photo.filedata, 4) eq 'win8'")>
		<cfset assert("photo._uf_original_filedata eq ''")>
		<cfset assert("listlast(photo._uploadDir(), '/') eq 'a'")>
 		<cffile action="copy" source="#loc.imagePath#" destination="#loc.tempImagePath#">
		<cfset photo.thepath = "b">
		<cfset photo.valid()>
		<cfset assert("left(photo.filedata, 4) eq 'win8'")>
		<cfset assert("photo._uf_original_filedata eq ''")>
		<cfset assert("listlast(photo._uploadDir(), '/') eq 'b'")>
		<cffile action="copy" source="#loc.imagePath#" destination="#loc.tempImagePath#">
		<cfset photo.thepath = "c">
		<cfset photo.valid()>
		<cfset assert("left(photo.filedata, 4) eq 'win8'")>
		<cfset assert("photo._uf_original_filedata eq ''")>
		<cfset assert("listlast(photo._uploadDir(), '/') eq 'c'")>
	</cffunction>
	
	<cffunction name="test_custom_message">
		<cfset photo = model("CustomMessage").findOne()>
		<cfset loc.methods["__UFCFFileUpload"] = __UFCFFileUploadError>
		<cfset photo.inject = inject>
		<cfset photo.inject(loc.methods)>
		<cfset loc.imagePath = expandPath("#loc.assetsPath#/images/win9.jpg")>
		<cfset photo.filedata = loc.imagePath>
		<cfset form["CustomMessage[filedata]"] = loc.imagePath>
		<cfset photo.valid()>
		<cfset loc.errors = photo.allErrors()>
		<cfset assert("loc.errors[1]['message'] eq 'ohhh nooo! something went wrong!'")>
	</cffunction>
	
	<cffunction name="__UFCFFileUpload">
		<cfset var loc = {}>
		<cfset loc.cffile = {}>
		<cfset loc.cffile.serverfile = "win8.jpg">
		<cfset loc.cffile.serverFileExt = "jpg">
		<cfset loc.cffile.serverFileName = "win8">
		<cfreturn loc.cffile>
	</cffunction>
	
	<cffunction name="__UFCFFileUploadError">
		<cfthrow type="custom" message="blah blah">
	</cffunction>
	
	<cffunction name="inject">
		<cfargument name="methods" type="struct" required="true">
		<cfset structAppend(this, arguments.methods)>
		<cfset structAppend(variables, arguments.methods)>
	</cffunction>

</cfcomponent>