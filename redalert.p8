pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--red alert (v0.01)
--by fab.industries

--[[

todo:

 ❎ explosion effect on boss
    hit (phs+torps)
 🅾️ enemy movement
 🅾️ proper enemy waves / spawn
    patterns
 🅾️ enemy shooting
 🅾️ player shield mechanics
 🅾️ weapon upgrades
 🅾️ debug setting: replace
    pause menu with screenshot
    mode for cart img
 🅾️ music

]]--

function _init()
 version="0.01"
 
 debug_setting={}
 debug_setting.info=true
 debug_setting.hideui=false
 
 cls(0)
 t=0
 btnlock=0
 hitlock=0
 
 startscreen()
 
end

function _update()
 t+=1
 if mode=="game" then
  update_game()
 elseif mode=="start" then
  update_start()
 elseif mode=="intro" then
  update_intro()
 elseif mode=="over" then
  update_over()
 end
end

function _draw()
 if mode=="game" then
  draw_game()
 elseif mode=="start" then
  draw_start()
 elseif mode=="intro" then
  draw_intro() 
 elseif mode=="over" then
  draw_over()
 end
 
 debug() 
 
end

function startscreen()
 mode="start"
end


function start_game()
 mode="intro"
 t=0
 timeout=120
 imode=1
 introt=0
   
 tailspr={7,8,9}
 torpflash=0
 phend=-128
 tcols={1,2,5}
 ship={}
 ship.x=64
 ship.y=80
 ship.sx=0
 ship.sy=0
 ship.spr=1
 ship.sprw=1
 ship.sprh=1
 ship.colpx=7
 ship.xf=64
 ship.pht=0
 ship.torp=true
 ship.ttmr=0
 ship.shield=100
 ship.cont=true
 ship.dead=false
 ship.warp=false
 invuln=0
 stars={}
 torps={}
 enemies={}
 particles={}
 score=0
 scoredisp=0
 
 wave=0
 wavtime=0
 wavspwned=false
 
 for i=1,500 do
  local newstar={}
  newstar.x=flr(rnd(128))
  newstar.y=flr(rnd(512))
  newstar.spd=rnd(0.4)+0.2
  newstar.trl=flr(rnd(40))+60
  newstar.trlcol=rnd(tcols)
  
  add(stars,newstar)
 end
  
end

-->8
--update

function update_game()
 ship.sx=0
 ship.sy=0
 ship.spr=1
 tailspr={7,8,9}
 
 chk_wav()
  
 if ship.cont==false then
  if timeout>0 then 
   timeout-=1
	 else
	  music(0)
	  mode="over"
	  btnlock=t+60
   return
  end
 end
 
 if ship.ttmr>0 then
  ship.ttmr-=1
 else 
  ship.torp=true
 end
 
 if ship.dead==false and mode=="game" then
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
	  newtorp.colpx=7
	  add(torps,newtorp)
	  
	  ship.torp=false
	  ship.ttmr=5*30
	  sfx(1)
	 end
 end

 if ship.pht>0 then
  ship.pht-=1
 end

 --move enemies 
 for myen in all(enemies) do
  myen.y+=myen.sy
  if myen.y>128 then
   local etype=myen.type
   del(enemies,myen)
  end
 end
 
 --collision torpedo x enemies
 for myen in all(enemies) do
  for mytorp in all(torps) do
   if col(myen,mytorp) then
    del(torps,mytorp)
    sfx(5)
    score+=5
    score+=20
    myen.hp-=5 
	   if myen.hp<=0 then
	    kill_en(myen)
	   else
	    hitexplod(myen)
	   end
   end
  end
 end
 
 --collision phaser x enemies
 for myen in all(enemies) do
	 if phcol(ship.x+2,ship.y,ship.xf+2,ship.y-128,myen) and ship.pht>0 then
	  phend=myen.y+myen.colpx
	    
	  if t>hitlock and myen.type=="bots" then
	   create_part("hit",myen.x,phend,myen.sx,myen.sy)
	   hitlock=t+10
	  end
	    
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
 if invuln<=0 and ship.dead==false then
	 for myen in all(enemies) do
	  if col(myen,ship) then
	   --check if shield is gone
    --if ship.shield<=0 then
     ship.cont=false
     core_breach()
	   --end
	   --ship.shield-=30
	   ship.shield=0
	   sfx(2)
	   --invuln=60
	   myen.hp-=50
	   if myen.hp<=0 then
     kill_en(myen)
	   end
	   
	  end
	 end
	else
	 invuln-=1
 end
 
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

 if btn(❎)==false and btn(🅾️)==false then 
  btnrel=true
 end

 if btnrel then
  if btnp(❎) or btnp(🅾️) then
   btnrel=false
   start_game()
  end
 end
