// Created by iWeb 3.0.4 local-build-20130704

setTransparentGifURL('Media/transparent.gif');function applyEffects()
{var registry=IWCreateEffectRegistry();registry.registerEffects({stroke_0:new IWStrokeParts([{rect:new IWRect(-2,2,4,107),url:'AGORASET_files/stroke.png'},{rect:new IWRect(-2,-2,4,4),url:'AGORASET_files/stroke_1.png'},{rect:new IWRect(2,-2,240,4),url:'AGORASET_files/stroke_2.png'},{rect:new IWRect(242,-2,4,4),url:'AGORASET_files/stroke_3.png'},{rect:new IWRect(242,2,4,107),url:'AGORASET_files/stroke_4.png'},{rect:new IWRect(242,109,4,4),url:'AGORASET_files/stroke_5.png'},{rect:new IWRect(2,109,240,4),url:'AGORASET_files/stroke_6.png'},{rect:new IWRect(-2,109,4,4),url:'AGORASET_files/stroke_7.png'}],new IWSize(244,111))});registry.applyEffects();}
function hostedOnDM()
{return false;}
function onPageLoad()
{loadMozillaCSS('AGORASET_files/AGORASETMoz.css')
adjustLineHeightIfTooBig('id1');adjustFontSizeIfTooBig('id1');adjustLineHeightIfTooBig('id2');adjustFontSizeIfTooBig('id2');Widget.onload();fixupAllIEPNGBGs();fixAllIEPNGs('Media/transparent.gif');applyEffects()}
function onPageUnload()
{Widget.onunload();}
