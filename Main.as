package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.system.Security;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.utils.setInterval;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import flash.display.StageDisplayState;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	//import flash.filesystem.File;
	
	
	public class Main extends MovieClip {
		
		public static var DEBUG_TRACE:Boolean = true;
		public static var rt:Main;
		
		// ---------------------------------------------------------------
		
		public static var CONFIG_XML:String = "app.xml";
		
		// ค่าที่อ่านได้จาก config file
		public static var CONFIG_AUTH:String;
		public static var CONFIG_SERVER_URL:String;
		public static var CONFIG_STEP_QUERY:Number;
		public static var CONFIG_STEP_REFRESH_UI:Number;
		// ---------------------------------------------------------------

		private var clockIntervalID:uint;
		
		// นับ step ละ 1s
		private var stepIntervalID:uint;
		private var stepCnt:Number;
		private var httpService:HTTPService;
		
		public function Main() {
			
			// เก็บ global reference
			Main.rt 					= this;
			this.stepCnt 				= 0; 
			this.modalPanel.visible 	= false;
			this.clearUI();
		
			try{
				this.stage.scaleMode 	= StageScaleMode.EXACT_FIT;
				this.stage.align 		= StageAlign.TOP;
				Security.exactSettings 	= false;
			}catch(err:Error){}
			
			// -------------------------------------------------------------------
			// -------------------------------------------------------------------
			// อ่านค่า config
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, function(e:Event) {
				
				// อ่านค่า config.xml เรียบร้อยแล้ว
				var responseXML:XML = new XML(e.target.data);
				trace("--------------------------------");
				trace("LOADED - config file");
				trace("--------------------------------");
				
				var config:XML = responseXML;
				if(config.auth.length() < 1
					|| config.serverURL.length() < 1
					|| config.stepQuery.length() < 1
					|| config.stepRefreshUI.length() < 1
				){
					failedOnLoadConfig();
					return;
				}
				Main.CONFIG_AUTH 						= config.auth;
				Main.CONFIG_SERVER_URL 					= config.serverURL;
				Main.CONFIG_STEP_QUERY 					= Utils.parse(config.stepQuery);
				Main.CONFIG_STEP_REFRESH_UI 			= Utils.parse(config.stepRefreshUI);
				
				Main.rt.stepIntervalID = setInterval(function(){
												
					var isQuery:Boolean = false;
					var isRefreshUI:Boolean = false;
					if(stepCnt % Main.CONFIG_STEP_QUERY == 0){
						
						// query and ui
						isQuery = true;
						doQuery();
					}
					if(stepCnt % Main.CONFIG_STEP_REFRESH_UI == 0 && !isQuery){
						
						// ui
						isRefreshUI = true;
						
					}
					//trace("step:", stepCnt, " query:",isQuery, " ui:", isUpdateUI);
					
					stepCnt++;
					if(stepCnt == Main.CONFIG_STEP_REFRESH_UI * Main.CONFIG_STEP_QUERY) stepCnt = 0;
					
				}, 100);
				
				// นาฬิกา 
			 	Main.rt.clockIntervalID = setInterval(function(){ updateClockUI();}, (60 * 1000));
				updateClockUI();
			});
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event) {
										   
				// อ่านค่า config.xml ไม่สำเร็จ (ปิดโปรแกรม)
				var responseXML:XML = new XML(e.target.data);
				trace("--------------------------------");
				trace("FAILED - config file");
				trace("--------------------------------");
				failedOnLoadConfig();
			});
			loader.load(new URLRequest("./" + Main.CONFIG_XML));
			
			//try { stage.displayState=StageDisplayState.FULL_SCREEN; }catch(err:Error){}
			
			// -------------------------------------------------------------------
			// -------------------------------------------------------------------
			//var prefsFile:flash.filesystem.File = new flash.filesystem.File("c:\\comportservice\\test.txt");
			//var desktop:File = File.desktopDirectory;			
			//(Main.rt.debugTxt as TextField).text = (File.desktopDirectory.nativePath);
			/*
			var folderURI="file:///c:/comportservice";
			fileList =new Array();
			paths="";
			
			function listFile(paths){
				files=[]
				folds=[]	
				files=FLfile.listFolder(paths,"files");	
				for(i=0;i<files.length;i++){
				fileList.push(paths+"/"+filesfolds=FLfile.listFolder(paths,"directories");
				for(j=0;j<folds.length;j++){
					
					listFile(paths+"/"+folds[j])
				}
			}
			listFile(folderURI);
			fl.trace(String(fileList).split(",").join("\n
			*/
			/*
			
			this.hiddenQueryButton.addEventListener(MouseEvent.CLICK, function(e:Event) {
				startQueryAndUpdateUI();
			});
			*/
			this.hiddenToggleButton.addEventListener(MouseEvent.CLICK, function(e:Event) {
				try { 
					if (stage.displayState == StageDisplayState.NORMAL) {
						stage.displayState=StageDisplayState.FULL_SCREEN;
					} else {
						stage.displayState=StageDisplayState.NORMAL;
					}
				}catch(err:Error){}
			});
		}
		
		private function doQuery():void{
			
			if(this.httpService != null) this.httpService.clearQueue();
			
			this.httpService = new HTTPService(function(rObject){
				
				try{
				
					
				}catch(err:Error){ trace("Error", err); }
			});
		}
		
		// -------------------------------------------------------------------
		// UI
		// -------------------------------------------------------------------

		// อัพเดทนาฬิกา
		private function updateClockUI():void{
			
			// นาฬิกา
			if (getChildByName("clock") != null){ 
				((this["clock"] as MovieClip).clockLabel as TextField).text = Utils.timeString();
			}
			// วันที่
			//if (getChildByName("dateLabel") != null) this["dateLabel"].text = Utils.thaiDateString();
		}
		private function clearUI():void{
			/*
			for(var i=1;i<=5;i++){
				
				if (getChildByName("line_"+i) != null){
					(this["line_"+i] as DisplayRoom).displayLineNo = i;
					(this["line_"+i] as DisplayRoom).clearUI();
				}
			}
			*/
		}
		
		// -------------------------------------------------------------------
		// Event Handler
		// -------------------------------------------------------------------
		
		// โหลด config ไม่สำเร็จ บังคับ refresh ข้อมูล
		private function failedOnLoadConfig():void{
			var msg: ModalDialog = new ModalDialog("เกิดข้อผิดพลาดในการอ่านค่า "+ Main.CONFIG_XML +" \n กรุณาลองเปิดโปรแกรมใหม่อีกครั้ง");
			(new DialogManager(msg)).showDialog();
		}
		
		// -------------------------------------------------------------------
		// -------------------------------------------------------------------
	}
}
