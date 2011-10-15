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
		<cfset application.wheels.transactionMode = "none">
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
		<cfset obj = model("Defaults").findOne()>
		<cfset obj.inject = inject>
		<cfset obj.inject(loc.methods)>
		<cfset obj.description = loc.imagePath>
		<cfset form["defaults[description]"] = loc.imagePath>
		<cfset obj.valid()>
		<cfset assert("left(obj.description, 4) eq 'win8'")>
	</cffunction>
	
	<cffunction name="test_remove_on_delete_true">
		<cftransaction action="begin">
			<cfset obj = model("Defaults").findOne()>
			<cfset obj.inject = inject>
			<cfset obj.inject(loc.methods)>
			<cfset obj.description = loc.imagePath>
			<cfset form["defaults[description]"] = loc.imagePath>
			<cfset obj.save()>
			<cfset loc.objProperties = duplicate(obj.properties())>
			<cfset obj.delete()>
			<cftransaction action="rollback" />
		</cftransaction>
		<cfset assert("left(loc.objProperties.description, 4) eq 'win8'")>
		<cfset loc.dir = application.wheels.filePath & "/#loc.objProperties.description#">
		<cfset loc.dir = expandPath(loc.dir)>
		<cfset assert('!FileExists(loc.dir)')>
	</cffunction>
	
	<cffunction name="test_remove_on_delete_false">
		<cftransaction action="begin">
			<cfset obj = model("RemoveOnDeleteFalse").findOne()>
			<cfset obj.inject = inject>
			<cfset obj.inject(loc.methods)>
			<cfset obj.description = loc.imagePath>
			<cfset form["RemoveOnDeleteFalse[description]"] = loc.imagePath>
			<cfset obj.save()>
			<cfset loc.objProperties = duplicate(obj.properties())>
			<cfset obj.delete()>
			<cftransaction action="rollback" />
		</cftransaction>
		<cfset assert("left(loc.objProperties.description, 4) eq 'win8'")>
		<cfset loc.dir = application.wheels.filePath & "/#loc.objProperties.description#">
		<cfset loc.dir = expandPath(loc.dir)>
		<cfset assert('FileExists(loc.dir)')>
	</cffunction>
	
	<cffunction name="test_on_create_property_value_is_the_description_of_the_upload">
		<cftransaction action="begin">
			<cfset obj = model("Defaults").new()>
			<cfset obj.inject = inject>
			<cfset obj.inject(loc.methods)>
			<cfset obj.description = loc.imagePath>
			<cfset obj.parentid = 5>
			<cfset obj.name = "fruity!">
			<cfset form["defaults[description]"] = loc.imagePath>
			<cfset obj.save(reload=true)>
			<cfset loc.objProperties = duplicate(obj.properties())>
			<cftransaction action="rollback" />
		</cftransaction>
		<cfset assert("left(loc.objProperties.description, 4) eq 'win8'")>
	</cffunction>
	
	<cffunction name="test_updating_with_nullWhenBlank_set_to_false_the_property_should_retain_value">
		<cftransaction action="begin">
			<cfset obj = model("Defaults").findOne()>
			<cfset obj.inject = inject>
			<cfset obj.inject(loc.methods)>
			<cfset obj.description = loc.imagePath>
			<cfset form["defaults[description]"] = loc.imagePath>
			<cfset obj.save()>
			<cfset loc.objPropertiesCreate = duplicate(obj.properties())>
			<cfset obj = model("Defaults").findOneById(loc.objPropertiesCreate.id)>
			<cfset loc.objPropertiesFind = duplicate(obj.properties())>
			<cfset obj.description = "">
			<cfset obj.save()>
			<cfset loc.objPropertiesUpdate = duplicate(obj.properties())>
			<cftransaction action="rollback" />
		</cftransaction>
		<cfset assert("left(loc.objPropertiesCreate.description, 4) eq 'win8'")>
		<cfset assert("left(loc.objPropertiesFind.description, 4) eq 'win8'")>
		<cfset assert("left(loc.objPropertiesUpdate.description, 4) eq 'win8'")>
	</cffunction>
	
	<cffunction name="test_updating_with_nullWhenBlank_set_to_true_the_property_should_be_empty_string">
		<cftransaction action="begin">
			<cfset obj = model("DefaultsNullWhenBlankTrue").findOne()>
			<cfset obj.inject = inject>
			<cfset obj.inject(loc.methods)>
			<cfset obj.description = loc.imagePath>
			<cfset form["DefaultsNullWhenBlankTrue[description]"] = loc.imagePath>
			<cfset obj.save()>
			<cfset loc.objPropertiesCreate = duplicate(obj.properties())>
			<cfset obj = model("DefaultsNullWhenBlankTrue").findOneById(loc.objPropertiesCreate.id)>
			<cfset loc.objPropertiesFind = duplicate(obj.properties())>
			<cfset obj.description = "">
			<cfset obj.save()>
			<cfset loc.objPropertiesUpdate = duplicate(obj.properties())>
			<cftransaction action="rollback" />
		</cftransaction>
		<cfset assert("left(loc.objPropertiesCreate.description, 4) eq 'win8'")>
		<cfset assert("left(loc.objPropertiesFind.description, 4) eq 'win8'")>
		<cfset assert("loc.objPropertiesUpdate.description eq ''")>
	</cffunction>
	
	<cffunction name="test_static_destination">
		<cfset obj = model("StaticDestination").findOne()>
		<cfset obj.inject = inject>
		<cfset obj.inject(loc.methods)>
		<cfset obj.description = loc.imagePath>
		<cfset form["StaticDestination[description]"] = loc.imagePath>
		<cfset obj.valid()>
		<cfset assert("left(obj.description, 4) eq 'win8'")>
	</cffunction>
	
	<cffunction name="test_static_destination_expandpath">
		<cfset obj = model("StaticDestinationExpandPath").findOne()>
		<cfset obj.inject = inject>
		<cfset obj.inject(loc.methods)>
		<cfset obj.description = loc.imagePath>
		<cfset form["StaticDestinationExpandPath[description]"] = loc.imagePath>
		<cfset obj.valid()>
		<cfset assert("left(obj.description, 4) eq 'win8'")>
	</cffunction>
	
	<cffunction name="test_dynamic_destination">
		<cfset obj = model("DynamicDestination").findOne()>
		<cfset obj.inject = inject>
		<cfset obj.inject(loc.methods)>
		<cfset obj.description = loc.imagePath>
		<cfset form["DynamicDestination[description]"] = loc.imagePath>
		<cfset obj.thepath = "a">
		<cfset obj.valid()>
		<cfset assert("left(obj.description, 4) eq 'win8'")>
		<cfset assert("listlast(obj._uploadDir(), '/') eq 'a'")>
 		<cffile action="copy" source="#loc.imagePath#" destination="#loc.tempImagePath#">
		<cfset obj.thepath = "b">
		<cfset obj.valid()>
		<cfset assert("left(obj.description, 4) eq 'win8'")>
		<cfset assert("listlast(obj._uploadDir(), '/') eq 'b'")>
		<cffile action="copy" source="#loc.imagePath#" destination="#loc.tempImagePath#">
		<cfset obj.thepath = "c">
		<cfset obj.valid()>
		<cfset assert("left(obj.description, 4) eq 'win8'")>
		<cfset assert("listlast(obj._uploadDir(), '/') eq 'c'")>
	</cffunction>
	
	<cffunction name="test_custom_message">
		<cfset obj = model("CustomMessage").findOne()>
		<cfset loc.methods["__UFCFFileUpload"] = __UFCFFileUploadError>
 		<cfset obj.inject = inject>
		<cfset obj.inject(loc.methods)>
		<cfset loc.imagePath = expandPath("#loc.assetsPath#/images/win9.jpg")>
		<cfset obj.description = loc.imagePath>
		<cfset form["CustomMessage[description]"] = loc.imagePath>
		<cfset obj.valid()>
		<cfset loc.errors = obj.allErrors()>
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