end

function update_over()

 if t<btnlock then
  return
 end

 if btn(❎)==false and btn(🅾️)==false then 
  btnrel=true
 end

 if btnrel then
  if btnp(❎) or btnp(🅾️) then
   btnrel=false
   startscreen()
  end
 end
end

function update_intro()
 update_game()
 
 --skip intro messages
 
 if btn(❎)==false and btn(🅾️)==false then 
  btnrel=true
 end

 if btnrel then
  if btnp(❎) or btnp(🅾️) then
   btnrel=false
   if imode<3 then
    imode+=1
   end
  end
 end
 
 if imode==3 then
  introt+=1
 end
 
 if introt==45 then
  sfx(7)
  reset_starspd()
  ship.warp=true
 end
 
 if introt>=90 then
  mode="game"
 end
end
-->8
--draw

function draw_game()
 cls(0)
 
 if mode=="intro" and introt<45 then
  starfield_imp()
 else
  starfield()
 end
 
 draw_ship()
 
 --drawing enemies
 for myen in all(enemies) do
  
  if myen.type=="bots" then
   myen.spr=myen.ani[t\50%4+1]
  else
   myen.spr=myen.ani[t\2%4+1]
  end
  
  if myen.invuln>0 then
	  if myen.type=="tingan" then
	   if sin(t/7)<0.5 then
		   fillp(0xd7b6)
		   ovalfill(myen.x-2,myen.y-4,myen.x+9,myen.y+11,8)
		   fillp()
		   pal(3,8)
		   pal(5,8)
		   pal(11,8)
		   pal(8,2)
		   pal(14,2)
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
	  elseif myen.type=="aquilan" then
	   if sin(t/7)<0.5 then
		   fillp(0xd7b6)
		   ovalfill(myen.x-2,myen.y-4,myen.x+9,myen.y+11,11)
		   fillp()
		   pal(5,3)
		   pal(6,3)
		   pal(7,3)
		   pal(10,3)
		   pal(11,3)
		   draw_spr(myen)
		   pal()
		   oval(myen.x-2,myen.y-4,myen.x+9,myen.y+11,11)  
	   else
		   pal(6,7)
		   pal(5,6)
		   pal(10,7)
		   draw_spr(myen)
		   pal()
		   oval(myen.x-2,myen.y-4,myen.x+9,myen.y+11,11)
	   end  
   elseif myen.type=="dicean" then
	   if sin(t/7)<0.5 then
		   fillp(0xd7b6)
		   ovalfill(myen.x-2,myen.y-4,myen.x+9,myen.y+11,9)
		   fillp()
		   pal(4,9)
		   pal(5,9)
		   pal(8,9)
		   pal(9,10)
		   pal(10,9)
		   pal(11,9)
		   draw_spr(myen)
		   pal()
		   oval(myen.x-2,myen.y-4,myen.x+9,myen.y+11,9)  
	   else
		   pal(9,7)
		   pal(10,7)
		   pal(4,6)
		   pal(5,6)
		   pal(8,6)
		   draw_spr(myen)
		   pal()
		   oval(myen.x-2,myen.y-4,myen.x+9,myen.y+11,9)
	   end
   elseif myen.type=="franconi" then
	   if sin(t/7)<0.5 then
		   pal(2,9)
		   pal(5,8)
		   draw_spr(myen)
		   pal()
		   fillp(0xd7b6)
		   oval(myen.x-2,myen.y-4,myen.x+9,myen.y+11,2)    
     fillp()	   
	   else
		   pal(2,7)
		   pal(5,6)
		   draw_spr(myen)
		   pal()
	   end 
	  elseif myen.type=="bots" then
	   if sin(t/7)<0.5 then
		   draw_spr(myen)
		   fillp(0xfdbf.8)
		   circfill(myen.x+8,myen.y+8,7,3)    
     fillp()	   
	   else
		   draw_spr(myen)
		   fillp(0xfbdf.8)
		   circfill(myen.x+8,myen.y+8,7,3)    
     fillp()	
	   end	     
	  end
  else
   draw_spr(myen)     
  end
 end
 
 --animate torpedo
 for mytorp in all(torps) do 
  local bspr={4,5,6}
  mytorp.spr=bspr[t\1%3+1]
  mytorp.sprw=1
  mytorp.sprh=1
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
 
 --particles
 draw_part()
 
 --reset phaser target point
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

