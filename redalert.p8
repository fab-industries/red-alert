pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--red alert (v0.01)
--by fab.industries

--[[
incoming message from fleet
command:

you are ordered to proceed to
sector 6547 mark 192 with
utmost speed. it is imperative
that your ship secures the area
and denies any and all hostile
vessels. use of force is
authorised. implement the
omega directive immediately.
all other priorities have been
recinded.
--]]

function _init()
 version="0.01"
 
 cls(0)
 t=0
 mode="start"
end

function _update()
 t+=1
 if mode=="game" then
  update_game()
 elseif mode=="start" then
  update_start()
 elseif mode=="over" then
  update_over()
 end
end

function _draw()
 if mode=="game" then
  draw_game()
 elseif mode=="start" then
  draw_start()
 elseif mode=="over" then
  draw_over()
 end
end

function start_game()
 mode="game"
  
 tailspr={7,8,9}
 torpflash=0
 phend=-128
 tcols={1,2,5}
 ship={}
 ship.x=64
 ship.y=64
 ship.sx=0
 ship.sy=0
 ship.spr=1
 ship.xf=64
 ship.pht=0
 ship.torp=true
 ship.ttmr=0
 ship.shield=100
 ship.cont=true
 invuln=0
 stars={}
 torps={}
 enemies={}
 explods={}
 score=0
 scoredisp=0

 for i=1,500 do
  local newstar={}
  newstar.x=flr(rnd(128))
  newstar.y=flr(rnd(512))
  newstar.spd=rnd(1.5)+0.5
  newstar.trl=flr(rnd(40))+60
  newstar.trlcol=rnd(tcols)
  
  add(stars,newstar)
 end
 
 spwn_en()
  
end

-->8
--update

function update_game()

 ship.sx=0
 ship.sy=0
 ship.spr=1
 tailspr={7,8,9}
 
 if ship.ttmr>0 then
  ship.ttmr-=1
 else 
  ship.torp=true
 end
 
 if btn(⬅️) then
  ship.sx=-2
  ship.spr=2
  tailspr={10,11,12}
 end
 if btn(➡️) then
  ship.sx=2
  ship.spr=3
   tailspr={13,14,15}
 end
 if btn(⬆️) then
  ship.sy=-2
 end
 if btn(⬇️) then
  ship.sy=2
 end
 
 --fires phaser
 if btnp(❎) then
  sfx(0)
  ship.pht=15
  ship.xf=ship.x
 end

 --fires torpedo
 if btnp(🅾️) and ship.torp then
  local newtorp={}
  newtorp.x=ship.x
  newtorp.y=ship.y-3
  newtorp.flash=4
  newtorp.spr=4
  add(torps,newtorp)
  
  ship.torp=false
  ship.ttmr=5*30
  sfx(1)
 end

 if ship.pht>0 then
  ship.pht-=1
 end

 --move enemies 
 for myen in all(enemies) do
  myen.y+=1
  if myen.y>128 then
   del(enemies,myen)
   spwn_en()
  end
 end
 
 --collision torpedo x enemies
 for myen in all(enemies) do
  if myen.invuln<=0 then
	  for mytorp in all(torps) do
	   if col(myen,mytorp) then
	    del(torps,mytorp)
	    sfx(5)
	    score+=5
	    score+=20
	    myen.hp-=5 
		   if myen.hp<=0 then
		    kill_en(myen)
		   end
	   end
	  end
  else
	  myen.invuln-=1
	 end
 end
 
 --collision phaser x enemies
 for myen in all(enemies) do
	 if phcol(ship.x+2,ship.y,ship.xf+2,ship.y-128,myen) and ship.pht>0 then
	  phend=myen.y+10
	  if myen.invuln<=0 then  
	   sfx(4)
	   score+=1
	   score+=20
	 	 myen.hp-=1
	 	 myen.invuln=30  
		  if myen.hp<=0 then
     kill_en(myen)
		  end
   else
	   myen.invuln-=1
	  end
	 end
 end
 
 --collision ship x enemies
 if invuln<=0 then
	 for myen in all(enemies) do
	  if col(myen,ship) then
	   ship.shield-=30
	   sfx(2)
	   invuln=60
	   myen.hp-=50
	   if myen.hp<=0 then
     kill_en(myen)
	   end
	   
	   if ship.cont==false then
     mode="over"
     return
	   end
	   
	  end
	 end
	else
	 invuln-=1
 end
 
 --check if shield is gone
 if (ship.shield<=0) ship.cont=false
 
 --move ship
 ship.x+=ship.sx
 ship.y+=ship.sy
 
 --prevent ship from moving
 --off the edge of the screen
 if ship.x>120 then
 	ship.x=120
 end
 if ship.x<0 then
  ship.x=0
 end
 if ship.y<7 then
  ship.y=7
 end
 if ship.y>110 then
  ship.y=110
 end
 
 --move torps
 for i=#torps,1,-1 do
  local mytorp=torps[i]
  mytorp.y-=3
  --delete torp as it moves
  --off screen
  if mytorp.y<-8 then
   del(torps,mytorp)
  end 
 end
 --animate torpflash
 if torpflash>0 then
  torpflash-=1
 end
 
 anim_stars()
 
