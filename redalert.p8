pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--red alert (v0.01)
--by fab.industries

--[[

todo:

 ❎ enemy movement
 ❎ real attack patterns
 🅾️ better score/score screen
 🅾️ enemy shooting
 ❎ more enemy attack patterns
 🅾️ fix enemy movement overlap
 🅾️ fix enemy invuln fx
 🅾️ hit effects for new enemies   
 🅾️ player shield mechanics
 🅾️ weapon upgrades
 🅾️ debug setting: replace
    pause menu with screenshot
    mode for cart img
 🅾️ port game to 60 fps
 🅾️ music

]]

function _init()
 version="0.01"
 
 debug_setting={}
 debug_setting.info=false
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
 ship.x=62
 ship.y=100
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
 wave={}
 particles={}
 score=0
 scoredisp=0
 wavecount=0
 wavtime=0
 wavspwned=false
 cleared=true
 attackfrq=60
 
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
 for myen in all(wave) do
  
  move_en(myen)
  
  if myen.y>128 then

   del(wave,myen)
   cleared=false
  end
  
  if myen.x<-8 or myen.x>128 then

   del(wave,myen)
   cleared=false
  end
  
 end
 
 --collision torpedo x enemies
 for myen in all(wave) do
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
 for myen in all(wave) do
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
	 for myen in all(wave) do
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
 
 chng_mission()
 
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
 for myen in all(wave) do
  
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

function move(obj)
 obj.x+=obj.sx
 obj.y+=obj.sy
end

