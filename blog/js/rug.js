  var canvas, context,output;  
  var x,y;
  var size = 50;
  var gap = 20;
  var vx = 25, vy = 25;
  
  window.onload = function() {

	  canvas = document.getElementById("canvas");	  
	  context = canvas.getContext("2d");
	  
	  x = canvas.width/2, y=canvas.height/2;	  
	  rug();
	  canvas.onmousemove = newrug;
  }
  
  function newrug(e)
  {
    var mx = e.pageX - canvas.offsetLeft;
	var my = e.pageY - canvas.offsetTop;
	
	context.strokeStyle = "rgb(" 
	   + Math.round(250 * (mx / canvas.width)) + "," 
	   + Math.round(250 * (my / canvas.width)) + ","
	   + Math.round(250 * ( ((100 * mx * my) % 1000) / 1000))
	   + ")";

	vx = 10 + Math.round(30 * (mx / canvas.width));
	vy = 10 + Math.round(30 * (my / canvas.height));
	gap = 10 + Math.round(20 * (( ((100 * mx * my) % 1000) / 1000)));	   
	
	rug();	
  }
  
  function rug()
  {
	  context.beginPath();
	  context.clearRect(0, 0, canvas.width, canvas.height);
	  for (var t = 0; t < 500; t++)
	  {
		ball(x,y,size,gap);
		
		var xbuffer = vx + size;
		var	ybuffer = vy + size;
		
		if (x > canvas.width - xbuffer  || x < size - vx ) vx *= -1;
		if (y > canvas.height - ybuffer || y < size - vy) vy *= -1;
		x += vx;
		y += vy;
	  }

	  context.stroke();
	  context.closePath();
  }
  
  function circle(x,y,r)
  {
	context.moveTo(x+r,y);
	context.arc(x,y,r,0,2*Math.PI);
  }
  
  function ball(x,y,maxr,step)
  {
	for (var r=0; r<maxr; r+=step)
	{
		circle(x,y,r);
	}
  }