end

function update_start()
 if btnp(❎) or btnp(🅾️) then
  start_game()
 end
end

function update_over()
 if btnp(❎) or btnp(🅾️) then
  mode="start"
 end
end
-->8
--draw

function draw_game()
 cls(0)
 starfield()
 if invuln<=0 then
  draw_spr(ship)
  spr(tailspr[t\3%3+1],ship.x,ship.y+7)
 else
  --invuln state
  if sin(t/7)<0.5 then
   fillp(0xd7b6)
   ovalfill(ship.x-3,ship.y-6,ship.x+10,ship.y+16,12)
   fillp()
   pal(5,12)
   pal(6,12)
   pal(7,12)
   pal(8,2)
   draw_spr(ship)
   pal()
   spr(tailspr[t\3%3+1],ship.x,ship.y+7) 
   oval(ship.x-3,ship.y-6,ship.x+10,ship.y+16,12)  
  else
   pal(5,6)
   pal(6,7)
   pal(8,7)
   draw_spr(ship)
   pal()
   spr(tailspr[t\3%3+1],ship.x,ship.y+7)
   oval(ship.x-3,ship.y-6,ship.x+10,ship.y+16,7)
  end
 end
 
 --drawing enemies
 for myen in all(enemies) do
  local enspr={16,16,16,17}
  myen.spr=enspr[t\30%4+1]
  if myen.invuln>0 then
   if sin(t/7)<0.5 then
	   fillp(0xd7b6)
	   ovalfill(myen.x-2,myen.y-4,myen.x+9,myen.y+11,8)
	   fillp()
	   pal(3,8)
	   pal(5,8)
	   pal(11,8)
	   pal(8,2)
	   draw_spr(myen)
	   pal()
	   oval(myen.x-2,myen.y-4,myen.x+9,myen.y+11,8)  
   else
	   pal(3,7)
	   pal(5,6)
	   pal(11,7)
	   draw_spr(myen)
	   pal()
	   oval(myen.x-2,myen.y-4,myen.x+9,myen.y+11,8)
   end
  else
   draw_spr(myen)     
  end
 end
 
 --animate torpedo
 for mytorp in all(torps) do 
  local bspr={4,5,6}
  mytorp.spr=bspr[t\1%3+1]
  draw_spr(mytorp)
 end
 
 --phaser fire
 if ship.pht>0 then
  line(ship.x+2,ship.y,ship.xf+2,phend,9)
 end
 
 --torpedo flash
 if torpflash>0 then
  circfill(ship.x+4,ship.y-2,torpflash,8)
  circfill(ship.x+3,ship.y-2,torpflash,9)
 end
 
 --explosions
 for myexpl in all(explods) do
  --explosion draw code goes
  --here
 end
 
 if phend!=-128 and t%6==0 then
  phend=-128
 end
 
 draw_ui()

 --tick up score display
 if (scoredisp<score) scoredisp+=1
 
end 

function draw_start()
 cls(0)

 draw_ui()
 
end

function draw_over()
 cls(0)
 
 draw_ui()
  
end
-->8
--tools

function starfield()
 --creates background stars 
 for i=1,#stars do
 
  local mystar=stars[i]  
  --colour stars based on
  --their speeds
  local starcol=7
  if mystar.spd<0.6 then
   starcol=1
  elseif mystar.spd<0.8 then
   starcol=2
  elseif mystar.spd<1 then
   starcol=12
  elseif mystar.spd<1.3 then
   starcol=6
  elseif mystar.spd<1.5 then
   starcol=7
  end
  
  --create warp trails
  if mystar.spd>=1.9 then
   line(mystar.x,mystar.y,mystar.x,mystar.y-mystar.trl,mystar.trlcol)
  end

  pset(mystar.x,mystar.y,starcol) 
 
 end 
 
end

