pragma solidity 0.8.7;

import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

library KeyboardLib {

    struct ColorScheme {
        string buttons;
        string keyboard;

    }
    struct URIParams {
        address soundsContract;
        string soundArr;
        string attributes;
        string frontend;
        address owner;
        uint id;
        ColorScheme colors;
        uint color;

    }


    

    string constant private svgStart = '<svg id="keyboard_svg" viewBox="0 0 650 255" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">';
    
    string constant private scriptStart = '<g id="allSounds"></g><script type="text/javascript"><![CDATA[';
                                                                            
    string constant private scriptEnd = 'document.documentElement.addEventListener("keydown",e=>handleKeyPress(e.code)),document.documentElement.addEventListener("keyup",e=>handleKeyUp(e.code));let notes=["c","cSharp","d","dSharp","e","f","fSharp","g","gSharp","a","aSharp","b"],ip={},cn={},co=1,sus=!1,aSus=!1,csi=0,hl=!1,svg=document.getElementById("keyboard_svg"),soundsGroup=document.getElementById("allSounds");function toggleAutoSustain(){let e,t;(aSus=!aSus)?(e="on",t="600"):(e="off",t="585"),document.getElementById("sustain").textContent=e,document.getElementById("autoSustainButton2").setAttribute("x",t)}function toggleHighlight(){let e,t,a;(hl=!hl)?(t="50",a="43",e="on"):(t="35",a="57",e="off");let s=document.getElementById("hltext");s.textContent=e,s.setAttribute("x",a),document.getElementById("highlight2").setAttribute("x",t)}function toggleSounds(e){if((0!=csi||!(e<0))&&(csi!=names.length-1||!(e>0))){csi+=e,co=1,document.getElementById("currOctave").textContent="1-2",document.getElementById("selectedSound").textContent=`${csi+1}. ${names[csi]}`;Object.values(soundsGroup.children).map(e=>e.id).includes(names[csi])||loadSounds(csi)}}function loadSounds(e){let t=1,a=0,s=document.createElementNS("http://www.w3.org/1999/xhtml","g");s.setAttribute("id",names[e]),soundsGroup.appendChild(s);let c=document.getElementById("loadingBar"),n=document.getElementById("loadingRect");n.setAttribute("stroke","#000"),c.setAttribute("class","keyboard"),c.setAttribute("width","0");let u=12*octaves[e]+1,r=0;for(let o=0;o<u;o++){let k=new Audio(soundUris[e]+"/"+notes[a]+`${t}`+".flac");k.oncanplaythrough=()=>{r++,c.setAttribute("width",r/u*80),r==u&&(r=0,n.removeAttribute("stroke"),c.removeAttribute("class"))},k.setAttribute("type","audio/flac"),k.setAttribute("preload","auto"),k.setAttribute("id",notes[a]+`${t}`),s.appendChild(k),11==a?(a=0,t+=1):a+=1}svg.appendChild(soundsGroup)}function play(e){if(!0==cn[e])return;(oneShots[csi]||!polyphonic[csi])&&pauseAll(),cn[e]=!0;let t=document.getElementById(names[csi]).querySelector("#"+e);t.currentTime=0,t.play()}function pauseUp(e){cn[e]=!1,!oneShots[csi]&&pause(e)}function pause(e){if(!sus&&!aSus)document.getElementById(names[csi]).querySelector("#"+e).pause()}function pauseAll(){Object.keys(cn).forEach(e=>{cn[e]=!1,pause(e)})}function pausePlaying(){Object.keys(cn).forEach(e=>{!1==cn[e]&&pause(e)})}function changeOctave(e){let t=octaves[csi];(co+=e)<1&&(co=1),co>t&&(co=t);let a=`${co}-${co+1}`;co==t&&(a=t),document.getElementById("currOctave").textContent=a}function ku(e,t){hl&&document.getElementById(e).removeAttribute("stroke");pauseUp(ip[t])}function kd(e,t,a,s){hl&&document.getElementById(e).setAttribute("stroke","#ff0a54");let c=notes[a]+`${co+s}`;ip[t]=c,play(c)}function handleKeyUp(e){switch(e){case"KeyA":ku(e,0);break;case"KeyW":ku(e,1);break;case"KeyS":ku(e,2);break;case"KeyE":ku(e,3);break;case"KeyD":ku(e,4);break;case"KeyF":ku(e,5);break;case"KeyT":ku(e,6);break;case"KeyG":ku(e,7);break;case"KeyY":ku(e,8);break;case"KeyH":ku(e,9);break;case"KeyU":ku(e,10);break;case"KeyJ":ku(e,11);break;case"KeyK":ku(e,12);break;case"KeyO":ku(e,13);break;case"KeyL":ku(e,14);break;case"KeyP":ku(e,15);break;case"Semicolon":ku(e,16);break;case"Quote":ku(e,17);break;case"BracketRight":ku(e,18);break;case"Enter":ku(e,19);break;case"Space":sus=!1,pausePlaying(),aSus||(document.getElementById("sustain").textContent="off")}}function handleKeyPress(e){switch(e){case"Digit1":changeOctave(-1);break;case"Digit2":changeOctave(1);break;case"Digit9":toggleSounds(-1);break;case"Digit0":toggleSounds(1);break;case"KeyA":kd(e,0,0,0);break;case"KeyW":kd(e,1,1,0);break;case"KeyS":kd(e,2,2,0);break;case"KeyE":kd(e,3,3,0);break;case"KeyD":kd(e,4,4,0);break;case"KeyF":kd(e,5,5,0);break;case"KeyT":kd(e,6,6,0);break;case"KeyG":kd(e,7,7,0);break;case"KeyY":kd(e,8,8,0);break;case"KeyH":kd(e,9,9,0);break;case"KeyU":kd(e,10,10,0);break;case"KeyJ":kd(e,11,11,0);break;case"KeyK":kd(e,12,0,1);break;case"KeyO":kd(e,13,1,1);break;case"KeyL":kd(e,14,2,1);break;case"KeyP":kd(e,15,3,1);break;case"Semicolon":kd(e,16,4,1);break;case"Quote":kd(e,17,5,1);break;case"BracketRight":kd(e,18,6,1);break;case"Enter":kd(e,19,7,1);break;case"Space":sus=!0,aSus||(document.getElementById("sustain").textContent="on")}}loadSounds(0);]]></script></svg>';



    function base64SVG(string memory soundArr, ColorScheme memory colors, uint id, address owner) private pure returns(string memory) {
        bytes memory svg = getSvg(id,owner,colors,soundArr);
        string memory base64 =  string(Base64.encode(svg));
        return string(abi.encodePacked("data:image/svg+xml;base64,", base64));
    }
    



    function getScript(string memory soundArr) private pure returns(string memory) {
        return string(abi.encodePacked(scriptStart, soundArr, scriptEnd));
    }

    function getSvg(uint id, address owner, ColorScheme memory colors, string memory soundArr) private pure returns(bytes memory) {
        string memory script = getScript(soundArr);
        string memory styles = getStyles(colors);
        string memory text = getText(id,owner);

        return abi.encodePacked(
            svgStart, 
            styles,
            '<defs> <filter id="f2"> <feDropShadow dx="10" dy="10" stdDeviation="4" flood-color="#262729" flood-opacity="0.7"/> </filter> </defs> <rect class="keyboard" stroke="#000" x="0" y="0" width="650" height="255" rx="6" filter="url(#f2)" /> <rect fill= "#050505" x="23" y="78" width="602" height="174" rx="6"/> <g class="buttons" stroke="#000"> <rect x="25" y="30" width="50" height="15" rx="2" onclick="changeOctave(-1)"/> <rect x="125" y="30" width="50" height="15" rx="2" onclick="changeOctave(1)"/> <rect x="575" y="30" width="50" height="15" rx="2" onclick="toggleSounds(1)"/> <rect x="475" y="30" width="50" height="15" rx="2" onclick="toggleSounds(-1)"/> <g onclick="toggleAutoSustain()"> <rect id="autoSustainButton" x="585" y="55" width="30" height="15" rx="2" /> <rect id="autoSustainButton2" fill="#fefae0" x="585" y="55" width="15" height="15" rx="2" /> </g> <g onclick="toggleHighlight()"> <rect id="highlight1" x="35" y="55" width="30" height="15" rx="2" /> <rect id="highlight2" fill="#fefae0" x="35" y="55" width="15" height="15" rx="2" /> </g> </g> <g fill="#fefae0" onmouseup="pauseAll()"> <rect stroke="#000" x="225" y="7" width="200" height="60" rx="3"/> <rect id="loadingRect" stroke-width=".3" x="285" y="43" width="80" height="2" rx="1"/> <rect id="loadingBar" x="285" y="43" width="0" height="2" rx="1"/> <g stroke-width="2"> <rect id="KeyA" x="25" y="80" width="38" height="170" rx="6" onmousedown="play(notes[0] + `${co +0}`)" /> <rect id="KeyS" x="65" y="80" width="38" height="170" rx="6" onmousedown="play(notes[2] + `${co +0}`)" /> <rect id="KeyD" x="105" y="80" width="38" height="170" rx="6" onmousedown="play(notes[4] + `${co +0}`)" /> <rect id="KeyF" x="145" y="80" width="38" height="170" rx="6" onmousedown="play(notes[5] + `${co +0}`)" /> <rect id="KeyG" x="185" y="80" width="38" height="170" rx="6" onmousedown="play(notes[7] + `${co +0}`)"/> <rect id="KeyH" x="225" y="80" width="38" height="170" rx="6" onmousedown="play(notes[9] + `${co +0}`)"/> <rect id="KeyJ" x="265" y="80" width="38" height="170" rx="6" onmousedown="play(notes[11] + `${co +0}`)"/> <rect id="KeyK" x="305" y="80" width="38" height="170" rx="6" onmousedown="play(notes[0] + `${co +1}`)"/> <rect id="KeyL" x="345" y="80" width="38" height="170" rx="6" onmousedown="play(notes[2] + `${co +1}`)"/> <rect id="Semicolon" x="385" y="80" width="38" height="170" rx="6" onmousedown="play(notes[4] + `${co +1}`)"/> <rect id="Quote" x="425" y="80" width="38" height="170" rx="6" onmousedown="play(notes[5] + `${co +1}`)"/> <rect id="Enter" x="465" y="80" width="38" height="170" rx="6" onmousedown="play(notes[7] + `${co +1}`)"/> <rect x="505" y="80" width="38" height="170" rx="6" onmousedown="play(notes[9] + `${co +1}`)"/> <rect x="545" y="80" width="38" height="170" rx="6" onmousedown="play(notes[11] + `${co +1}`)"/> <rect x="585" y="80" width="38" height="170" rx="6" onmousedown="play(notes[0] + `${co +2}`)"/> </g> </g> <g fill="#050505" onmouseup="pauseAll()" stroke-width="2"> <rect id="KeyW" x="48" y="79" width="24" height="95" rx="4" onmousedown="play(notes[1] + `${co +0}`)"/> <rect id="KeyE" x="92" y="79" width="24" height="95" rx="4" onmousedown="play(notes[3] + `${co +0}`)"/> <rect id="KeyT" x="168" y="79" width="24" height="95" rx="4" onmousedown="play(notes[6] + `${co +0}`)"/> <rect id="KeyY" x="211" y="79" width="24" height="95" rx="4" onmousedown="play(notes[8] + `${co +0}`)"/> <rect id="KeyU" x="254" y="79" width="24" height="95" rx="4" onmousedown="play(notes[10] + `${co +0}`)"/> <rect id="KeyO" x="328" y="79" width="24" height="95" rx="4" onmousedown="play(notes[1] + `${co +1}`)"/> <rect id="KeyP" x="372" y="79" width="24" height="95" rx="4" onmousedown="play(notes[3] + `${co +1}`)"/> <rect id="BracketRight" x="448" y="79" width="24" height="95" rx="4" onmousedown="play(notes[6] + `${co +1}`)"/> <rect x="491" y="79" width="24" height="95" rx="4" onmousedown="play(notes[8] + `${co +1}`)"/> <rect x="534" y="79" width="24" height="95" rx="4" onmousedown="play(notes[10] + `${co +1}`)"/> </g>',
            text,
            script
            
            
            );
    }

    function getText(uint id, address owner) private pure returns(string memory) {
        return string(abi.encodePacked(
            '<g text-anchor="middle" class="keyboard"><text x="325" y="18" class="tiny">',
            Strings.toString(id),
            '/10000</text><text x="325" y="60" class="very_tiny" >Owner: ',
            Strings.toHexString(uint160(owner), 20),
            '</text> <text x="245" y="30" class="tiny">sustain</text> <text id="sustain" x="245" y="40" class="medium" onclick="toggleAutoSustain()">off</text> <text x="405" y="30" class="tiny">octave</text> <text id="currOctave" x="405" y="40" class="medium" >1-2</text> <text id="selectedSound" x="325" y="35" class="heavy">1. Electric Piano</text> <text id="loading" x="325" y="47" class="tiny"></text> </g> <g dominant-baseline="middle" text-anchor="middle" fill="#fefae0"> <text x="100" y="38" class="medium">octave</text> <text x="550" y="38" class="medium">sounds</text> <text x="550" y="63" class="medium">sustain</text><text x="100" y="63" class="medium">highlight</text><text id="hltext" x="57" y="63" class="very_tiny">off</text><text x="500" y="37" class="heavy" onclick="toggleSounds(-1)">-</text> <text x="600" y="38.5" class="heavy" onclick="toggleSounds(1)">+</text> <text x="50" y="37" class="heavy" onclick="changeOctave(-1)">-</text> <text x="150" y="38.5" class="heavy" onclick="changeOctave(1)">+</text> </g>'
            ));

    }

             




    function getStyles(ColorScheme memory colors) private pure returns(string memory styles) {
        string memory start = '<style> .very_tiny { font: bold 6px sans-serif; } .tiny { font: bold 7px sans-serif; } .heavy { font: bold 12px sans-serif; } .medium { font: bold 10px sans-serif; }';
        styles = string(abi.encodePacked(
            start,
            '.keyboard {fill: #',
            colors.keyboard,
            '}.buttons {fill: #',
            colors.buttons,
            '} </style>'
            ));
    }

    


    function generateTokenURI(URIParams memory params) public pure returns(string memory) {
        
        string memory imageUrl = base64SVG(params.soundArr, params.colors, params.id, params.owner);

        bytes memory base64Html = abi.encodePacked(
            'data:text/html;base64,', 

            Base64.encode(abi.encodePacked(
                '<!DOCTYPE html> <html><object type="image/svg+xml" data="',
                imageUrl,
                '" alt="keyboard"></object></html>'
            )));

        bytes memory json = abi.encodePacked(
                  '{"name":"Keyboard #',
                  Strings.toString(params.id),
                  '", "description":"A fully functional virtual keyboard on Arbitrum! White keys are mapped from letter -A- to -Enter- (notes C-G) on your computer keyboard.  Black keys are mapped from -W- to -]- (notes C#-F#).  -1- & -2- toggle octaves.  -9- & -0- toggle sounds.  Space bar acts as a sustain pedal.  Highlight outlines the keys that are pressed.  To play, paste the image uri into a web browser, or visit the [Official Website](',
                  params.frontend,
                  ') to play and record your keyboards, and manage installations.","external_url":"',
                  params.frontend,
                  '", "Sounds Contract":"',
                  Strings.toHexString(uint160(params.soundsContract), 20),
                  '",'
                  );
        json = abi.encodePacked(
                  json,
                  '"attributes":',
                  params.attributes,
                  ', "owner":"',
                  Strings.toHexString(uint160(params.owner), 20),
                  '", "image": "',
                  imageUrl,
                  '", "animation_url":"',
                    base64Html,
                    '"}'
              );
        return string(
              abi.encodePacked('data:application/json;base64,',Base64.encode(json)));
          

    }
}