function draw_intro()
 draw_game()
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

function starfield_imp()
 --creates background stars 
 for i=1,#stars do
  local mystar=stars[i]  
  --colour stars based on
  --their speeds
  local starcol=7
  if mystar.spd<0.2 then
   starcol=1
  elseif mystar.spd<0.3 then
   starcol=2
  elseif mystar.spd<0.4 then
   starcol=12
  elseif mystar.spd<0.5 then
   starcol=6
  elseif mystar.spd<0.6 then
   starcol=7
  end
  pset(mystar.x,mystar.y,starcol) 
 end 
end

function reset_starspd()
 for mystar in all(stars) do
  mystar.spd=rnd(1.5)+0.5
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
 spr(sp.spr,sp.x,sp.y,sp.sprw,sp.sprh)
end

function col(a,b)
 if a.y>b.y+b.colpx then return false end
 if b.y>a.y+a.colpx then return false end
 if a.x>b.x+b.colpx then return false end
 if b.x>a.x+a.colpx then return false end
 return true
end

function phcol(phx1,phy1,phx2,phy2,obj)
 if linecol(phx1,phy1,phx2,phy2,obj.x,obj.y,obj.x,obj.x+obj.colpx) then return true end
 if linecol(phx1,phy1,phx2,phy2,obj.x+obj.colpx,obj.y,obj.x+obj.colpx,obj.y+obj.colpx) then return true end
 if linecol(phx1,phy1,phx2,phy2,obj.x,obj.y,obj.x+obj.colpx,obj.y) then return true end
 if linecol(phx1,phy1,phx2,phy2,obj.x,obj.y+obj.colpx,obj.x+obj.colpx,obj.y+obj.colpx) then return true end
 return false
end


function linecol(x1,y1,x2,y2,x3,y3,x4,y4)
 ua=((x4-x3)*(y1-y3)-(y4-y3)*(x1-x3))/((y4-y3)*(x2-x1)-(x4-x3)*(y2-y1))
 ub=((x2-x1)*(y1-y3)- (y2-y1)*(x1-x3))/((y4-y3)*(x2-x1)-(x4-x3)*(y2-y1))
 if ua>=0 and ua<=1 and ub>=0 and ub<=1 then return true end
 return false
end

function core_breach()
 sfx(6)
 ship.dead=true
 create_part("breach",ship.x,ship.y)
	create_part("bspark",ship.x,ship.y) 
end

function create_part(ptype,px,py,psx,psy)
 local ltype=ptype
 if ltype=="explod" then 
	 local myp={}
	 myp.type=ltype
	 myp.x=px
	 myp.y=py
	 myp.sx=0
	 myp.sy=rnd(0.6,1)
	 myp.age=1
	 myp.maxage=20+rnd(10)
	 add(particles,myp)
 end
 if ltype=="smol" then 
	 local myp={}
	 myp.type=ltype
	 myp.x=px
	 myp.y=py
	 myp.sx=0
	 myp.sy=rnd(0.6,1)
	 myp.age=1
	 myp.maxage=20+rnd(10)
	 add(particles,myp)
 end
 if ltype=="spark" then
  for i=1,10 do
	  local myp={}
		 myp.type=ltype
		 myp.x=px+4
		 myp.y=py+4
		 myp.sx=(rnd()-0.5)*2
		 myp.sy=(rnd()-0.5)*2
		 myp.age=1
		 myp.maxage=15+rnd(15)
		 add(particles,myp)
		end
	end
	 if ltype=="bspark" then
  for i=1,40 do
	  local myp={}
		 myp.type=ltype
		 myp.x=px+4
		 myp.y=py+4
		 myp.sx=(rnd()-0.5)*3
		 myp.sy=(rnd()-0.5)*3
		 myp.age=1
		 myp.maxage=40+rnd(5)
		 add(particles,myp)
		end
	end		
	if ltype=="breach" then 
	 local myp={}
	 myp.type=ltype
	 myp.x=px
	 myp.y=py
	 myp.sx=0
	 myp.sy=rnd(0.6,1)
	 myp.age=1
	 myp.maxage=50
	 add(particles,myp)	
	end
	
	if ltype=="hit" then
	 local myp={}
	 myp.type=ltype
	 myp.x=px+4
		myp.y=phend+6
		myp.sx=rnd(2)-1
		myp.sy=psy
		myp.age=1
		myp.maxage=5+rnd(5)
	 add(particles, myp)
	end
	