function anim_stars()
 --animates the starfield 
 for i=1,#stars do
  local mystar=stars[i]
  mystar.y=mystar.y+mystar.spd
  if mystar.y>512 then
   mystar.y=mystar.y-512
  end
 end
end

function draw_spr(sp)
 spr(sp.spr,sp.x,sp.y)
end

function col(a,b)
 if a.y>b.y+7 then return false end
 if b.y>a.y+7 then return false end
 if a.x>b.x+7 then return false end
 if b.x>a.x+7 then return false end

 return true
end

function phcol(phx1,phy1,phx2,phy2,obj)
 if linecol(phx1,phy1,phx2,phy2,obj.x,obj.y,obj.x,obj.x+7) then return true end
 if linecol(phx1,phy1,phx2,phy2,obj.x+7,obj.y,obj.x+7,obj.y+7) then return true end
 if linecol(phx1,phy1,phx2,phy2,obj.x,obj.y,obj.x+7,obj.y) then return true end
 if linecol(phx1,phy1,phx2,phy2,obj.x,obj.y+7,obj.x+7,obj.y+7) then return true end
 
 return false
end

function linecol(x1,y1,x2,y2,x3,y3,x4,y4)
 ua=((x4-x3)*(y1-y3)-(y4-y3)*(x1-x3))/((y4-y3)*(x2-x1)-(x4-x3)*(y2-y1))
 ub=((x2-x1)*(y1-y3)- (y2-y1)*(x1-x3))/((y4-y3)*(x2-x1)-(x4-x3)*(y2-y1))
 
 if ua>=0 and ua<=1 and ub>=0 and ub<=1 then return true end

 return false
end

function spwn_en()
 local myen={}
 myen.x=rnd(120)
 myen.y=-8
 myen.spr=16
 myen.hp=4
 myen.invuln=0
 
 add(enemies,myen)
end

function kill_en(myen)
	del(enemies,myen)
	sfx(3)
	explode(myen.x,myen.y)
	spwn_en()
end

function explode(expx,expy)
 local myexpl={}
 myexpl.x=expx
 myexpl.y=expy
 add(explods,myexpl)
end

