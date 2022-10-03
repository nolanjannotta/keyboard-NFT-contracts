pragma solidity 0.8.7;

import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

library keyBoardLib {

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
                                                                            
    string constant private scriptEnd = 'document.documentElement.addEventListener("keydown",e=>handleKeyPress(e.code)),document.documentElement.addEventListener("keyup",e=>handleKeyUp(e.code));let notes=["c","cSharp","d","dSharp","e","f","fSharp","g","gSharp","a","aSharp","b"],ip={},cn={},co=1,sus=!1,aSus=!1,csi=0,svg=document.getElementById("keyboard_svg"),soundsGroup=document.getElementById("allSounds");function toggleAutoSustain(){let e,t;e=(aSus=!aSus)?"on":"off",t=aSus?"600":"585",document.getElementById("sustain").textContent=e,document.getElementById("autoSustainButton2").setAttribute("x",t)}function toggleSounds(e){if((0!=csi||!(e<0))&&(csi!=names.length-1||!(e>0))){csi+=e,co=1,document.getElementById("currOctave").textContent="1-2",document.getElementById("selectedSound").textContent=`${csi+1}. ${names[csi]}`;Object.values(soundsGroup.children).map(e=>e.id).includes(names[csi])||loadSounds(csi)}}function loadSounds(e){let t=1,a=0,s=document.createElementNS("http://www.w3.org/1999/xhtml","g");s.setAttribute("id",names[e]),soundsGroup.appendChild(s);let n=document.getElementById("loadingBar"),c=document.getElementById("loadingRect");c.setAttribute("stroke","#000"),n.setAttribute("class","keyboard"),n.setAttribute("width","0");let p=12*octaves[e]+1,o=0;for(let i=0;i<p;i++){let r=new Audio(soundUris[e]+"/"+notes[a]+`${t}`+".flac");r.oncanplaythrough=()=>{o++,n.setAttribute("width",o/p*80),o==p&&(o=0,c.removeAttribute("stroke"),n.removeAttribute("class"))},r.setAttribute("type","audio/flac"),r.setAttribute("preload","auto"),r.setAttribute("id",notes[a]+`${t}`),s.appendChild(r),11==a?(a=0,t+=1):a+=1}svg.appendChild(soundsGroup)}function play(e){if(!0==cn[e])return;(oneShots[csi]||!polyphonic[csi])&&pauseAll(),cn[e]=!0;let t=document.getElementById(names[csi]).querySelector("#"+e);t.currentTime=0,t.play()}function pauseUp(e){cn[e]=!1,!oneShots[csi]&&pause(e)}function pause(e){if(!sus&&!aSus)document.getElementById(names[csi]).querySelector("#"+e).pause()}function pauseAll(){Object.keys(cn).forEach(e=>{cn[e]=!1,pause(e)})}function pausePlaying(){Object.keys(cn).forEach(e=>{!1==cn[e]&&pause(e)})}function changeOctave(e){let t=octaves[csi];(co+=e)<1&&(co=1),co>t&&(co=t);let a=`${co}-${co+1}`;co==t&&(a=t),document.getElementById("currOctave").textContent=a}function handleKeyUp(e){let t;switch(e){case"KeyA":pauseUp(t=ip[0]);break;case"KeyW":pauseUp(t=ip[1]);break;case"KeyS":pauseUp(t=ip[2]);break;case"KeyE":pauseUp(t=ip[3]);break;case"KeyD":pauseUp(t=ip[4]);break;case"KeyF":pauseUp(t=ip[5]);break;case"KeyT":pauseUp(t=ip[6]);break;case"KeyG":pauseUp(t=ip[7]);break;case"KeyY":pauseUp(t=ip[8]);break;case"KeyH":pauseUp(t=ip[9]);break;case"KeyU":pauseUp(t=ip[10]);break;case"KeyJ":pauseUp(t=ip[11]);break;case"KeyK":pauseUp(t=ip[12]);break;case"KeyO":pauseUp(t=ip[13]);break;case"KeyL":pauseUp(t=ip[14]);break;case"KeyP":pauseUp(t=ip[15]);break;case"Semicolon":pauseUp(t=ip[16]);break;case"Quote":pauseUp(t=ip[17]);break;case"BracketRight":pauseUp(t=ip[18]);break;case"Enter":pauseUp(t=ip[19]);break;case"Space":sus=!1,pausePlaying(),aSus||(document.getElementById("sustain").textContent="off")}}function handleKeyPress(e){switch(e){case"Digit1":changeOctave(-1);break;case"Digit2":changeOctave(1);break;case"Digit9":toggleSounds(-1);break;case"Digit0":toggleSounds(1);break;case"KeyA":note=notes[0]+`${co+0}`,ip[0]=note,play(note);break;case"KeyW":note=notes[1]+`${co+0}`,ip[1]=note,play(note);break;case"KeyS":note=notes[2]+`${co+0}`,ip[2]=note,play(note);break;case"KeyE":note=notes[3]+`${co+0}`,ip[3]=note,play(note);break;case"KeyD":note=notes[4]+`${co+0}`,ip[4]=note,play(note);break;case"KeyF":note=notes[5]+`${co+0}`,ip[5]=note,play(note);break;case"KeyT":note=notes[6]+`${co+0}`,ip[6]=note,play(note);break;case"KeyG":note=notes[7]+`${co+0}`,ip[7]=note,play(note);break;case"KeyY":note=notes[8]+`${co+0}`,ip[8]=note,play(note);break;case"KeyH":note=notes[9]+`${co+0}`,ip[9]=note,play(note);break;case"KeyU":note=notes[10]+`${co+0}`,ip[10]=note,play(note);break;case"KeyJ":note=notes[11]+`${co+0}`,ip[11]=note,play(note);break;case"KeyK":note=notes[0]+`${co+1}`,ip[12]=note,play(note);break;case"KeyO":note=notes[1]+`${co+1}`,ip[13]=note,play(note);break;case"KeyL":note=notes[2]+`${co+1}`,ip[14]=note,play(note);break;case"KeyP":note=notes[3]+`${co+1}`,ip[15]=note,play(note);break;case"Semicolon":note=notes[4]+`${co+1}`,ip[16]=note,play(note);break;case"Quote":note=notes[5]+`${co+1}`,ip[17]=note,play(note);break;case"BracketRight":note=notes[6]+`${co+1}`,ip[18]=note,play(note);break;case"Enter":note=notes[7]+`${co+1}`,ip[19]=note,play(note);break;case"Space":sus=!0,aSus||(document.getElementById("sustain").textContent="on")}}loadSounds(0);]]></script></svg>';



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
            '<defs> <filter id="f2"> <feDropShadow dx="10" dy="10" stdDeviation="4" flood-color="#262729" flood-opacity="0.7"/> </filter> </defs> <rect class="keyboard" stroke="#000" x="0" y="0" width="650" height="255" rx="6" filter="url(#f2)" /> <rect fill="#050505" x="23" y="78" width="602" height="174" rx="6"/> <g class="buttons" stroke="#000"> <rect x="25" y="30" width="50" height="15" rx="2" onclick="changeOctave(-1)"/> <rect x="125" y="30" width="50" height="15" rx="2" onclick="changeOctave(1)"/> <rect x="575" y="30" width="50" height="15" rx="2" onclick="toggleSounds(1)"/> <rect x="475" y="30" width="50" height="15" rx="2" onclick="toggleSounds(-1)"/> <g onclick="toggleAutoSustain()"> <rect id="autoSustainButton" x="585" y="55" width="30" height="15" rx="2" /> <rect id="autoSustainButton2" fill="#fefae0" x="585" y="55" width="15" height="15" rx="2" /> </g> </g> <g fill="#fefae0" onmouseup="pauseAll()"> <rect stroke="#000" x="225" y="7" width="200" height="60" rx="3"/><rect id="loadingRect" stroke-width=".3" x="285" y="43" width="80" height="2" rx="1"/><rect id="loadingBar" x="285" y="43" width="0" height="2" rx="1"/> <g> <rect x="25" y="80" width="38" height="170" rx="6" onmousedown="play(notes[0] + `${co +0}`)" /> <rect x="65" y="80" width="38" height="170" rx="6" onmousedown="play(notes[2] + `${co +0}`)" /> <rect x="105" y="80" width="38" height="170" rx="6" onmousedown="play(notes[4] + `${co +0}`)" /> <rect x="145" y="80" width="38" height="170" rx="6" onmousedown="play(notes[5] + `${co +0}`)" /> <rect x="185" y="80" width="38" height="170" rx="6" onmousedown="play(notes[7] + `${co +0}`)"/> <rect x="225" y="80" width="38" height="170" rx="6" onmousedown="play(notes[9] + `${co +0}`)"/> <rect x="265" y="80" width="38" height="170" rx="6" onmousedown="play(notes[11] + `${co +0}`)"/> <rect x="305" y="80" width="38" height="170" rx="6" onmousedown="play(notes[0] + `${co +1}`)"/> <rect x="345" y="80" width="38" height="170" rx="6" onmousedown="play(notes[2] + `${co +1}`)"/> <rect x="385" y="80" width="38" height="170" rx="6" onmousedown="play(notes[4] + `${co +1}`)"/> <rect x="425" y="80" width="38" height="170" rx="6" onmousedown="play(notes[5] + `${co +1}`)"/> <rect x="465" y="80" width="38" height="170" rx="6" onmousedown="play(notes[7] + `${co +1}`)"/> <rect x="505" y="80" width="38" height="170" rx="6" onmousedown="play(notes[9] + `${co +1}`)"/> <rect x="545" y="80" width="38" height="170" rx="6" onmousedown="play(notes[11] + `${co +1}`)"/> <rect x="585" y="80" width="38" height="170" rx="6" onmousedown="play(notes[0] + `${co +2}`)"/> </g> </g> <g fill="#050505" onmouseup="pauseAll()"> <rect x="48" y="79" width="24" height="95" rx="4" onmousedown="play(notes[1] + `${co +0}`)"/> <rect x="92" y="79" width="24" height="95" rx="4" onmousedown="play(notes[3] + `${co +0}`)"/> <rect x="168" y="79" width="24" height="95" rx="4" onmousedown="play(notes[6] + `${co +0}`)"/> <rect x="211" y="79" width="24" height="95" rx="4" onmousedown="play(notes[8] + `${co +0}`)"/> <rect x="254" y="79" width="24" height="95" rx="4" onmousedown="play(notes[10] + `${co +0}`)"/> <rect x="328" y="79" width="24" height="95" rx="4" onmousedown="play(notes[1] + `${co +1}`)"/> <rect x="372" y="79" width="24" height="95" rx="4" onmousedown="play(notes[3] + `${co +1}`)"/> <rect x="448" y="79" width="24" height="95" rx="4" onmousedown="play(notes[6] + `${co +1}`)"/> <rect x="491" y="79" width="24" height="95" rx="4" onmousedown="play(notes[8] + `${co +1}`)"/> <rect x="534" y="79" width="24" height="95" rx="4" onmousedown="play(notes[10] + `${co +1}`)"/> </g>',
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
            '</text> <text x="245" y="30" class="tiny">sustain</text> <text id="sustain" x="245" y="40" class="medium" onclick="toggleAutoSustain()">off</text> <text x="405" y="30" class="tiny">octave</text> <text id="currOctave" x="405" y="40" class="medium" >1-2</text> <text id="selectedSound" x="325" y="35" class="heavy">1. Electric Piano</text> <text id="loading" x="325" y="47" class="tiny"></text> </g> <g dominant-baseline="middle" text-anchor="middle" fill="#fefae0"> <text x="100" y="38" class="medium">octave</text> <text x="550" y="38" class="medium">sounds</text> <text x="550" y="63" class="medium">sustain</text> <text x="500" y="37" class="heavy" onclick="toggleSounds(-1)">-</text> <text x="600" y="38.5" class="heavy" onclick="toggleSounds(1)">+</text> <text x="50" y="37" class="heavy" onclick="changeOctave(-1)">-</text> <text x="150" y="38.5" class="heavy" onclick="changeOctave(1)">+</text> </g>'
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
                  '", "description":"A fully functional virtual keyboard on Polygon! White keys are mapped from letter -A- to -Enter- (notes C-G) on your computer keyboard. Black keys are mapped from -W- to -]- (notes C#-F#). -1- & -2- toggle octaves, and -9- & -0- toggle sounds. Space bar acts as a sustain pedal. To play, paste the image uri into a web browser, or visit the [Official Website](',
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