end

function draw_part()
 for myp in all(particles) do
  if myp.type=="explod" then
	  local shock=myp.age-9
	  local shock2=shock-6
	  if myp.age<2 then
	   ovalfill(myp.x-10,myp.y+1,myp.x+14,myp.y+3,9)  
	   ovalfill(myp.x+2,myp.y+10,myp.x+3,myp.y-7,9)  
	  elseif myp.age<5 then
	   fillp(0xa5a5.8)
	   ovalfill(myp.x-5,myp.y-2,myp.x+9,myp.y+6,10)
	   fillp()
	  elseif myp.age<7 then
	   fillp(0xbebe.8)
	   ovalfill(myp.x-5,myp.y-3,myp.x+9,myp.y+8,8)    
	   fillp()
	  elseif myp.age<10 then
	   fillp(0xdfbf.8)
	   ovalfill(myp.x-5,myp.y-4,myp.x+9,myp.y+9,8)  
	   fillp()
	  elseif myp.age<13 then
	   fillp(0xdfbf.8)
	   ovalfill(myp.x-5,myp.y-6,myp.x+9,myp.y+11,8)  
	   fillp()
	   circ(myp.x+4,myp.y+4,shock,9)
	  elseif myp.age<21 then
	   shock2+=1 
	   circ(myp.x+4,myp.y+4,shock,9)
	   circ(myp.x+4,myp.y+4,shock2,8)
	  elseif myp.age<26 then
	   shock2+=3 
	   circ(myp.x+4,myp.y+4,shock,9)
	   circ(myp.x+4,myp.y+4,shock2,8)
	  end
	 end
	 
	 if myp.type=="smol" then
	  if myp.age<2 then
	   ovalfill(myp.x-8,myp.y-1,myp.x+12,myp.y+1,9)  
	   ovalfill(myp.x,myp.y+8,myp.x+1,myp.y-5,9)  
	  elseif myp.age<5 then
	   fillp(0xa5a5.8)
	   ovalfill(myp.x-3,myp.y-1,myp.x+7,myp.y+5,10)
	   fillp()
	  elseif myp.age<7 then
	   fillp(0xbebe.8)
	   ovalfill(myp.x-3,myp.y-2,myp.x+7,myp.y+6,8)    
	   fillp()
	  elseif myp.age<10 then
	   fillp(0xdfbf.8)
	   ovalfill(myp.x-3,myp.y-3,myp.x+7,myp.y+7,8)  
	   fillp()
	  elseif myp.age<13 then
	   fillp(0xdfbf.8)
	   ovalfill(myp.x-3,myp.y-4,myp.x+7,myp.y+8,8)  
	   fillp()
	  end
	 end
	 
	  
	 if myp.type=="spark" then 
	  local scol={8,9}
	  pset(myp.x,myp.y,scol[t\2%2+1])
  end
  if myp.type=="bspark" then 
	  local scol={7,13}
	  pset(myp.x,myp.y,scol[t\2%2+1])
  end
	 if myp.type=="breach" then
	  local shock=myp.age-9
	  local shock2=shock-6
	  if myp.age<2 then
	   ovalfill(myp.x-20,myp.y+1,myp.x+24,myp.y+3,7)  
	   ovalfill(myp.x+2,myp.y+20,myp.x+3,myp.y-17,7)  
	  elseif myp.age<5 then
	   fillp(0xa5a5.8)
	   ovalfill(myp.x-5,myp.y-10,myp.x+9,myp.y+14,7)
	   fillp()
	  elseif myp.age<7 then
	   fillp(0xbebe.8)
	   ovalfill(myp.x-5,myp.y-11,myp.x+9,myp.y+15,12)    
	   fillp()
	  elseif myp.age<10 then
	   fillp(0xdfbf.8)
	   ovalfill(myp.x-5,myp.y-12,myp.x+9,myp.y+16,12)  
	   fillp()
	  elseif myp.age<13 then
	   fillp(0xdfbf.8)
	   ovalfill(myp.x-5,myp.y-6,myp.x+9,myp.y+11,2)  
	   fillp()
	   circ(myp.x+4,myp.y+4,shock,7)
	  elseif myp.age<51 then
	   shock2+=1 
	   circ(myp.x+4,myp.y+4,shock,7)
	   circ(myp.x+4,myp.y+4,shock2,12)
	  elseif myp.age<61 then
	   shock2+=3 
	   circ(myp.x+4,myp.y+4,shock,7)
	   circ(myp.x+4,myp.y+4,shock2,12)
	  end
	 end
	 if myp.type=="hit" then
	  local scol={7,10,9,8}
	  fillp(0xa241.8)
	  circfill(myp.x+2,myp.y-6,2,scol[t\2%4+1])
	  fillp() 
	 end
	 
  myp.age+=1
  myp.x+=myp.sx
  myp.y+=myp.sy
  myp.sx=myp.sx*0.95
  myp.sy=myp.sy*0.95
  
  if (myp.age>myp.maxage) del(particles,myp)
 end
