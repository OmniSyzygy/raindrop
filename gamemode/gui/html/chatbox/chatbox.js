var chatbox = chatbox || {};

chatbox.AddMessage = function(Sender, Message, SenderStyle, MessageStyle){
	var chatbox = document.getElementById("chatbox");
  var chatmessage = document.createElement("div");
  
  chatmessage.className = "chatmessage";
  chatmessage.innerHTML = ""
  
  if (typeof SenderStyle === "undefined"){
  	chatmessage.innerHTML += "<span class = 'sender'>" + Sender + ":</span> "
  }
  else
  {
  	chatmessage.innerHTML += "<span class = 'sender' style = '" + SenderStyle + "' >" + Sender + ": </span>"
  }
  
  if (typeof MessageStyle === "undefined"){
  	chatmessage.innerHTML += "<span class = 'message'>" + Message + "</span>"
  }
  else
  {
   chatmessage.innerHTML += "<span class = 'message' style = '" + MessageStyle + "' >" + Message + "</span>"
  }
  
  chatbox.appendChild(chatmessage);
}

chatbox.AddRawMessage = function(Message, MessageStyle){
	var chatbox = document.getElementById("chatbox");
  var chatmessage = document.createElement("div");
  
  chatmessage.className = "chatmessage";
  if (typeof MessageStyle === "undefined")
  {
  	chatmessage.innerHTML = Message
  }
  
  chatbox.appendChild(chatmessage);
}