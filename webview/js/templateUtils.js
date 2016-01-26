window.onload=function(){
    
//    initSwiper(2);
    
    var textDomList=document.getElementsByClassName("text_element");
    for(var i=0;i<textDomList.length;i++){
        textDomList[i].index=i;
        textDomList[i].onclick=function(){
            console.log("text_element:",new String(this.innerHTML).trim(), this.index);
            if(this.getAttribute("islist")=="true"){
                clickedText(this.innerHTML, this.index,true);
            }else{
                clickedText(this.innerHTML, this.index,false);
            }
        }
    }
    
    var imgDomList=document.getElementsByClassName("img_element");
    for(var i=0;i<imgDomList.length;i++){
        imgDomList[i].index=i;
        imgDomList[i].addEventListener("click",function(){
                                       console.log("img_element:", this.index);
                                       clickedImage(this.index);
                                       })
    }
    
}


function addListItem(index){
    var dom=document.getElementsByClassName("text_element")[index];
    var a=document.createElement("li");
    a.className="text_element";
    a.setAttribute("islist","true");
    a.innerHTML="Please fill in content."
    dom.parentElement.appendChild(a);
    
    var textDomList=document.getElementsByClassName("text_element");
    for(var i=0;i<textDomList.length;i++){
        textDomList[i].index=i;
        textDomList[i].onclick=function(){
            console.log("text_element:",new String(this.innerHTML).trim(), this.index);
            if(this.getAttribute("islist")=="true"){
                clickedText(this.innerHTML, this.index,true);
            }else{
                clickedText(this.innerHTML, this.index);
            }
        }
    }
}
function deleteCurrentLine(index){
    var dom=document.getElementsByClassName("text_element")[index];
    dom.remove();
    
    var textDomList=document.getElementsByClassName("text_element");
    for(var i=0;i<textDomList.length;i++){
        textDomList[i].index=i;
        textDomList[i].onclick=function(){
            console.log("text_element:",new String(this.innerHTML).trim(), this.index);
            if(this.getAttribute("islist")=="true"){
                clickedText(this.innerHTML, this.index,true);
            }else{
                clickedText(this.innerHTML, this.index);
            }
        }
    }
}
