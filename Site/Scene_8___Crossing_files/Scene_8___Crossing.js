// Created by iWeb 3.0.4 local-build-20130704

function writeMovie1()
{detectBrowser();if(windowsInternetExplorer)
{document.write('<object id="id11" classid="clsid:02BF25D5-8C17-4B23-BC80-D3488ABDDC6B" codebase="http://www.apple.com/qtactivex/qtplugin.cab" width="261" height="212" style="height: 212px; left: 186px; position: absolute; top: 356px; width: 261px; z-index: 1; "><param name="src" value="Media/cross.webm" /><param name="controller" value="true" /><param name="autoplay" value="false" /><param name="scale" value="tofit" /><param name="volume" value="100" /><param name="loop" value="false" /></object>');}
else if(isiPhone)
{document.write('<object id="id11" type="video/quicktime" width="261" height="212" style="height: 212px; left: 186px; position: absolute; top: 356px; width: 261px; z-index: 1; "><param name="src" value="Scene_8___Crossing_files/cross.jpg"/><param name="target" value="myself"/><param name="href" value="../Media/cross.webm"/><param name="controller" value="true"/><param name="scale" value="tofit"/></object>');}
else
{document.write('<object id="id11" type="video/quicktime" width="261" height="212" data="Media/cross.webm" style="height: 212px; left: 186px; position: absolute; top: 356px; width: 261px; z-index: 1; "><param name="src" value="Media/cross.webm"/><param name="controller" value="true"/><param name="autoplay" value="false"/><param name="scale" value="tofit"/><param name="volume" value="100"/><param name="loop" value="false"/></object>');}}
setTransparentGifURL('Media/transparent.gif');function applyEffects()
{var registry=IWCreateEffectRegistry();registry.registerEffects({stroke_0:new IWStrokeParts([{rect:new IWRect(-1,1,2,163),url:'Scene_8___Crossing_files/stroke.png'},{rect:new IWRect(-1,-1,2,2),url:'Scene_8___Crossing_files/stroke_1.png'},{rect:new IWRect(1,-1,234,2),url:'Scene_8___Crossing_files/stroke_2.png'},{rect:new IWRect(235,-1,2,2),url:'Scene_8___Crossing_files/stroke_3.png'},{rect:new IWRect(235,1,2,163),url:'Scene_8___Crossing_files/stroke_4.png'},{rect:new IWRect(235,164,2,2),url:'Scene_8___Crossing_files/stroke_5.png'},{rect:new IWRect(1,164,234,2),url:'Scene_8___Crossing_files/stroke_6.png'},{rect:new IWRect(-1,164,2,2),url:'Scene_8___Crossing_files/stroke_7.png'}],new IWSize(236,165))});registry.applyEffects();}
function hostedOnDM()
{return false;}
function onPageLoad()
{loadMozillaCSS('Scene_8___Crossing_files/Scene_8___CrossingMoz.css')
adjustLineHeightIfTooBig('id1');adjustFontSizeIfTooBig('id1');adjustLineHeightIfTooBig('id2');adjustFontSizeIfTooBig('id2');adjustLineHeightIfTooBig('id3');adjustFontSizeIfTooBig('id3');adjustLineHeightIfTooBig('id4');adjustFontSizeIfTooBig('id4');adjustLineHeightIfTooBig('id5');adjustFontSizeIfTooBig('id5');adjustLineHeightIfTooBig('id6');adjustFontSizeIfTooBig('id6');adjustLineHeightIfTooBig('id7');adjustFontSizeIfTooBig('id7');adjustLineHeightIfTooBig('id8');adjustFontSizeIfTooBig('id8');adjustLineHeightIfTooBig('id9');adjustFontSizeIfTooBig('id9');adjustLineHeightIfTooBig('id10');adjustFontSizeIfTooBig('id10');adjustLineHeightIfTooBig('id12');adjustFontSizeIfTooBig('id12');adjustLineHeightIfTooBig('id13');adjustFontSizeIfTooBig('id13');Widget.onload();applyEffects()}
function onPageUnload()
{Widget.onunload();}
