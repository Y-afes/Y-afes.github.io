(function(){
"use strict";
const KEY="quisensor-site-lang";
let lang="TR";
try{if(localStorage.getItem(KEY)==="EN")lang="EN";}catch(_){}
const button=document.getElementById("language-toggle");
function render(){
 document.documentElement.lang=lang==="TR"?"tr":"en";
 for(const node of document.querySelectorAll("[data-tr][data-en]")){
  node.textContent=node.getAttribute(lang==="TR"?"data-tr":"data-en");
 }
 if(button){button.textContent=lang;button.setAttribute("aria-label",lang==="TR"?"Switch to English":"Türkçeye geç");}
}
if(button)button.addEventListener("click",()=>{lang=lang==="TR"?"EN":"TR";try{localStorage.setItem(KEY,lang);}catch(_){}render();});
render();
})();
