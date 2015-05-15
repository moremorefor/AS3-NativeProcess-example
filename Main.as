package  {
	
	import flash.display.MovieClip;
	import flash.filesystem.File;
	import flash.events.NativeDragEvent;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragManager;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.ProgressEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.IOErrorEvent;
	
	
	
	public class Main extends MovieClip {
		
		var file:File;
		var process:NativeProcess;
		
		public function Main() {
			
			droparea.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, nativeDragEnterHandler);
			droparea.addEventListener(NativeDragEvent.NATIVE_DRAG_EXIT, nativeDragExitHandler);
			droparea.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, nativeDragDropHandler);
			
			btn_ok.addEventListener(MouseEvent.CLICK, startProcess);
			btn_ok.buttonMode = true;
			
			btn_reset.addEventListener(MouseEvent.CLICK, resetOutput);
			btn_reset.buttonMode = true;

		}
		
		function nativeDragEnterHandler(e:NativeDragEvent):void{
			droparea.alpha = 0.6;
			
			var clipboard:Clipboard = e.clipboard;
			if ( clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT) ) NativeDragManager.acceptDragDrop(droparea);
		}
		 
		function nativeDragExitHandler(event:NativeDragEvent):void{
			droparea.alpha = 1;
		}
		 
		function nativeDragDropHandler(event:NativeDragEvent):void{
			droparea.alpha = 1;
			
			var clipboard:Clipboard = event.clipboard;
			var files:Array = clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
			
			file = files[0];
			output.text = "[FILE]: " + file.nativePath;
		}
		
		
		function startProcess(e:Event){
			if (file == null) {
				output.appendText("Please drag & drop json file.\n");
				return;
			}
			
			btn_ok.alpha = 0.2;
			
			
			var commandFile:File = new File();
			commandFile.nativePath = "/usr/bin/python";
			var argfile:File = File.applicationDirectory.resolvePath("assets/exec.py");
			
			output.appendText("\n [command file]: " + commandFile.nativePath);
			output.appendText("\n [exec file]: " + argfile.nativePath);
		
			var processArgs:Vector.<String> = new Vector.<String>();
			processArgs.push(argfile.nativePath);
			processArgs.push(file.nativePath);
			
			var nativeProcessStartupInfo = new NativeProcessStartupInfo();
			nativeProcessStartupInfo.executable = commandFile;
			nativeProcessStartupInfo.arguments = processArgs;
		
			process = new NativeProcess();
			process.start(nativeProcessStartupInfo);
			process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onOutputDataHandler);
			process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onErrorDataHandler);
			process.addEventListener(NativeProcessExitEvent.EXIT, onExitHandler);
			process.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onIOErrorHandler);
			process.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, onIOErrorHandler);
		}
			
		function onOutputDataHandler(e:ProgressEvent) {
			trace("onOutputDataHandler: ", process.standardOutput.readUTFBytes(process.standardOutput.bytesAvailable) ); 
			output.appendText("\n onOutputDataHandler");
		}
		
		function onErrorDataHandler(e:ProgressEvent) {
			trace("onErrorDataHandler: ", process.standardError.readUTFBytes(process.standardError.bytesAvailable)); 
			output.appendText("\n onErrorDataHandler");
		}
		
		function onExitHandler(e:NativeProcessExitEvent) {
			trace("onExitHandler: Process exited with ", e.exitCode);
			output.appendText("\n onExitHandler");
			btn_ok.alpha = 0.5;
		}
		
		function onIOErrorHandler(e:IOErrorEvent) {
			trace("onIOErrorHandler: " + e.toString());
			output.appendText("\n onIOErrorHandler");
		}
		
		function resetOutput(e:MouseEvent) {
			output.text = "";
		}
		
	}	
}