function debug()

 if debug_setting.info then
  local clearedstr=tostr(cleared)
  
  print("mode : "..mode,0,10,15)
  print("t    : "..t,0,16,15)
  print("lock : "..btnlock,0,22,15)
  if mode=="game" then  
   print("wave : "..wavecount,0,28,15)
   print("clear: "..clearedstr,0,34,15)
   --print("en x : "..myendebug,0,34,15)
   --print("endir: "..myendir,0,40,15)
   --print("wavtm: "..wavtime,0,34,15)
   --print("enems: "..#wave,0,40,15)
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

function chk_wav()
 if ship.dead==false and mode=="game" and #wave==0 and wavtime==0 then
  wavtime=80
 end
 if wavtime==1 then
  if cleared then
   wavecount+=1
  end
  next_wav()
  wavtime=0
 elseif wavtime>0 then
  wavtime-=1
 end
end

function next_wav()
 cleared=true
 if wavecount==1 then
  spwn_wav(1)
 elseif wavecount==2 then
  spwn_wav(2)
 elseif wavecount==3 then
  spwn_wav(2)
 elseif wavecount==4 then
  spwn_wav(3)
 elseif wavecount==5 then
  spwn_wav(4) 
 elseif wavecount==6 then 
  spwn_wav(5)
 elseif wavecount>6 then
  spwn_wav(6)
 end
end

function kill_en(myen)
	del(wave,myen)
	sfx(3)
	create_part("explod",myen.x,myen.y)
	create_part("spark",myen.x,myen.y)
end

function hitexplod(obj)
 sfx(2)
 create_part("smol",obj.x+5,obj.y+12)
end

function add_en(enx,eny,tary,entype,enwait)
 local myen={}
 myen.x=enx
 myen.y=eny
 myen.tarx=enx+rnd(14)-7
 myen.tary=tary+flr(rnd(20)) 
 myen.sx=0
 myen.sy=1
 myen.wait=enwait
 myen.invuln=0
 myen.type=entype
 myen.sprw=1
 myen.sprh=1
 myen.colpx=7
 myen.mission="approach"
 myen.warpsnd=false
 if entype=="tingan" then
  myen.hp=4
  myen.ani={16,17,16,17}
 elseif entype=="ti-cruiser" then
  myen.hp=16
  myen.sprw=2
  myen.sprh=2
  myen.colpx=15
  --myen.x-=7
  myen.ani={32,34,32,34} 
 elseif entype=="aquilan" then
  myen.hp=1
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
  myen.x-=7
  myen.ani={64,66,64,66}
 elseif entype=="regency" then
  myen.hp=4
  myen.ani={30,31,30,31}
 end
 add(wave,myen)
end

function place_ens(encount)
 local xords={}
 --[[
 defining spawn zones:
  1: 11+rnd(25)
  2: 37+rnd(25)
  3: 64+rnd(25)
  4: 90+rnd(25)
  ]]
 --one enemy
 if encount==1 then
  local zone=flr(rnd(4))+1
  if zone==1 then
   xord=11+rnd(25)
  elseif zone==2 then
   xord=37+rnd(25)
  elseif zone==3 then
   xord=64+rnd(25)
  elseif zone==4 then
   xord=90+rnd(25)
  end
  add(xords,xord)
 --two enemies
 elseif encount==2 then
  local zone1=flr(rnd(4))+1
  local zone2=flr(rnd(4))+1
  ::zone_check::
  if zone1==zone2 then
   zone2=flr(rnd(4))+1
   goto zone_check
  end
  if zone1==1 then
   xord1=11+rnd(25)
  elseif zone1==2 then
   xord1=37+rnd(25)
  elseif zone1==3 then
   xord1=64+rnd(25)
  elseif zone1==4 then
   xord1=90+rnd(25)
  end
  if zone2==1 then
   xord2=11+rnd(25)
  elseif zone2==2 then
   xord2=37+rnd(25)
  elseif zone2==3 then
   xord2=64+rnd(25)
  elseif zone2==4 then
   xord2=90+rnd(25)
  end
  add(xords,xord1)
  add(xords,xord2) 
 --three enemies
 elseif encount==3 then
  local nozone=flr(rnd(4))+1
  if nozone==1 then
   xord1=37+rnd(25)
   xord2=64+rnd(25)
   xord3=90+rnd(25)
  elseif nozone==2 then
   xord1=11+rnd(25)
   xord2=64+rnd(25)
   xord3=90+rnd(25)
  elseif nozone==3 then
   xord1=11+rnd(25)
   xord2=37+rnd(25)
   xord3=90+rnd(25)
  elseif nozone==4 then
   xord1=11+rnd(25)
   xord2=37+rnd(25)
   xord3=64+rnd(25) 
  end
  add(xords,xord1)
  add(xords,xord2)
  add(xords,xord3)
 --four enemies
 elseif encount==4 then 
  xord1=11+rnd(25)
  xord2=37+rnd(25)
  xord3=64+rnd(25)
  xord4=90+rnd(25)
  add(xords,xord1)
  add(xords,xord2)
  add(xords,xord3)
  add(xords,xord4)
 end 
 return xords
end

function create_wav(wav_type)
 if wav_type=="ti-single" then
  local ens=place_ens(1)
  add_en(ens[1],-8,10,"tingan",0)
 elseif wav_type=="ti-dual" then
  local ens=place_ens(2)
  add_en(ens[1],-8,20,"tingan",0)
  add_en(ens[2],-8,10,"tingan",30)
 elseif wav_type=="ti-triple" then
  local ens=place_ens(3)
  add_en(ens[1],-8,30,"tingan",0)
  add_en(ens[2],-8,20,"tingan",0)
  add_en(ens[3],-8,10,"tingan",30)
 elseif wav_type=="ti-squadron" then
  add_en(27,-8,38,"tingan",0)
  add_en(91,-8,28,"tingan",0)
  add_en(55,-16,10,"ti-cruiser",60)
 elseif wav_type=="aq-dual" then
  local ens=place_ens(2)
  add_en(ens[1],-8,18,"aquilan",0)
  add_en(ens[2],-8,8,"aquilan",30)
 elseif wav_type=="rg-single" then
  local ens=place_ens(1)
  add_en(ens[1],-8,10,"regency",0)
 end
end

function spwn_wav(wav_diff)
 if wav_diff==1 then
  create_wav("ti-single")
 elseif wav_diff==2 then
  create_wav("ti-dual")
 elseif wav_diff==3 then 
  create_wav("aq-dual")
 elseif wav_diff==4 then
  create_wav("ti-triple")
 elseif wav_diff==5 then
  create_wav("ti-squadron")
 elseif wav_diff==6 then
  create_wav("rg-single") 
 end
 
 if wav_diff<7 then
  attackfreq=60
 else
  attackfreq=30
 end
 
end
-->8
--enemy ai

function move_en(myen)
 
 if myen.y>1 and myen.warpsnd==false then
  sfx(8) 
  myen.warpsnd=true
 end
 
 if myen.wait>0 then
  myen.wait-=1
  return
 end

 if myen.mission=="approach" then
  --coming into range
  
  --basic easing function
  --x+=(targetx-x)/n
  myen.y+=(myen.tary-myen.y)/10
  myen.x+=(myen.tarx-myen.x)/10
  
  --enemy approach w/0 easing
  --based on speed
  --myen.y+=myen.sy
  
  if abs(myen.y-myen.tary)<0.4 then
   myen.y=myen.tary
   myen.mission="station"
  end
  
  
 elseif myen.mission=="station" then
  --station keeping

 elseif myen.mission=="attack" then
  --attack maneuvers

  if myen.type=="tingan" then
   --basic enemy
  
   myen.sy=0.1
   myen.sx=sin(t/300)
   if myen.x<32 then
    myen.sx+=1-(myen.x/32)
   end
   if myen.x>88 then
    myen.sx-=(myen.x-88)/32
   end
   move(myen)
   
  elseif myen.type=="aquilan" then
   --faster, more aggressive
   --but less hp
   
   myen.sy=2
   myen.sx=sin(t/80)+sin(t/80)
   if myen.x<38 then
    myen.sx+=1-(myen.x/38)
   end
   if myen.x>82 then
    myen.sx-=(myen.x-82)/38
   end
   move(myen) 
   
  elseif myen.type=="regency" then
   --kamikaze enemy
   if myen.sx==0 then
    --flying down
    myen.sy=1
    if ship.y<=myen.y then
     myen.sy=0
     if ship.x<myen.x then
      myen.sx=-1
     else
      myen.sx=1
     end
    end
   end
   move(myen)
 
  elseif myen.type=="ti-cruiser" then
 
  end

 end
end

function chng_mission()

 if mode!="game" or #wave==0 then
  return
 end
 
 if t%attackfreq==0 then
  --local myen=rnd(wave)
  
  --oldest enemy attacks first
  local myen=wave[1]
  if myen.mission=="station" then
   myen.mission="attack"
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
00000000170000710700071001700070000000000000000000000000000000000000000001000010000000000000000000000100000000000000000000100000
00588500005ee50000000000000000000005500000055000000220000002200000536500005b650060000006600000060005500000055000000dd000000dd000
03b33b3003b33b30300aa003b00aa00b0004400000044000092222900a2222a003b6553006365b3068000086690000966006600660066006c055550ce055550e
5bbbbbb55bbbbbb55066660550666605000440000004400092255229a225522a0656b6500656565068800886689009866056650660566506c05dd50ce05dd50e
350550533505505360655606606556060089980000799700225555222255552200656500006565000686686006866860656666566566665615dddd5115dddd51
3005500330055003a765567aa765567a0099990000999900250550522505505200565b000056530006666660066666606566665665666656c511115ce511115e
3003300330033003a667766aa667766a449aa944449aa94420022002200220020563566005635660005665000056650060d66d0660d66d0610dddd0110dddd01
b00bb00bb00bb00b0766667007666670044994400449944000299200002992000656b350065b3650005555000055550010dddd01c0dddd0c00d11d0000d11d00
000bb000000bb00000777700007777000044440000444400002002000020020000b56500006565000005500000055000000dd000000dd0000001100000011000
300000000000000330000000000000030000000bb00000000000000bb000000000000050050000000000005005000000000000c00c000000000000e00e000000
635500055000553663550005500055360000005bb50000000000005bb500000000000040040000000000004004000000000000c00c000000000000e00e000000
63538805508835366353ee0550ee35360000053bb35000000000053bb35000000000004994000000000000499400000001000510015000100100051001500010
605365655656350660536565565635060000b335533b00000000b335533b0000000000099000000000000009900000001100d5d55d5d00111100d5d55d5d0011
6053656556563506605365655656350600003333333300000000333333330000000000099000000000000009900000001155d5dddd5d55111155d5dddd5d5511
300b66666666b003300b66666666b0030005333333335000000533333333500000000009900000000000000990000000c1dd156dd651dd1ce1dd156dd651dd1e
00006355553600000000635555360000a05333333333350a705333333333350700000009900000000000000990000000c105d65dd56d501ce105d65dd56d501e
0000563553650000000056355365000055335bb33bb5335555335bb33bb53355000008899880000000000779977000000100d51dd15d00100100d51dd15d0010
00000566665000000000056666500000333b50033005b333333b50033005b333000005999950000000000599995000000000dd1661dd00000000dd1661dd0000
0000000330000000000000033000000035b0000330000b5335b0000330000b530000059aa95000000000059aa95000000000055dd55000000000055dd5500000
00000003300000000000000330000000300000033000000330000003300000030a559449944955a00a559449944955a0000000d11d000000000000d11d000000
00000003300000000000000330000000a00000033000000aa00000033000000a00555554455554000055555445555400000000d55d000000000000d55d000000
000000533500000000000053350000000000003333000000000000333300000000044499994440000004449999444000000001d55d100000000001d55d100000
00000536635000000000053663500000000000333300000000000033330000000000499aa99400000000499aa9940000000001d00d100000000001d00d100000
00005666666500000000566666650000000000b55b000000000000b55b0000000000009aa90000000000009aa900000000000150051000000000015005100000
000000588500000000000058850000000000000bb00000000000000bb000000000000009900000000000000990000000000000d00d000000000000d00d000000
00000535565000000000053556500000000000000000005555500000000000000000000000000000000000000000000000000000000000000000000000000000
00055563556550000005556b55655000000000000000555665555000000000000900009000090000000090000000000000000000000000000000000000000000
00566556b55535000056655635555500000000000055566353555550000000000080080000080000000080000000000000000000000000000000000000000000
05556566556565300555656655656560000000005556655555566655500000000008800000088890098880003000000300000000000000000000000000000000
0b56555565565b500556555565565350000000055666556553565355550000000008800009888000000888900000000000000000000000000000000000000000
3565565563533565356556556b565565000005563355655566655556655500000080080000008000000800003000000300000000000000000000000000000000
55535566565653565b5555665656b55600055565555335665665536b56655000090000900000900000090000b000000b00000000000000000000000000000000
665b533555566655665553b5555666550055636556655535b535655555365550000000000000000000000000b000000b00000000000000000000000000000000
556556666b6555655565566666655565055665556556656653656555655666550000000000000000000000000000000000000000000000000000000000000000
53356556666b53565b3565566b665b56056555655b53565355553665565535650000000000000000000000000000000000000000000000000000000000000000
55566b55335656555556655555565655053655556653566363553666555555650000000000000000000000000000000000000000000000000000000000000000
0565566666555650056556666655565005655655566555b353655656655666350000000000000000000000000000000000000000000000000000000000000000
05565565353555300556556353555550055555655565655665565565556565550000000000000000000000000000000000000000000000000000000000000000
00555656555665000055565655566500056535556555665556566555655655550000000000000000000000000000000000000000000000000000000000000000
0005b55656b55000000535565665500005555555636556663565556655555b650000000000000000000000000000000000000000000000000000000000000000
00000566655000000000056665500000056536553566655665555635535553650000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000005b55656635636555556565555b533350000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000055556366555556656365665556535650000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000005653656555655b556565655563653650000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000056553535655556655565b56565656550000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000056356b6566b555656555556565656b50000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000056556565536655656b55b56565656650000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000055655365665655555566655363555650000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000005553365366535656566565355335500000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000555655636556555555655b6655000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000555656635656556555665500000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000055565555555355566555000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000556656655356655500000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000055b5555b565550000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000555656655000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000005555550000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000555000000000000000000000000000000000000000000000000000000000000000000000000000000
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
47030000003500135002350023500235002350033500335004350043500435005350053500635008350093500b3500c3500d3500f3501135013350173501c3502035023350293502b2502b2502b2203921007210
470200003c2513c2513c2513c2513a2513825136251322512d251262411c24116241112410c241092310623103231032310222101221012210121101201002010020100201012010120101201012010020100201
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

