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
        string script;

    }


    

    string constant private svgStart = '<svg id="keyboard_svg" viewBox="0 0 650 255" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">';
    
    string constant private scriptStart = '<g id="allSounds"></g><script type="text/javascript"><![CDATA[';
                                                                            

    function base64SVG(URIParams memory params) private pure returns(string memory) {
        bytes memory svg = getSvg(params.id,params.owner,params.colors,params.soundArr, params.script);
        string memory base64 =  string(Base64.encode(svg));
        return string(abi.encodePacked("data:image/svg+xml;base64,", base64));
    }
    



    function getScript(string memory soundArr, string memory scriptEnd) private pure returns(string memory) {
        return string(abi.encodePacked(scriptStart, soundArr, scriptEnd));
    }

    function getSvg(uint id, address owner, ColorScheme memory colors, string memory soundArr, string memory scriptEnd) private pure returns(bytes memory) {
        string memory script = getScript(soundArr,scriptEnd);
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
        
        string memory imageUrl = base64SVG(params);

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
                  '", "description":"A fully functional virtual keyboard on Arbitrum! White keys are mapped from letter -A- to -Enter- (notes C-G).  Black keys are mapped from -W- to -]- (notes C#-F#).  -1- & -2- toggle octaves.  -9- & -0- toggle sounds.  Space bar acts as a sustain pedal.  Highlight outlines the keys that are pressed.  To play, paste the image uri into a web browser, or visit the [Official Website](',
                  params.frontend,
                  ') to play and record your keyboards as well as manage installations.","external_url":"',
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