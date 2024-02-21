pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--red alert (v0.01)
--by fab.industries

--[[
incoming message from fleet
command:

the survivor you picked up
when surveying gaseous
anomalies in sector 649x518
has been identified as a
member of the metazoid alien
race, which has been considered
extinct for millenia. the
prophecy of nalesh - of which a
version exists among most
sentient races - states that
the return of the metazoid will
bring upon us the end of the
galaxy. many races have
dispatched armadas to kill your
passenger by destroying your
ship. fleet command recognises
the request for asylum entered
by your passenger. you must
reach starstation 47 at all
cost. defence directive omega
has been authorised.

good luck, captain!
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
 
 score=32767
 shield=100
 
 shipx=64
 shipy=64
 shipsx=0
 shipsy=0
 shipspr=1
 tailspr={7,8,9}
 bulx=64
 buly=-10
 pht=0
 torpflash=0
 
 stars={}

 for i=1,500 do
  local newstar={}
  newstar.x=flr(rnd(128))
  newstar.y=flr(rnd(512))
  newstar.spd=rnd(1.5)+0.5
  newstar.trl=flr(rnd(40))
  add(stars,newstar)
 end
 
 torps={}
 
end

-->8
--update

function update_game()

 shipsx=0
 shipsy=0
 shipspr=1
 tailspr={7,8,9}
 
 if btn(⬅️) then
  shipsx=-2
  shipspr=2
  tailspr={10,11,12}
 end
 if btn(➡️) then
  shipsx=2
  shipspr=3
   tailspr={13,14,15}
 end
 if btn(⬆️) then
  shipsy=-2
 end
 if btn(⬇️) then
  shipsy=2
 end
 
 --fires phaser
 if btnp(🅾️) then
  sfx(0)
  pht=15
  shipxf=shipx
 end

 --fires torpedo
 if btnp(❎) then
  local newtorp={}
  newtorp.x=shipx
  newtorp.y=shipy-3
  newtorp.flash=4
  add(torps,newtorp)
  
  sfx(1)
 end

 if pht>0 then
  pht-=1
 end

 --move ship
 shipx=shipx+shipsx
 shipy=shipy+shipsy
 
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
 
 --prevent ship from moving
 --off the edge of the screen
 if shipx>120 then
 	shipx=0
 end
 if shipx<0 then
  shipx=120
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
 spr(shipspr,shipx,shipy)
 
 --animate ship trail
 spr(tailspr[t\3%3+1],shipx,shipy+7)
 
 spr(16,64,20)
 spr(17,30,20)
 
 --animate torpedo
 for i=1,#torps do
  local mytorp=torps[i]
  local bspr={4,5,6}
  spr(bspr[t\1%3+1],mytorp.x,mytorp.y)
 end
 
 
 --phaser fire
 if pht>0 then
  line(shipx+2,shipy,shipxf+2,shipy-128,9)
 end
 
 --torpedo flash
 if torpflash>0 then
  circfill(shipx+4,shipy-2,torpflash,8)
  circfill(shipx+3,shipy-2,torpflash,9)
 end
 
 --drawing ui
 rectfill (0,0,127,6,0)
 
 rectfill(0,0,122,6,8)
 circfill(124,3,3,8)
 rectfill(5,0,7,6,0)
 print("red alert",10,1,0)
 print(score,105,1,0)

 rectfill(0,121,127,127,0)
 
 rectfill(0,121,4,127,8)
 rectfill(8,121,42,127,9)
 
 local tcol={5,8}
 rectfill(46,121,93,127,tcol[t\15%2+1])
 
 rectfill(97,121,115,127,2)
 rectfill(119,121,122,127,8)
 
 
 circfill(124,124,3,8)
 print("shd "..shield.."%",10,122,0)
 print("trp loading",48,122,0)
 print("p1t1",99,122,0)
end 

function draw_start()
 cls(0)

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
 fillp(0x7bdf)
 rectfill(24,10,103,12,b1_col)
 fillp(0xedb7)
 rectfill(24,15,103,17,b2_col) 
 fillp(0xa5a5)
 rectfill(24,20,103,22,b3_col)
 fillp()
 rectfill(24,25,103,27,b4_col)

 
 --bottom bars
 fillp(0x7bdf)
 rectfill(24,54,103,56,b1_col)
 fillp(0xedb7)
 rectfill(24,49,103,51,b2_col)
 fillp(0xa5a5)
 rectfill(24,44,103,46,b3_col)
 fillp()
 rectfill(24,39,103,41,b4_col)
  
 --left bars
 fillp(0xbfbf)
 rectfill(4,30,6,36,b1_col)
 fillp(0xefbf)
 rectfill(9,30,11,36,b2_col)
 fillp(0xa5a5)
 rectfill(14,30,16,36,b3_col)
 fillp()
 rectfill(19,30,21,36,b4_col)
 
 --right bars
 fillp(0xbfbf)
 rectfill(123,30,121,36,b1_col)
 fillp(0x7fdf)
 rectfill(118,30,116,36,b2_col)
 fillp(0xa5a5)
 rectfill(113,30,111,36,b3_col)
 fillp()
 rectfill(108,30,106,36,b4_col)
 
 --border
 rect(0,6,127,62,15)
 line(24,6,103,6,0)
 line(24,7,103,7,15)
 line(24,62,103,62,0)
 line(24,61,103,61,15)
 line(0,30,0,36,0)
 line(1,30,1,36,15)
 line(127,30,127,36,0)
 line(126,30,126,36,15)
 
 if imp==5 then 
  pal(8,15)
 elseif imp==6 then 
  pal(8,7)
 elseif imp==7 then 
  pal(8,7)
  elseif imp==8 then 
  pal(8,7)
 end
 
 spr(192,24,30,10,1)
 pal()
 
 local tcol={5,8}
 rectfill(36,82,66,88,tcol[t\15%2+1])
 
 rectfill(30,82,32,88,9)
 circfill(28,85,3,9)
 print("any key",38,83,0)
 
 rectfill(70,82,92,88,9)
 
 rectfill(96,82,101,88,9) 
 circfill(100,85,3,9)
 print("respd",72,83,0)
 
 print("capt to the bridge!",27,73,8)
 
 rectfill(0,65,20,69,9)
 rectfill(0,73,20,120,8)
 rectfill(17,65,20,116,0)

 rectfill(6,121,122,127,8)
 circfill(124,124,3,8)
 circfill(8,119,8,8)
 circfill(20,117,3,0)
 
 rectfill(32,121,34,127,0)
 
 print("(c) 2024",36,106,8)
 print("fab.industries",36,112,8)
 print("ver "..version,93,122,0)

end

function draw_over()
 cls(0)
 
  --drawing ui
 rectfill (0,0,127,6,0)
 
 rectfill(0,0,122,6,8)
 circfill(124,3,3,8)
 rectfill(5,0,7,6,0)
 print("red alert",10,1,0)
 print(score,105,1,0)

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
   if mystar.trl>=36 then
    line(mystar.x,mystar.y,mystar.x,mystar.y-mystar.trl,1)
   end
  elseif mystar.spd<1.3 then
   starcol=6
   if mystar.trl>=36 then
    line(mystar.x,mystar.y,mystar.x,mystar.y-mystar.trl,2)
   end 
  elseif mystar.spd<1.5 then
   starcol=7
   if mystar.trl>=36 then
    line(mystar.x,mystar.y,mystar.x,mystar.y-mystar.trl,13)
   end
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
__gfx__
00000000000660000066000000006600000000000000000000000000c000000cc000000cc000000c0c0000c00c0000c00c0000c00c0000c00c0000c00c0000c0
00000000007667000766700000076670000000000000000000000000cc0000cc1c0000c1cc0000cc0c000cc001000c100c000cc00cc000c001c000100cc000c0
007007000665566006556000000655600080080000080000000080001c0000c111000011cc0000cc01000c10010001100c000cc001c00010011000100cc000c0
0007700006655660065560000006556000099000000998000089900011000011010000101c0000c1010001100000010001000c10011000100010000001c00010
00077000006666000066600000066600000990000089900000099800010000101000000111000011000001000100001001000110001000000100001001100010
00700700885665880866588008856680008008000000800000080000100000010100001001000010010000100000010000000100010000100010000000100000
00000000670550760755076006705570000000000000000000000000010000100000000010000001000001000000000001000010001000000000000001000010
00000000070000700700070000700070000000000000000000000000000000000000000001000010000000000000000000000100000000000000000000100000
00588500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03b33b30500aa0050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5bbbbbb5506666050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
35055053606556060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
30055003a765567a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
30033003a667766a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b00bb00b076666700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000bb000007777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
88888888008888888808888888880000000088880000880000000888888880888888880088888888000000000000000000000000000000000000000000000000
88000088808800000008800008880000000088880000880000000880000000880000888000088000000000000000000000000000000000000000000000000000
88000008808800000008800000888000000880088000880000000880000000880000088000088000000000000000000000000000000000000000000000000000
88000088808888888808800000888000008800008800880000000888888880880000888000088000000000000000000000000000000000000000000000000000
88888888008800000008800000888000008800008800880000000880000000888888880000088000000000000000000000000000000000000000000000000000
88000088808800000008800008880000088888888880880000000880000000880000888000088000000000000000000000000000000000000000000000000000
88000008808888888808888888880000088000000880888888800888888880880000088000088000000000000000000000000000000000000000000000000000
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
