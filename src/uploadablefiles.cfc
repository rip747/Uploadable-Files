<cfcomponent output="false" mixin="model">

	<cffunction name="init" returntype="any" access="public" output="false">
		
		<cfset this.version = "1.1.1,1.1.2,1.1.3,1.1.4,1.1.5,1.1.6">
		<cfreturn this>
		
	</cffunction>
	
	<cffunction name="uploadableFile" access="public" output="false" hint="model method to call to configure the upload">
		<cfargument name="property" type="string" required="true" hint="property that we want to upload files for">
		<cfargument name="destination" type="string" required="false" default="#expandPath(get('filePath'))#" hint="where to place the file after uploading">
		<cfargument name="message" type="string" required="false" default="Error during upload." hint="error message when an upload fails">
		<cfargument name="removeOnDelete" type="boolean" required="false" default="true" hint="removes the upload when the record is deleted">
		<cfargument name="nullWhenBlank" type="boolean" required="false" default="false" hint="tells the plugin to not to remove the property when doing an update and the file is blank thus allowing the column to be null. by default the plugin prevents this.">
		<cfset var loc = {}>
		
		<!--- setup class variable --->
		<cfset _UFInitalize()>
		<!--- inject callbacks --->
		<cfset _UFSetupCallbacks()>
		
		<!--- get the model name for default --->
		<cfset loc.modelName = Lcase(ListLast(getMetaData(this).name, "."))>
		
		<!--- save the arguments passed in --->
		<cfset loc.args = duplicate(arguments)>
		<cfset loc.args.virtual = "_uf_original_#arguments.property#">
		<!--- 
		by default, the form fieldname is modelName[property]
		you can over write this using uploadableFileFieldName()
		 --->
		<cfset loc.args.fileField = "#loc.modelName#[#arguments.property#]">
		
		<!--- setup container for property --->
		<cfset variables.wheels.class._uploadableFiles[arguments.property] = loc.args>
		
		<!--- 
		We need to be able to save the original value of the property in a virutal property.
		The whole point of this is because during an edit that you display the value of the
		property (like providing a link to the current file) and there are errors on the
		object, the property gets sets to an empty string.	
		 --->
		<cfset this[loc.args.virtual] = "">

	</cffunction>
	
	<cffunction name="uploadableFileFieldName" hint="call from outside your model within the controller to tell the plugin what form field to look for that doesn't follow conventions. there in no way to dynamically determine the form field name if convertions aren't followed.">
		<cfset var loc = {}>
		
		<cfloop collection="#arguments#" item="loc.i">
			<cfif StructKeyExists(variables.wheels.class._uploadableFiles, loc.i)>
				<cfset variables.wheels.class._uploadableFiles[loc.i].fileField = arguments[loc.i]>
			</cfif>
		</cfloop>
		
	</cffunction>
	
	<!--- init  --->
	<cffunction name="_UFInitalize" hint="create a class variable to hold the configuration">
		
		<cfif !StructKeyExists(variables.wheels.class, "_uploadableFiles")>
			<cfset variables.wheels.class._uploadableFiles = {}>
		</cfif>
		
	</cffunction>
	
	<cffunction name="_UFCallBackUploadFile" returntype="void" output="false" hint="this will perform the file upload">
		<cfset var loc = {}>

		<cfset loc.data = _getUFData()>

		<cfloop collection="#loc.data#" item="loc.key">
			<cfset loc.config = _getUFProperty(loc.key, true)>
			<!--- only upload if the property has a value. and the form field is present --->
			<cfif propertyIsPresent(loc.key) && StructKeyExists(form, loc.config.filefield)>
				<!--- perform the upload and catch any errors --->
				<cfset loc.ret = _UFHandleUpload(argumentCollection=loc.config)>
				<cfif !StructIsEmpty(loc.ret)>
					<cfset _setUFData(loc.config.property, loc.ret)>
					<cfset this[loc.key] = loc.ret.serverfile>
					<cfset this[loc.config.virtual] = loc.ret.serverfile>
				<cfelse>
					<cfset addError(property="#loc.key#", message="#loc.config.message#")>
					<cfset this[loc.key] = "">
				</cfif>
			<cfelseif hasProperty(loc.key) && hasProperty(loc.config.virtual) && !loc.config.nullWhenBlank>
				<cfset this[loc.key] = this[loc.config.virtual]>
			</cfif>
		</cfloop>

	</cffunction>
	
	<cffunction name="_UFCallBackRemoveProperties" hint="this prevents your property from being set to null when updating a record and not uploading a file">
		<cfset var loc = {}>

		<!--- loop through the properties we handle --->
		<cfset loc.data = _getUFData()>
		<cfloop collection="#loc.data#" item="loc.key">
			<cfset loc.config = _getUFProperty(loc.key)>
			<cfif hasProperty(loc.key) && !len(this[loc.key]) && !loc.config.nullWhenBlank>
				<cfset structDelete(this, loc.key, false)>
			</cfif>
		</cfloop>

	</cffunction>
	
	<cffunction name="_UFCallBackReaddProperties" hint="need to readd the property back after saving">
		<cfset var loc = {}>

		<!--- loop through the properties we handle --->
		<cfset loc.data = _getUFData()>
		<cfloop collection="#loc.data#" item="loc.key">
			<cfif !hasProperty(loc.key)>
				<cfset loc.config = _getUFProperty(loc.key)>
				<cfset this[loc.key] = this[loc.config.virtual]>
			</cfif>
		</cfloop>

	</cffunction>
	
	<cffunction name="_UFCallBackDeleteUpload" hint="deletes the upload when the record is deleted">
		<cfset var loc = {}>
	
		<!--- loop through the properties we handle --->
		<cfset loc.data = _getUFData()>
		<cfloop collection="#loc.data#" item="loc.key">
			<cfset loc.config = _getUFProperty(loc.key, true)>
			<cfif loc.config["removeOnDelete"]>
				<cfif propertyIsPresent(loc.key)>
					<cfset loc.theFile = listappend(loc.config["destination"], this[loc.key], "\/")>
					<cfif FileExists(loc.theFile)>
						<cffile action="delete" file="#loc.theFile#">
					</cfif>
				</cfif>
			</cfif>
		</cfloop>

	</cffunction>
	
	<cffunction name="_UFCallBackSetVirtualProperties">
		<cfset var loc = {}>

	 	<!--- loop through the properties we handle --->
	 	<cfset loc.data = _getUFData()>
		<cfloop collection="#loc.data#" item="loc.key">
			<cfset loc.config = _getUFProperty(loc.key)>
			<cfif StructKeyExists(arguments, loc.key)>
				<cfset this[loc.config.virtual] = arguments[loc.key]>
			</cfif>
		</cfloop>

	</cffunction>
	
	<cffunction name="_UFSetupCallbacks" returntype="void" output="false">
	
		<cfset beforeValidation("_UFCallBackuploadFile")>
		<cfset beforeSave("_UFCallBackRemoveProperties")>
		<cfset afterSave("_UFCallBackReaddProperties")>
		<cfset afterDelete("_UFCallBackDeleteUpload")>
		<cfset afterFind("_UFCallBackSetVirtualProperties")>
		
	</cffunction>
	
	<!--- accessors --->
	<cffunction name="_getUFData" hint="return the class variables container for the plugin">
		<cfreturn variables.wheels.class._uploadableFiles>
	</cffunction>
	
	<cffunction name="_setUFData" hint="return the class variables container for the plugin">
		<cfargument name="key" type="string" required="true">
		<cfargument name="data" type="any" required="true">
		<cfset variables.wheels.class._uploadableFiles[arguments.key]["data"] = arguments.data>
	</cffunction>	
	
	<cffunction name="_getUFProperty" hint="sometimes you need to have a dynamic destination. in order to do this, we see if the destination ends with `()` and if so evaluate the method name">
		<cfargument name="key" type="string" required="true">
		<cfargument name="eval" type="boolean" required="false" default="false">
		<cfset var loc = {}>
		<cfset loc.config = variables.wheels.class._uploadableFiles[arguments.key]>
		<cfif arguments.eval && IsValid("variablename", loc.config['destination']) && StructKeyExists(this, loc.config['destination']) && IsCustomFunction(this[loc.config['destination']])>
			<cfinvoke component="#this#" method="#loc.config['destination']#" returnvariable="loc.ret">
			<cfset loc.config['destination'] = loc.ret>
		</cfif>
		<cfreturn loc.config>
	</cffunction>

	<!--- private methods --->
	<cffunction name="_UFHandleUpload" returntype="any" output="false">
		<cfargument name="property" type="string" required="true">
		<cfargument name="fileField" type="string" required="true">
		<cfargument name="destination" type="string" required="false" default="#expandpath(get('filePath'))#">
		<cfset var loc = {}>
		
		<cfset loc.ret = {}>
		<cfset loc.mp = "multipart/form-data">
		
		<!---
		see if the content_type is mulitpart which means a file was uploaded
		if not get out. no use wasting time
		--->
		<cfif not left(request.cgi.CONTENT_TYPE, len(loc.mp)) eq loc.mp>
			<cfreturn loc.ret>
		</cfif>
	
		<!--- now that we have our field name, let's look in the form scope to see if it's blank --->
		<cfif not len(form[arguments.fileField])>
			<cfreturn loc.ret>
		</cfif>
	
		<!--- create the a default set of arguments to pass to cffileupload --->
		<cfset loc.args = {}>
		<cfset loc.args.action = "upload">
		<cfset loc.args.filefield = arguments.fileField>
		<cfset loc.args.destination = arguments.destination>
		<cfset loc.args.nameconflict = "MAKEUNIQUE">

		<!--- remove the fieldName, destination from the arguments scope for overloading --->
		<cfset structdelete(arguments, "fileField", false)>
		<cfset structdelete(arguments, "destination", false)>
		
		<!--- append and oveerwrite the defaults with any extra arguments --->
		<cfset structappend(loc.args, arguments, true)>

		<!--- upload the file --->
		<cftry>
			<cfset loc.ret = _UFCFFileUpload(
					argumentCollection=loc.args
				)>
			<cfcatch type="any">
				<cfset _setUFData(arguments.property, cfcatch)>
			</cfcatch>
		</cftry>
	
		<cfreturn loc.ret>
		
	</cffunction>
		
	<cffunction name="_UFCFFileUpload" returntype="struct" output="false">
		<cfargument name="deleteBadFile" type="boolean" required="false" default="true" hint="should we delete an invalid files that are uploaded from the temp directory.">
		<cfargument name="badExtensions" type="string" required="false" default="" hint="appends the internal extension list. any file with these extensions is automatically invalid.">
		<cfargument name="mimeTypes" type="struct" required="false" default="#structnew()#" hint="appends or replace the internal list of mimetypes with your own custom list.">
		<cfset var loc = {}>
		
		<cfset loc.badExtensions = "cfm,cfml,cfc,dbm,jsp,asp,aspx,exe,php,cgi,shtml">
		<cfset loc.mimetypes = {}>
		<!--- pdf --->
		<cfset loc.mimetypes.pdf = "application/pdf,application/x-pdf,app/pdf">
		<!--- office --->
		<cfset loc.mimetypes.ppt = "application/vnd.ms-powerpoint">
		<cfset loc.mimetypes.xls = "application/vnd.ms-excel">
		<cfset loc.mimetypes.doc = "application/msword">
		<cfset loc.mimetypes.pub = "application/x-mspublisher,application/vnd.ms-publisher">
		<cfset loc.mimetypes.docm = "application/vnd.ms-word.document.macroEnabled.12">
		<cfset loc.mimetypes.docx = "application/vnd.openxmlformats-officedocument.wordprocessingml.document">
		<cfset loc.mimetypes.dotm = "application/vnd.ms-word.template.macroEnabled.12">
		<cfset loc.mimetypes.dotx = "application/vnd.openxmlformats-officedocument.wordprocessingml.template">
		<cfset loc.mimetypes.potm = "application/vnd.ms-powerpoint.template.macroEnabled.12">
		<cfset loc.mimetypes.potx = "application/vnd.openxmlformats-officedocument.presentationml.template">
		<cfset loc.mimetypes.ppam = "application/vnd.ms-powerpoint.addin.macroEnabled.12">
		<cfset loc.mimetypes.ppsm = "application/vnd.ms-powerpoint.slideshow.macroEnabled.12">
		<cfset loc.mimetypes.ppsx = "application/vnd.openxmlformats-officedocument.presentationml.slideshow">
		<cfset loc.mimetypes.pptm = "application/vnd.ms-powerpoint.presentation.macroEnabled.12">
		<cfset loc.mimetypes.pptx = "application/vnd.openxmlformats-officedocument.presentationml.presentation">
		<cfset loc.mimetypes.xlam = "application/vnd.ms-excel.addin.macroEnabled.12">
		<cfset loc.mimetypes.xlsb = "application/vnd.ms-excel.sheet.binary.macroEnabled.12">
		<cfset loc.mimetypes.xlsm = "application/vnd.ms-excel.sheet.macroEnabled.12">
		<cfset loc.mimetypes.xlsx = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet">
		<cfset loc.mimetypes.xltm = "application/vnd.ms-excel.template.macroEnabled.12">
		<cfset loc.mimetypes.xltx = "application/vnd.openxmlformats-officedocument.spreadsheetml.template">
		<!--- images --->
		<cfset loc.mimetypes.jpg = "image/jpg,image/pjpg,image/jpeg,image/pjpeg">
		<cfset loc.mimetypes.jpeg = "image/jpg,image/pjpg,image/jpeg,image/pjpeg">
		<cfset loc.mimetypes.gif = "image/gif">
		<cfset loc.mimetypes.png = "image/png">
		
		<!--- append our mime types with any custom ones --->
		<cfif not structisempty(arguments.mimeTypes)>
			<cfset structappend(loc.mimetypes, arguments.mimeTypes, true)>
		</cfif>
		<cfset structdelete(arguments, "mimeTypes")>
		
		<!--- append our badExtensions with any custom ones --->
		<cfset loc.badExtensions = listappend(loc.badExtensions, arguments.badExtensions)>
		<cfset structdelete(arguments, "badExtensions")>
		
		<!--- the result to use internally --->
		<cfset arguments.result = "loc.cffile">
	
		<!---
			intercept the upload destination and set it to the tempdirectory,
			save it so we can move the file later
		 --->
		<cfset loc.destination = arguments.destination>
		<cfset arguments.destination = getTempDirectory()>
	
		<!--- execute upload --->
		<cfset loc.cffile = __UFCFFileUpload(argumentCollection=arguments)>
	
		<!--- get the full filename that was uploaded --->
		<cfset loc.fileuploaded = arguments.destination & loc.cffile["serverFile"]>
	
		<!--- try to get the mimetype of the uploaded file --->
		<cfset loc.filemimetype = getPageContext().getServletContext().getMimeType(loc.fileuploaded)>
	
		<cfif
			listfindnocase(loc.badExtensions, loc.cffile["serverFileExt"])
			or not structkeyexists(loc.mimetypes, loc.cffile["serverFileExt"])
			or (structkeyexists(loc, "filemimetype") && not listfindnocase(loc.mimetypes[loc.cffile["serverFileExt"]], loc.filemimetype))>
			<cfif arguments.deleteBadFile>
				<cffile action="delete" file="#loc.fileuploaded#">
			</cfif>
			<cfthrow type="Custom" message="Invalid file type">
		</cfif>
		
		<!--- full path to move the file to --->
		<cfset loc.destination = ListChangeDelims(loc.destination, "/", "\")>
		<cfset loc.finaldestination = listappend(loc.destination, loc.cffile["serverFile"], "/")>
		
		<!--- handle makeunique when moving --->
		<cfif structkeyexists(arguments, "nameconflict") and arguments.nameconflict eq "makeunique">
		
			<cfif fileexists(loc.finaldestination)>
				<cfset loc.cffile["serverFileName"] = loc.cffile["serverFileName"] & gettickcount()>
				<cfset loc.cffile["serverFile"] = listappend(loc.cffile["serverFileName"], loc.cffile["serverFileExt"], ".")>
				<cfset loc.finaldestination = listappend(loc.destination, loc.cffile["serverFile"], "\/")>
			</cfif>
		
		</cfif>

		<!--- forgot to handle mode in unix --->
		<cfset loc.args = {}>
		<cfset loc.args.action = "move">
		<cfif structkeyexists(arguments, "action") AND ListFindNoCase("move,copy", arguments.action)>
			<cfset loc.args.action = "#arguments.action#">
		</cfif>
		<cfset loc.args.source = "#loc.fileuploaded#">
		<cfset loc.args.destination = "#loc.finaldestination#">
		<cfif structkeyexists(arguments, "mode")>
			<cfset loc.args.mode = "#arguments.mode#">
		</cfif>

		<!--- move the file --->
		<cffile attributeCollection="#loc.args#">
	
		<!--- append the mimetype to the returning structure for convinence --->
		<cfset loc.cffile.mimetype = listfirst(loc.mimetypes[loc.cffile["serverFileExt"]])>
		<cfif structkeyexists(loc, "filemimetype")>
			<cfset loc.cffile.mimetype = loc.filemimetype>
		</cfif>
		
		<cfreturn loc.cffile>
		
	</cffunction>
	
	<cffunction name="__UFCFFileUpload">
		<cfset var loc = {}>
		<cffile attributeCollection="#arguments#">
		<cfreturn loc.cffile>
	</cffunction>

</cfcomponent>