function draw_ui()

 if mode=="game" then
 
	 rectfill (0,0,127,6,0)
	 rectfill(0,0,122,6,8)
	 circfill(124,3,3,8)
	 rectfill(5,0,7,6,0)
	 print("red alert",10,1,0)
	 local scx
	 local scl
	 scl=tostr(scoredisp)
	 if (#scl==1) scx=121
	 if (#scl==2) scx=117
	 if (#scl==3) scx=113
	 if (#scl==4) scx=109
	 if (#scl==5) scx=105
	 print(scoredisp,scx,1,0)
	 rectfill(0,121,127,127,0)
	 rectfill(0,121,4,127,8)
	 local scol={10,10}
	 if ship.shield>60 then
	  scol={10,10}
	 elseif ship.shield>20 then
	  scol={9,9} 
	 elseif ship.shield>0 then
	  scol={8,8}
	 elseif ship.shield<=0 then 
	  scol={8,5}
	 end
	 rectfill(8,121,42,127,scol[t\15%2+1])
	 rectfill(97,121,115,127,2)
	 rectfill(119,121,122,127,8)
	 circfill(124,124,3,8)
	 if ship.shield>0 then
	  print("shd "..ship.shield.."%",10,122,0)
	 else
	  print("shd ".."off",10,122,0) 
	 end
	 
	 if ship.torp then
	  rectfill(46,121,93,127,10)
	  print("trp ready",52,122,0)
	 else
	  local tcol={8,5}
	  rectfill(46,121,93,127,tcol[t\15%2+1])
	  print("trp loading",48,122,0)
	 end
	 print("up 0",99,122,0)
 
 elseif mode=="start" then

	 --bar colour fx
	 local imp=t\6%8+1
	 local bar_cols={2,8,15}
	 local b1_col=5
	 local b2_col=5
	 local b3_col=2
	 local b4_col=2
	
	 if imp==1 then
	  b1_col=5
	  b2_col=5
	  b3_col=2
	  b4_col=2
	 elseif imp==2 then
	  b1_col=15
	  b2_col=2
	  b3_col=2
	  b4_col=2 
	 elseif imp==3 then
	  b1_col=8 
	  b2_col=15
	  b3_col=2
	  b4_col=2
	 elseif imp==4 then
	  b1_col=8
	  b2_col=8
	  b3_col=15
	  b4_col=2  
	 elseif imp==5 then 
	  b1_col=2
	  b2_col=8
	  b3_col=8 
	  b4_col=15
	 elseif imp==6 then 
	  b1_col=2
	  b2_col=2
	  b3_col=8
	  b4_col=8
	 elseif imp==7 then 
	  b1_col=5
	  b2_col=2
	  b3_col=2
	  b4_col=8
	 elseif imp==8 then 
	  b1_col=5
	  b2_col=5
	  b3_col=2
	  b4_col=2
	 end
	
	 --top bars
	 fillp(0x5bff)
	 rectfill(24,4,103,6,b1_col)
	 fillp(0xedb7)
	 rectfill(24,9,103,11,b2_col) 
	 fillp(0xa5a5)
	 rectfill(24,14,103,16,b3_col)
	 fillp()
	 rectfill(24,19,103,21,b4_col)
	
	 --bottom bars
	 fillp(0xb5ff)
	 rectfill(24,48,103,50,b1_col)
	 fillp(0xb7fd)
	 rectfill(24,43,103,45,b2_col)
	 fillp(0xa5a5)
	 rectfill(24,38,103,40,b3_col)
	 fillp()
	 rectfill(24,33,103,35,b4_col)
	  
	 --left bars
	 fillp(0xbfbf)
	 rectfill(4,24,6,30,b1_col)
	 fillp(0xefbf)
	 rectfill(9,24,11,30,b2_col)
	 fillp(0xa5a5)
	 rectfill(14,24,16,30,b3_col)
	 fillp()
	 rectfill(19,24,21,30,b4_col)
	 
	 --right bars
	 fillp(0xbfbf)
	 rectfill(123,24,121,30,b1_col)
	 fillp(0x7fdf)
	 rectfill(118,24,116,30,b2_col)
	 fillp(0xa5a5)
	 rectfill(113,24,111,30,b3_col)
	 fillp()
	 rectfill(108,24,106,30,b4_col)
	 
	 --border
	 rect(0,0,127,54,15)
	 line(24,0,103,0,0)
	 line(24,1,103,1,15)
	 line(24,54,103,54,0)
	 line(24,53,103,53,15)
	 line(0,24,0,30,0)
	 line(1,24,1,30,15)
	 line(127,24,127,30,0)
	 line(126,24,126,30,15)
	 
	 if imp==5 then 
	  pal(8,15)
	 elseif imp==6 then 
	  pal(8,7)
	 elseif imp==7 then 
	  pal(8,7)
	  elseif imp==8 then 
	  pal(8,7)
	 end
	 
	 spr(192,24,24,10,1)
	 pal()
	 local tcol={5,8}
	 rectfill(36,79,66,85,tcol[t\15%2+1])
	 rectfill(30,79,32,85,9)
	 circfill(28,82,3,9)
	 print("any key",38,80,0)
	 rectfill(70,79,92,85,9)
	 rectfill(96,79,101,85,9) 
	 circfill(100,82,3,9)
	 print("respd",72,80,0)
	 print("capt to the bridge!",27,68,8)
	 rectfill(0,57,16,61,9)
	 rectfill(0,65,20,120,8)
	 rectfill(17,65,20,116,0)
	 rectfill(6,121,122,127,8)
	 circfill(124,124,3,8)
	 circfill(8,119,8,8)
	 circfill(20,117,3,0)
	 rectfill(32,121,34,127,0)
	 
	 print("(c) 2024",36,106,8)
	 print("fab.industries",36,112,8)
	 print("ver "..version,93,122,0)

 elseif mode=="over" then

	 rectfill (0,0,127,6,0) 
	 rectfill(0,0,122,6,8)
	 circfill(124,3,3,8)
	 rectfill(5,0,7,6,0)
	 print("red alert",10,1,0)
	 local scx
	 local scl
	 scl=tostr(score)
	 if (#scl==1) scx=121
	 if (#scl==2) scx=117
	 if (#scl==3) scx=113
	 if (#scl==4) scx=109
	 if (#scl==5) scx=105
	 print(score,scx,1,0)
	 rectfill(0,121,127,127,0)
	 rectfill(0,121,4,127,8)
	 rectfill(8,121,42,127,5)
	 rectfill(46,121,93,127,5)
	 rectfill(97,121,115,127,5)
	 rectfill(119,121,122,127,8)
	 circfill(124,124,3,8)
	 print("your ship lost",36,40,2)
	 print("core containment",32,46,8)
	 print("and was destroyed.",29,52,2)
	 local tcol={5,8}
	 rectfill(35,72,65,78,tcol[t\15%2+1])
	 rectfill(29,72,31,78,9)
	 circfill(27,75,3,9)
	 print("any key",37,73,0)
	 rectfill(69,72,91,78,9)
	 rectfill(95,72,100,78,9) 
	 circfill(99,75,3,9)
	 print("aknwl",71,73,0)
 end

end
__gfx__
00000000000660000066000000006600000000000000000000000000c000000cc000000cc000000c0c0000c00c0000c00c0000c00c0000c00c0000c00c0000c0
00000000007667000766700000076670000000000000000000000000cc0000cc1c0000c1cc0000cc0c000cc001000c100c000cc00cc000c001c000100cc000c0
007007000665566006556000000655600080080000080000000080001c0000c111000011cc0000cc01000c10010001100c000cc001c00010011000100cc000c0
0007700006655660065560000006556000099000000998000089900011000011010000101c0000c1010001100000010001000c10011000100010000001c00010
00077000006666000066600000066600000990000089900000099800010000101000000111000011000001000100001001000110001000000100001001100010
00700700885665880866588008856680008008000000800000080000100000010100001001000010010000100000010000000100010000100010000000100000
00000000670550760755076006705570000000000000000000000000010000100000000010000001000001000000000001000010001000000000000001000010
00000000070000700700070000700070000000000000000000000000000000000000000001000010000000000000000000000100000000000000000000100000
00588500005225000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03b33b3003b33b30500aa00500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5bbbbbb55bbbbbb55066660500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
35055053350550536065560600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3005500330055003a765567a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3003300330033003a667766a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b00bb00bb00bb00b0766667000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000bb000000bb0000077770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888008888888808888888880000000088880000880000000888888880888888880088888888000000000000888888880000000000000000000000000000
88000088808800000008800008880000000088880000880000000880000000880000888000088000000000000888888888888880000000000000000000000000
88000008808800000008800000888000000880088000880000000880000000880000088000088000000000088888888888888888800000000000000000000000
88000088808888888808800000888000008800008800880000000888888880880000888000088000000000888888888888888888880000000000000000000000
88888888008800000008800000888000008800008800880000000880000000888888880000088000000008888888800000088888888000000000000000000000
88000088808800000008800008880000088888888880880000000880000000880000888000088000000088888880000000000888888800000000000000000000
88000008808888888808888888880000088000000880888888800888888880880000088000088000000888888000000000000008888880000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000008888880000000000000000888888000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000008888800000000000000000088888000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000088888800000000000000000088888800000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000088888000000000000000000008888800000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000088888000000000000000000008888800000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000888880000000000000000000000888880000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000888880000000000000000000000888880000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000888880000000000000000000000888880000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000888880000000000000000000000888880000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000888880000000000000000000000888880000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000888880000000000000000000000888880000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000888880000000000000000000000888880000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000888880000000000000000000000888880000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000088888000000000000000000008888800000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000088888000000000000000000008888800000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000088888800000000000000000088888800000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000008888800000000000000000088888000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000008888880000000000000000888888000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000888880000000000000000888880000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000088888000000000000008888800000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000008888000000000000008888000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000800088888000000000000008888800080000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000888888888800000000000088888888880000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000888888888800000000000088888888880000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000088888888800000000000088888888800000000000000000
__label__
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddmddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddmmddddmdddmmdmdddddddddddddddmddmdmdddmdddddddddddddddddddddddddddddddmmddmmmmdddddddddddddddddmmddddddddddmmdm
mddddddddmdddmdddddddddddddddddmdddddddddddddddddddddddmdmddddddmddddddmmddddddddddddddddddmddmdddddmdddddddddddmmdmmdddddmdmddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd

__sfx__
0001000001350023500535007320093200e3201132010320173201a3201d320223202232019320223202132021320213201c32021330213301e3401a3400d35012340143400a3300632005310023500035001350
000200000f2201123015230202402b240372403b2503f2503f2503f2603e2603c2603826034260302602b2602726023260212601d2601b2501825016250152501325011240102400e2400d2300b2300a23009220
000100002e6502c65028650226501a650136500e65009640066300663005620046100461002610016000160000000020000000000000000000000000000000000000000000000000000000000000000000000000
000100003965031250086503465028630132200a62005220042200221000000000000000002650000000000000650016500000002650036300165001620016500062001620006100000000610000000061000000
0001000019750097403b7600070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000100001025026240342203d250342003720037200212000420007200202000020020200202000a200042000c200062001d20000200002000020000200002000020000200002000020000200002000020000200
