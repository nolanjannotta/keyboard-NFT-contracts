// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "forge-std/Script.sol";
import "../src/KeyboardA.sol";
import "../src/KeyboardOZ.sol";
import "../src/Sounds.sol";
import "forge-std/console.sol";


contract MyScript is Script {
    function run() external {
        vm.startBroadcast();

        // KeyboardA keyboardA = KeyboardA();
        // KeyboardOZ keyboardOZ = new KeyboardOZ();
        KeyboardOZ keyboardOZ = KeyboardOZ(0xdFa67C96eE94C114b514ca6d6e5E6363e12ACbA7);
        // Sounds sounds = new Sounds();
        // Sounds sounds = Sounds(0x833f4Ee22C40cf85493f33d527D9ac371AD8478C);
        // keyboardOZ.setSounds(address(sounds));
        keyboardOZ.updateScript('document.documentElement.addEventListener("keydown",e=>handleKeyPress(e.code)),document.documentElement.addEventListener("keyup",e=>handleKeyUp(e.code));let notes=["c","cSharp","d","dSharp","e","f","fSharp","g","gSharp","a","aSharp","b"],ip={},cn={},co=1,sus=!1,aSus=!1,csi=0,hl=!1,svg=document.getElementById("keyboard_svg"),soundsGroup=document.getElementById("allSounds");function toggleAutoSustain(){let e,t;(aSus=!aSus)?(e="on",t="600"):(e="off",t="585"),document.getElementById("sustain").textContent=e,document.getElementById("autoSustainButton2").setAttribute("x",t)}function toggleHighlight(){let e,t,a;(hl=!hl)?(t="50",a="43",e="on"):(t="35",a="57",e="off");let s=document.getElementById("hltext");s.textContent=e,s.setAttribute("x",a),document.getElementById("highlight2").setAttribute("x",t)}function toggleSounds(e){if((0!=csi||!(e<0))&&(csi!=names.length-1||!(e>0))){csi+=e,co=1,document.getElementById("currOctave").textContent="1-2",document.getElementById("selectedSound").textContent=`${csi+1}. ${names[csi]}`;Object.values(soundsGroup.children).map(e=>e.id).includes(names[csi])||loadSounds(csi)}}function loadSounds(e){let t=1,a=0,s=document.createElementNS("http://www.w3.org/1999/xhtml","g");s.setAttribute("id",names[e]),soundsGroup.appendChild(s);let c=document.getElementById("loadingBar"),n=document.getElementById("loadingRect");n.setAttribute("stroke","#000"),c.setAttribute("class","keyboard"),c.setAttribute("width","0");let u=12*octaves[e]+1,r=0;for(let o=0;o<u;o++){let k=new Audio;k.crossOrigin="anonymous",k.src=soundUris[e]+"/"+notes[a]+`${t}`+".flac",k.oncanplaythrough=()=>{r++,c.setAttribute("width",r/u*80),r==u&&(r=0,n.removeAttribute("stroke"),c.removeAttribute("class"))},k.setAttribute("type","audio/flac"),k.setAttribute("preload","auto"),k.setAttribute("id",notes[a]+`${t}`),s.appendChild(k),11==a?(a=0,t+=1):a+=1}svg.appendChild(soundsGroup)}function play(e){if(!0==cn[e])return;(oneShots[csi]||!polyphonic[csi])&&pauseAll(),cn[e]=!0;let t=document.getElementById(names[csi]).querySelector("#"+e);t.currentTime=0,t.play()}function pauseUp(e){cn[e]=!1,!oneShots[csi]&&pause(e)}function pause(e){if(!sus&&!aSus)document.getElementById(names[csi]).querySelector("#"+e).pause()}function pauseAll(){Object.keys(cn).forEach(e=>{cn[e]=!1,pause(e)})}function pausePlaying(){Object.keys(cn).forEach(e=>{!1==cn[e]&&pause(e)})}function changeOctave(e){let t=octaves[csi];(co+=e)<1&&(co=1),co>t&&(co=t);let a=`${co}-${co+1}`;co==t&&(a=t),document.getElementById("currOctave").textContent=a}function ku(e,t){hl&&document.getElementById(e).removeAttribute("stroke");pauseUp(ip[t])}function kd(e,t,a,s){hl&&document.getElementById(e).setAttribute("stroke","#ff0a54");let c=notes[a]+`${co+s}`;ip[t]=c,play(c)}function handleKeyUp(e){switch(e){case"KeyA":ku(e,0);break;case"KeyW":ku(e,1);break;case"KeyS":ku(e,2);break;case"KeyE":ku(e,3);break;case"KeyD":ku(e,4);break;case"KeyF":ku(e,5);break;case"KeyT":ku(e,6);break;case"KeyG":ku(e,7);break;case"KeyY":ku(e,8);break;case"KeyH":ku(e,9);break;case"KeyU":ku(e,10);break;case"KeyJ":ku(e,11);break;case"KeyK":ku(e,12);break;case"KeyO":ku(e,13);break;case"KeyL":ku(e,14);break;case"KeyP":ku(e,15);break;case"Semicolon":ku(e,16);break;case"Quote":ku(e,17);break;case"BracketRight":ku(e,18);break;case"Enter":ku(e,19);break;case"Space":sus=!1,pausePlaying(),aSus||(document.getElementById("sustain").textContent="off")}}function handleKeyPress(e){switch(e){case"Digit1":changeOctave(-1);break;case"Digit2":changeOctave(1);break;case"Digit9":toggleSounds(-1);break;case"Digit0":toggleSounds(1);break;case"KeyA":kd(e,0,0,0);break;case"KeyW":kd(e,1,1,0);break;case"KeyS":kd(e,2,2,0);break;case"KeyE":kd(e,3,3,0);break;case"KeyD":kd(e,4,4,0);break;case"KeyF":kd(e,5,5,0);break;case"KeyT":kd(e,6,6,0);break;case"KeyG":kd(e,7,7,0);break;case"KeyY":kd(e,8,8,0);break;case"KeyH":kd(e,9,9,0);break;case"KeyU":kd(e,10,10,0);break;case"KeyJ":kd(e,11,11,0);break;case"KeyK":kd(e,12,0,1);break;case"KeyO":kd(e,13,1,1);break;case"KeyL":kd(e,14,2,1);break;case"KeyP":kd(e,15,3,1);break;case"Semicolon":kd(e,16,4,1);break;case"Quote":kd(e,17,5,1);break;case"BracketRight":kd(e,18,6,1);break;case"Enter":kd(e,19,7,1);break;case"Space":sus=!0,aSus||(document.getElementById("sustain").textContent="on")}}loadSounds(0);');
        
        
        
        
        // sounds.createSound(
        //     "FzGq3qnau8PTI4cJRGTYxZfEITomQGI2mf-i1Y792Xo", 
        //     false, 
        //     true, 
        //     "Synth", 
        //     "Wobbly Synth", 
        //     5, 
        //     10_000, 
        //     .01 ether
        // );
        // sounds.createSound(
        //     "yApPUXbn1TVuBkhh-dErFCOV_tZ65GT9mRSmy-a0d-s", 
        //     false, 
        //     false, 
        //     "Synth", 
        //     "Square Lead", 
        //     5, 
        //     10_000, 
        //     .01 ether
        // );
        // sounds.createSound(
        //     "9qyWIKrNm3y16YtLNbqgSxKfzI-UuY7VTyRq1mb3n8o", 
        //     false, 
        //     true, 
        //     "Percussion", 
        //     "Marimba", 
        //     5, 
        //     10_000, 
        //     .01 ether
        // );
        // sounds.createSound(
        //     "2r9EyAogQBg-ct_KvVOJjB8hx9G5Q2VDDVaHAx0oXsg", 
        //     false, 
        //     true, 
        //     "Synth", 
        //     "Synth Violin", 
        //     5, 
        //     10_000, 
        //     .01 ether
        // );
        // uint[] memory colors = new uint[](5);
        // colors[0] = 1; colors[1] = 2; colors[2] = 3; colors[3] = 4; colors[4] = 5;
        // keyboardOZ.mint{value: keyboardOZ.price() * 5}(colors);
        // string memory tokenUri = keyboardOZ.tokenURI(5);
        // console.log(tokenUri);

        // keyboardOZ.updateScript('document.documentElement.addEventListener("keydown",e=>handleKeyPress(e.code)),document.documentElement.addEventListener("keyup",e=>handleKeyUp(e.code));let notes=["c","cSharp","d","dSharp","e","f","fSharp","g","gSharp","a","aSharp","b"],ip={},cn={},co=1,sus=!1,aSus=!1,csi=0,hl=!1,svg=document.getElementById("keyboard_svg"),soundsGroup=document.getElementById("allSounds");function toggleAutoSustain(){let e,t;(aSus=!aSus)?(e="on",t="600"):(e="off",t="585"),document.getElementById("sustain").textContent=e,document.getElementById("autoSustainButton2").setAttribute("x",t)}function toggleHighlight(){let e,t,a;(hl=!hl)?(t="50",a="43",e="on"):(t="35",a="57",e="off");let s=document.getElementById("hltext");s.textContent=e,s.setAttribute("x",a),document.getElementById("highlight2").setAttribute("x",t)}function toggleSounds(e){if((0!=csi||!(e<0))&&(csi!=names.length-1||!(e>0))){csi+=e,co=1,document.getElementById("currOctave").textContent="1-2",document.getElementById("selectedSound").textContent=`${csi+1}. ${names[csi]}`;Object.values(soundsGroup.children).map(e=>e.id).includes(names[csi])||loadSounds(csi)}}function loadSounds(e){let t=1,a=0,s=document.createElementNS("http://www.w3.org/1999/xhtml","g");s.setAttribute("id",names[e]),soundsGroup.appendChild(s);let c=document.getElementById("loadingBar"),n=document.getElementById("loadingRect");n.setAttribute("stroke","#000"),c.setAttribute("class","keyboard"),c.setAttribute("width","0");let u=12*octaves[e]+1,r=0;for(let o=0;o<u;o++){let k=new Audio(soundUris[e]+"/"+notes[a]+`${t}`+".flac");k.oncanplaythrough=()=>{r++,c.setAttribute("width",r/u*80),r==u&&(r=0,n.removeAttribute("stroke"),c.removeAttribute("class"))},k.setAttribute("type","audio/flac"),k.setAttribute("preload","auto"),k.setAttribute("id",notes[a]+`${t}`),s.appendChild(k),11==a?(a=0,t+=1):a+=1}svg.appendChild(soundsGroup)}function play(e){if(!0==cn[e])return;(oneShots[csi]||!polyphonic[csi])&&pauseAll(),cn[e]=!0;let t=document.getElementById(names[csi]).querySelector("#"+e);t.currentTime=0,t.play()}function pauseUp(e){cn[e]=!1,!oneShots[csi]&&pause(e)}function pause(e){if(!sus&&!aSus)document.getElementById(names[csi]).querySelector("#"+e).pause()}function pauseAll(){Object.keys(cn).forEach(e=>{cn[e]=!1,pause(e)})}function pausePlaying(){Object.keys(cn).forEach(e=>{!1==cn[e]&&pause(e)})}function changeOctave(e){let t=octaves[csi];(co+=e)<1&&(co=1),co>t&&(co=t);let a=`${co}-${co+1}`;co==t&&(a=t),document.getElementById("currOctave").textContent=a}function ku(e,t){pauseUp(ip[t])}function kd(e,t,a,s){let c=notes[a]+`${co+s}`;ip[t]=c,play(c)}function handleKeyUp(e){switch(e){case"KeyA":ku(e,0);break;case"KeyW":ku(e,1);break;case"KeyS":ku(e,2);break;case"KeyE":ku(e,3);break;case"KeyD":ku(e,4);break;case"KeyF":ku(e,5);break;case"KeyT":ku(e,6);break;case"KeyG":ku(e,7);break;case"KeyY":ku(e,8);break;case"KeyH":ku(e,9);break;case"KeyU":ku(e,10);break;case"KeyJ":ku(e,11);break;case"KeyK":ku(e,12);break;case"KeyO":ku(e,13);break;case"KeyL":ku(e,14);break;case"KeyP":ku(e,15);break;case"Semicolon":ku(e,16);break;case"Quote":ku(e,17);break;case"BracketRight":ku(e,18);break;case"Enter":ku(e,19);break;case"Space":sus=!1,pausePlaying(),aSus||(document.getElementById("sustain").textContent="off")}}function handleKeyPress(e){switch(e){case"Digit1":changeOctave(-1);break;case"Digit2":changeOctave(1);break;case"Digit9":toggleSounds(-1);break;case"Digit0":toggleSounds(1);break;case"KeyA":kd(e,0,0,0);break;case"KeyW":kd(e,1,1,0);break;case"KeyS":kd(e,2,2,0);break;case"KeyE":kd(e,3,3,0);break;case"KeyD":kd(e,4,4,0);break;case"KeyF":kd(e,5,5,0);break;case"KeyT":kd(e,6,6,0);break;case"KeyG":kd(e,7,7,0);break;case"KeyY":kd(e,8,8,0);break;case"KeyH":kd(e,9,9,0);break;case"KeyU":kd(e,10,10,0);break;case"KeyJ":kd(e,11,11,0);break;case"KeyK":kd(e,12,0,1);break;case"KeyO":kd(e,13,1,1);break;case"KeyL":kd(e,14,2,1);break;case"KeyP":kd(e,15,3,1);break;case"Semicolon":kd(e,16,4,1);break;case"Quote":kd(e,17,5,1);break;case"BracketRight":kd(e,18,6,1);break;case"Enter":kd(e,19,7,1);break;case"Space":sus=!0,aSus||(document.getElementById("sustain").textContent="on")}}loadSounds(0);');
        // keyboardOZ.setFrontend("https://twitter.com/jannotta_nolan");
        // tokenUri = keyboardOZ.tokenURI(5);
        // console.log(tokenUri);

        vm.stopBroadcast();
    }
}