end

function draw_ship()
 if ship.cont then
	 if invuln<=0 then
	  draw_spr(ship)
	  if mode=="intro" and introt>685 then
	   pset(ship.x,ship.y+7,12)
	   pset(ship.x+7,ship.y+7,12)
	  end
	  if ship.warp then
	   spr(tailspr[t\3%3+1],ship.x,ship.y+7)
	  end
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
 end
end

function debug()

 if debug_setting.info then
  
  print("mode : "..mode,0,10,15)
  print("t    : "..t,0,16,15)
  print("lock : "..btnlock,0,22,15)
  if mode=="game" then  
   print("wave : "..wave,0,28,15)
   print("wavtm: "..wavtime,0,34,15)
   print("enems: "..#enemies,0,40,15)
   --local dead
   --dead=tostr(ship.dead)
   --print("dead:  "..dead,0,44,15)
  end
 end

end
-->8
--ui

function draw_ui()
 if mode=="game" then
  if debug_setting.hideui==false then
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
  end
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
	 
 elseif mode=="intro" then
  
  if imode<3 then
		 rectfill (0,0,127,6,0)
		 rectfill(0,0,122,6,8)
		 circfill(124,3,3,8)
		 rectfill(5,0,7,6,0)
		 print("red alert",10,1,0)
		 rectfill(0,121,127,127,0)
		 rectfill(0,121,127,127,0)
		 rectfill(0,121,122,127,8)
		 circfill(124,124,3,8)
		 rectfill(5,121,7,127,0)
		else
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
		 local tcol={5,8}
		end 
		if imode<3 then		 
		 rectfill(5,121,7,127,0)
		 rectfill(8,10,114,117,0)
		 rectfill(10,10,110,16,8)
		 rectfill(10,111,110,117,8)
		 circfill(11,13,3,8)
		 circfill(111,13,3,8)
		 circfill(11,114,3,8)
		 circfill(111,114,3,8)
		 rectfill(16,10,19,16,0)
		 rectfill(103,10,106,16,0)
		 rectfill(16,111,19,117,0)
		 rectfill(103,111,106,117,0)	 
		 
		 spr(202,46,19,4,4)
		 print("incoming message from",20,54,9)
		 print("fleet command:",35,60,9)
  
  
   rectfill(42,111,45,117,0)
   rectfill(81,111,84,117,0)
   local tcol={9,8}
	  rectfill(46,111,80,117,tcol[t\15%2+1])
	  print("any key",50,112,0)
  
  end
	 if imode==1 then
		 print("you are ordered to proceed",10,68,8)
		 print("to sector 6547 mark 192",10,74,8)
	 	print("with utmost speed. it is",10,80,8)
	 	print("imperative that your ship",10,86,8)
	 	print("secures the area and",10,92,8)
	 	print("denies any and all hostile",10,98,8)
	  print("vessels.",10,104,8) 
	 elseif imode==2 then 
	  print("maximum use of force is",10,68,8)
		 print("authorised.",10,74,8)
	 	print("",10,80,8)
	 	print("implement the omega",10,86,8)
	 	print("directive immediately. all",10,92,8)
	 	print("other priorities have been",10,98,8)
	  print("recinded.",10,104,8)
	  blink_txt("message ends.",47,104,9,0)
	 else
	 end 
 end
end

function blink_txt(txt,x,y,col1,col2)
 local bcol={col1,col2}
 print(txt,x,y,bcol[t\30%2+1])
end 
-->8
--waves & enemies

function spwn_en(enx,eny,entype)
 local myen={}
 myen.x=enx
 myen.y=eny
 myen.sx=0
 myen.sy=1
 myen.invuln=0
 myen.type=entype
 myen.sprw=1
 myen.sprh=1
 myen.colpx=7
 if entype=="tingan" then
  myen.hp=4
  myen.ani={16,17,16,17}
 elseif entype=="aquilan" then
  myen.hp=4
  myen.ani={18,19,18,19}
 elseif entype=="dicean" then
  myen.hp=4
  myen.ani={20,21,20,21}
 elseif entype=="franconi" then
  myen.hp=4
  myen.ani={22,23,22,23}
 elseif entype=="bots" then
  myen.hp=20
  myen.sprw=2
  myen.sprh=2
  myen.colpx=15
  myen.ani={64,66,64,66}
 end
 
 add(enemies,myen)
end

function chk_wav()
 if ship.dead==false and mode=="game" and #enemies==0 and wavtime==0 then
  wavtime=80
 end
 if wavtime==1 then
  wave+=1
  next_wav()
  wavtime=0
 elseif wavtime>0 then
  wavtime-=1
 end
end

function next_wav()
 if wave==1 then
  spwn_wav(1)
 elseif wave==2 then
  spwn_wav(2)
 elseif wave==3 then
  spwn_wav(3)
 elseif wave==4 then
  spwn_wav(4)
 elseif wave>4 then
  spwn_wav(5)
 end
end

function spwn_z(encount)

 if encount==1 then
  local zone=flr(rnd(4))+1
  if zone==1 then
   local enx=13+rnd(25)
  elseif zone==2 then
   local enx=38+rnd(25)
  elseif zone==3 then
   local enx=63+rnd(25)
  elseif zone==4 then
   local enx=88+rnd(25)
  end
 end
  
  return enx
end


function place_en(wav_type)

 --[[
 defining spawn zones:
 
  1: 13+rnd(25)
  2: 38+rnd(25)
  3: 63+rnd(25)
  4: 88+rnd(25)
 
 formations:

  0: does not apply
  1: normal spawning
  2: middle two enemies have
    y-offset

]]

 if wav_type=="ti-single" then
  
  local enx=spawn_z(1)
  local eny=-8
  spwn_en(enx,eny,"tingan")
  
 end

end


function spwn_wav(wav_diff)
 
 if wav_diff==1 then

  place_en("ti-single")
 
 elseif wav_diff==2 then
  spwn_en("aquilan")
 elseif wav_diff==3 then 
  spwn_en("dicean")
 elseif wav_diff==4 then
  spwn_en("franconi")
 elseif wav_diff==5 then
  spwn_en("bots")
 end
end

function kill_en(myen)
	del(enemies,myen)
	sfx(3)
	create_part("explod",myen.x,myen.y)
	create_part("spark",myen.x,myen.y)
end

function hitexplod(obj)
 sfx(2)
 create_part("smol",obj.x+5,obj.y+12)
end
__gfx__
00000000000660000066000000006600000000000000000000000000c000000cc000000cc000000c0c0000c00c0000c00c0000c00c0000c00c0000c00c0000c0
00000000007667000766700000076670000000000000000000000000cc0000cc1c0000c1cc0000cc0c000cc001000c100c000cc00cc000c001c000100cc000c0
007007000665566006556000000655600080080000080000000080001c0000c111000011cc0000cc01000c10010001100c000cc001c00010011000100cc000c0
0007700006655660065560000006556000099000000998000089900011000011010000101c0000c1010001100000010001000c10011000100010000001c00010
00077000006666000066600000066600000990000089900000099800010000101000000111000011000001000100001001000110001000000100001001100010
00700700885665880866588008856680008008000000800000080000100000010100001001000010010000100000010000000100010000100010000000100000
00000000670550760755076006705570000000000000000000000000010000100000000010000001000001000000000001000010001000000000000001000010
00000000170000710700071001700070000000000000000000000000000000000000000001000010000000000000000000000100000000000000000000100000
00588500005ee50000000000000000000005500000055000000220000002200000536500005b6500600000066000000600000000000000000000000000000000
03b33b3003b33b30300aa003b00aa00b0004400000044000092222900a2222a003b6553006365b30680000866900009600000000000000000000000008080000
5bbbbbb55bbbbbb55066660550666605000440000004400092255229a225522a0656b65006565650688008866890098600000000000000000080000000000900
35055053350550536065560660655606008998000079970022555522225555220065650000656500068668600686686000000000000000000008090000000090
3005500330055003a765567aa765567a0099990000999900250550522505505200565b00005653000666666006666660000000000000000000000a9009000000
3003300330033003a667766aa667766a449aa944449aa94420022002200220020563566005635660005665000056650000000000000000000009a70000009000
b00bb00bb00bb00b0766667007666670044994400449944000299200002992000656b350065b3650005555000055550000000000000000000000900000000000
000bb000000bb00000777700007777000044440000444400002002000020020000b5650000656500000550000005500000000000000000000000000000009000
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
00000535565000000000053556500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00055563556550000005556b55655000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00566556b55535000056655635555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05556566556565300555656655656560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b56555565565b500556555565565350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3565565563533565356556556b565565000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55535566565653565b5555665656b556000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
665b533555566655665553b555566655000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
556556666b6555655565566666655565000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
53356556666b53565b3565566b665b56000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55566b55335656555556655555565655000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05655666665556500565566666555650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05565565353555300556556353555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00555656555665000055565655566500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0005b55656b550000005355656655000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000566655000000000056665500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
ffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffff
f00000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000000000000000000f
f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f
f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f
f000000000000000000000002020202020202020202020202020202020202020202020202020202020202020202020202020202000000000000000000000000f
f000000000000000000000000200020002000200020002000200020002000200020002000200020002000200020002000200020000000000000000000000000f
f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f
f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f
f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f
f000000000000000000000000080008000800080008000800080008000800080008000800080008000800080008000800080008000000000000000000000000f
f000000000000000000000000800080008000800080008000800080008000800080008000800080008000800080008000800080000000000000000000000000f
f000000000000000000000008000800080008000800080008000800080008000800080008000800080008000800080008000800000000000000000000000000f
f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f
f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f
f000000000000000000000000808080808080808080808080808080808080808080808080808080808080808080808080808080800000000000000000000000f
f000000000000000000000008080808080808080808080808080808080808080808080808080808080808080808080808080808000000000000000000000000f
f000000000000000000000000808080808080808080808080808080808080808080808080808080808080808080808080808080800000000000000000000000f
f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f
f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f
f00000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000000000000000000f
f00000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000000000000000000f
f00000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000000000000000000f
f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f
f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f
0f00020000080008000fff00ffffffff00ffffffff0fffffffff00000000ffff0000ff0000000ffffffff0ffffffff00ffffffff00fff00808008000020000f0
0f00000000000080800fff00ff0000fff0ff0000000ff0000fff00000000ffff0000ff0000000ff0000000ff0000fff0000ff00000fff00080000000000000f0
0f00020008000008000fff00ff00000ff0ff0000000ff00000fff000000ff00ff000ff0000000ff0000000ff00000ff0000ff00000fff00808000080020000f0
0f00000000000080800fff00ff0000fff0ffffffff0ff00000fff00000ff0000ff00ff0000000ffffffff0ff0000fff0000ff00000fff00080000000000000f0
0f00020000080008000fff00ffffffff00ff0000000ff00000fff00000ff0000ff00ff0000000ff0000000ffffffff00000ff00000fff00808008000020000f0
0f00000000000080800fff00ff0000fff0ff0000000ff0000fff00000ffffffffff0ff0000000ff0000000ff0000fff0000ff00000fff00080000000000000f0
0f00020008000008000fff00ff00000ff0ffffffff0fffffffff00000ff000000ff0fffffff00ffffffff0ff00000ff0000ff00000fff00808000080020000f0
f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f
f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f
f00000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000000000000000000f
f00000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000000000000000000f
f00000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000000000000000000f
f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f
f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f
f000000000000000000000000808080808080808080808080808080808080808080808080808080808080808080808080808080800000000000000000000000f
f000000000000000000000008080808080808080808080808080808080808080808080808080808080808080808080808080808000000000000000000000000f
f000000000000000000000000808080808080808080808080808080808080808080808080808080808080808080808080808080800000000000000000000000f
f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f
f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f
f000000000000000000000000080008000800080008000800080008000800080008000800080008000800080008000800080008000000000000000000000000f
f000000000000000000000000800080008000800080008000800080008000800080008000800080008000800080008000800080000000000000000000000000f
f000000000000000000000008000800080008000800080008000800080008000800080008000800080008000800080008000800000000000000000000000000f
f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f
f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f
f000000000000000000000000200020002000200020002000200020002000200020002000200020002000200020002000200020000000000000000000000000f
f000000000000000000000002020202020202020202020202020202020202020202020202020202020202020202020202020202000000000000000000000000f
f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f
f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f
f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f
f00000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000000000000000000f
ffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffff
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99999999999999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99999999999999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99999999999999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99999999999999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99999999999999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888000000000008808880888088800000888008800000888080808880000088808880888088000880888008000000000000000000000000000
88888888888888888000000000080008080808008000000080080800000080080808000000080808080080080808000800008000000000000000000000000000
88888888888888888000000000080008880888008000000080080800000080088808800000088008800080080808000880008000000000000000000000000000
88888888888888888000000000080008080800008000000080080800000080080808000000080808080080080808080800000000000000000000000000000000
88888888888888888000000000008808080800008000000080088000000080080808880000088808080888088808880888008000000000000000000000000000
88888888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888000000000099999900088888888888888888888888888888880009999999999999999999999900099999900000000000000000000000000
88888888888888888000000000999999900088000800880808888808080008080880009900090009900900090099900099999990000000000000000000000000
88888888888888888000000009999999900088080808080808888808080888080880009909090999099909090909900099999999000000000000000000000000
88888888888888888000000009999999900088000808080008888800880088000880009900990099000900090909900099999999000000000000000000000000
88888888888888888000000009999999900088080808088808888808080888880880009909090999990909990909900099999999000000000000000000000000
88888888888888888000000000999999900088080808080008888808080008000880009909090009009909990009900099999990000000000000000000000000
88888888888888888000000000099999900088888888888888888888888888888880009999999999999999999999900099999900000000000000000000000000
88888888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888000000000000000000008000880080000008880888088808080000000000000000000000000000000000000000000000000000000000000
88888888888888888000000000000000000080008000008000000080808000808080000000000000000000000000000000000000000000000000000000000000
88888888888888888000000000000000000080008000008000008880808088808880000000000000000000000000000000000000000000000000000000000000
88888888888888888000000000000000000080008000008000008000808080000080000000000000000000000000000000000000000000000000000000000000
88888888888888888000000000000000000008000880080000008880888088800080000000000000000000000000000000000000000000000000000000000000
88888888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888000000000000000000088808880888000008880880088008080088088808880888088800880000000000000000000000000000000000000
88888888888888888000000000000000000080008080808000000800808080808080800008008080080080008000000000000000000000000000000000000000
88888888888888888000000000000000000088008880880000000800808080808080888008008800080088008880000000000000000000000000000000000000
88888888888888888000000000000000000080008080808000000800808080808080008008008080080080000080000000000000000000000000000000000000
88888888888888888000000000000000000080008080888008008880808088800880880008008080888088808800000000000000000000000000000000000000
88888888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888888888888888888000888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888800
08888888888888888888888888888888000888888888888888888888888888888888888888888888888888888888808080008000888880008888800080088880
08888888888888888888888888888888000888888888888888888888888888888888888888888888888888888888808080888080888880808888808088088888
00888888888888888888888888888888000888888888888888888888888888888888888888888888888888888888808080088008888880808888808088088888
00088888888888888888888888888888000888888888888888888888888888888888888888888888888888888888800080888080888880808888808088088888
00008888888888888888888888888888000888888888888888888888888888888888888888888888888888888888880880008080888880008808800080008880
00000088888888888888888888888888000888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888800

__sfx__
0001000001350023500535007320093200e3201132010320173201a3201d320223202232019320223202132021320213201c32021330213301e3401a3400d35012340143400a3300632005310023500035001350
000200000f2201123015230202402b240372403b2503f2503f2503f2603e2603c2603826034260302602b2602726023260212601d2601b2501825016250152501325011240102400e2400d2300b2300a23009220
000100002e6502c65028650226501a650136500e65009640066300663005620046100461002610016000160000000020000000000000000000000000000000000000000000000000000000000000000000000000
000100003965031250086503465028630132200a62005220042200221000000000000000002650000000000000650016500000002650036300165001620016500062001620006100000000610000000061000000
0001000019750097403b7600070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000100001025026240342203d250342003720037200212000420007200202000020020200202000a200042000c200062001d20000200002000020000200002000020000200002000020000200002000020000200
000300000a6500e6501d650276503f6503f6503e6501e650386502e640166402d6401b6402e64014640286403f6403e6401a64015610156303e6203862029620236101a6101f6101b61039610186101761017610
00030000003500135002350023500235002350033500335004350043500435005350053500635008350093500b3500c3500d3500f3501135013350173501c3502035023350293502b2502b2502b2203921007210
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
002400001a5501a5501a5501f550235502155021550215501d5502855026550265502655026550005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
__music__
00 14494344

