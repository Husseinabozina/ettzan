import AppKit
import Foundation

// Deterministic composition: screenshots are scaled uniformly, never retouched or cropped.
let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let assets = root.appendingPathComponent("docs/showcase/assets")
func color(_ h: UInt32) -> NSColor { NSColor(calibratedRed: CGFloat((h >> 16) & 255)/255, green: CGFloat((h >> 8) & 255)/255, blue: CGFloat(h & 255)/255, alpha: 1) }
func topRect(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, canvasHeight: CGFloat) -> NSRect { NSRect(x:x,y:canvasHeight-y-h,width:w,height:h) }
func text(_ s: String, rect: NSRect, size: CGFloat, ink: NSColor, alignment: NSTextAlignment = .center) {
  let p = NSMutableParagraphStyle(); p.alignment = alignment; p.baseWritingDirection = .rightToLeft
  (s as NSString).draw(in: rect, withAttributes:[.font:NSFont.systemFont(ofSize:size,weight:.semibold),.foregroundColor:ink,.paragraphStyle:p])
}
func render(width: Int, height: Int, path: URL, body: (CGFloat)->Void) throws {
  guard let rep = NSBitmapImageRep(bitmapDataPlanes:nil,pixelsWide:width,pixelsHigh:height,bitsPerSample:8,samplesPerPixel:4,hasAlpha:true,isPlanar:false,colorSpaceName:.deviceRGB,bytesPerRow:0,bitsPerPixel:0), let c = NSGraphicsContext(bitmapImageRep:rep) else { fatalError("Canvas failed") }
  NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current=c; c.imageInterpolation = .high
  body(CGFloat(height)); c.flushGraphics(); NSGraphicsContext.restoreGraphicsState()
  guard let data = rep.representation(using:.jpeg,properties:[.compressionFactor:0.90]) else { fatalError("Export failed") }
  try data.write(to:path,options:.atomic); print(path.path)
}
let slides:[(String,String,String,String)] = [
  ("01-splash","splash","اتزان، من أول لحظة","توازن داخلي. حياة أفضل."),
  ("02-onboarding","onboarding","رحلتك تبدأ بخطوة","نمّ ذاتك، وضع أهدافك"),
  ("03-signup","signup","ابدأ رحلتك مع اتزان","إنشاء حساب أو الدخول كضيف"),
  ("04-guest-home","guest-home","استكشف بإيقاعك","الرئيسية في وضع الضيف"),
  ("05-coaches","coaches","اكتشف مدربًا مناسبًا","التخصصات والملفات في مكان واحد"),
  ("06-profile","profile","رحلتك في مكان واحد","ملفك الشخصي وإنجازاتك"),
  ("07-goals","goals","خطّط، وتابع خطواتك","أهداف وعادات وخطة يومية"),
  ("08-dashboard","dashboard","صورة أوضح لتقدّمك","لوحة المتابعة الشخصية")
]
for (i,slide) in slides.enumerated() {
  try render(width:1080,height:1920,path:assets.appendingPathComponent("posters/\(slide.0).jpg")) { h in
    let canvas=NSRect(x:0,y:0,width:1080,height:h)
    NSGradient(starting:color(i % 2 == 0 ? 0xe2f7f1 : 0xf0e7fc),ending:color(0xf7fafc))!.draw(in:canvas,angle:-75)
    text("etzan / اتزان",rect:topRect(70,55,940,52,canvasHeight:h),size:30,ink:color(0x087c78))
    text(slide.2,rect:topRect(40,142,1000,98,canvasHeight:h),size:56,ink:color(0x102e48))
    text(slide.3,rect:topRect(60,242,960,65,canvasHeight:h),size:29,ink:color(0x516779))
    let frame=topRect(191,340,698,1508,canvasHeight:h)
    let shadow=NSShadow();shadow.shadowColor=color(0x073e43).withAlphaComponent(0.20);shadow.shadowBlurRadius=35;shadow.shadowOffset=NSSize(width:0,height:-16);shadow.set()
    color(0x123e46).setFill();NSBezierPath(roundedRect:frame,xRadius:52,yRadius:52).fill();NSShadow().set()
    let screenWidth:CGFloat=670; let screenHeight=screenWidth*2532/1170
    let screen=topRect(205,354,screenWidth,screenHeight,canvasHeight:h)
    guard let screenshot=NSImage(contentsOf:assets.appendingPathComponent("screens/\(slide.1).png")) else { fatalError("Missing \(slide.1)") }
    NSGraphicsContext.saveGraphicsState();NSBezierPath(roundedRect:screen,xRadius:38,yRadius:38).addClip();screenshot.draw(in:screen);NSGraphicsContext.restoreGraphicsState()
  }
}
try render(width:1600,height:680,path:assets.appendingPathComponent("readme-cover.jpg")) { h in
  NSGradient(starting:color(0xe2f7f1),ending:color(0xe5d7f9))!.draw(in:NSRect(x:0,y:0,width:1600,height:h),angle:0)
  if let logo=NSImage(contentsOf:assets.appendingPathComponent("logo.png")) {
    let scale=min(420/logo.size.width,260/logo.size.height)
    let w=logo.size.width*scale; let lh=logo.size.height*scale
    logo.draw(in:topRect(940+(420-w)/2,45+(260-lh)/2,w,lh,canvasHeight:h))
  }
  text("خطوات صغيرة. حياة أكثر اتزانًا.",rect:topRect(610,335,900,90,canvasHeight:h),size:58,ink:color(0x102e48))
  text("تطوير الذات · المدربون · الأهداف والعادات",rect:topRect(670,442,800,65,canvasHeight:h),size:30,ink:color(0x087c78))
  text("FLUTTER  /  ARABIC-FIRST  /  iOS + ANDROID",rect:topRect(645,545,850,55,canvasHeight:h),size:23,ink:color(0x516779))
  let w:CGFloat=248;let sh=w*2532/1170
  for (x,y,id) in [(CGFloat(88),CGFloat(45),"guest-home"),(CGFloat(340),CGFloat(100),"coaches")] {
    let r=topRect(x,y,w+16,sh+16,canvasHeight:h);color(0x123e46).setFill();NSBezierPath(roundedRect:r,xRadius:25,yRadius:25).fill()
    if let im=NSImage(contentsOf:assets.appendingPathComponent("screens/\(id).png")) { im.draw(in:topRect(x+8,y+8,w,sh,canvasHeight:h)) }
  }
}
