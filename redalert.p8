pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--red alert (v0.01)
--by fab.industries

function _init()
 version="0.01"
 
 --debug settings
 --using declare function

 dclr"dbs_info,dbs_hideui,dbs_wave,dbs_cpause|false,false,46,true"

 cls(0)
 t=0
 btnlock=0
 hitlock=0
 shake=0
 cpaused=false
 
 --remove later
 pdeb=false
 
 
 startscreen()
 
end

function _update()
 t+=1
 
 if dbs_cpause then
  if band(btn(),64)!=0 then
   poke(0x5f30,1)
   if cpaused then
    cpaused=false
    --remove later
    pdeb=false
   else
    cpaused=true
   end
  end 
 end
 
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

 scrshake()
 
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
 phend=-128
 tcols={1,2,5}

 --ship attributes
 --using declare function
 dclr"ship_x,ship_y,ship_sx,ship_sy,ship_spr,ship_colw,ship_colh,ship_xf,ship_pht,ship_torp,ship_ttmr,ship_shield,ship_cont,ship_dead,ship_warp,ship_flash|62,100,0,0,1,8,8,64,0,true,0,100,true,false,false,0"

 invuln=0
 stars={}
 torps={}
 eshots={}
 wave={}
 particles={}
 score=0
 scoredisp=0
 bot_timer=0
 bot_speech=0
 bot_snd=false
 
 if dbs_wave then
  wavecount=dbs_wave
 else
  wavecount=0
 end
 
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

 if (cpaused) return

 ship_sx=0
 ship_sy=0
 ship_spr=1
 tailspr={7,8,9}
 
 chk_wav()
  
 if ship_cont==false then
  if timeout>0 then 
   timeout-=1
	 else
	  music(0)
	  mode="over"
	  btnlock=t+60
   return
  end
 end
 
 if ship_ttmr>0 then
  ship_ttmr-=1
 else 
  ship_torp=true
 end
 
 if t<btnlock then
 
 else
	 if ship_dead==false and mode=="game" then
		 if btn(⬅️) then
		  ship_sx=-2
		  ship_spr=2
		  tailspr={10,11,12}
		 end
		 if btn(➡️) then
		  ship_sx=2
		  ship_spr=3
		  tailspr={13,14,15}
		 end
		 if btn(⬆️) then
		  ship_sy=-2
		 end
		 if btn(⬇️) then
		  ship_sy=2
		 end
		 
		 --[[ weapon damage:
		 phaser:   1hp
		 torpedo:  4hp
		 qtorp:   10hp
		 ]]
		 
		 
		 --fires phaser
		 if btnp(❎) then
	   fire_ph("ship")
		 end
		
		 --fires torpedo
		 if btnp(🅾️) then 
		  if ship_torp then
     local newtorp=dclr"sx,sy,flash,spr,colw,colh|0,-3,4,4,4,4|out"
     newtorp.x=ship_x+2
     newtorp.y=ship_y-3
     newtorp.ani={4,5,6}
			  add(torps,newtorp)
			  ship_torp=false
			  ship_ttmr=5*30
			  ship_flash=3
			  sfx(1)
			 else
			  sfx(10)
			 end
		 end
	 end

 end

 --move enemies 
 for myen in all(wave) do
  
  if myen.y>110 then
  --move enemy off screen 
   if myen.sy<1 then
    myen.sy=1
   end
   move(myen)
  else
  --move enemy normally
   move_en(myen)
  end
  
  if myen.y>128 or myen.x<-8 or myen.x>128 then
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
	 if phcol(ship_x+2,ship_y,ship_xf+2,ship_y-128,myen) and ship_pht>0 then
	  phend=myen.y+myen.colh
	    
	  if t>hitlock then 
	   if myen.type=="bs" then
	    create_part("hit",myen.x,phend,myen.sx,myen.sy)
	    sfx(2)
	   elseif myen.type=="bc" then
	   	create_part("hit",myen.x+(flr(rnd(16))+8),phend-flr(rnd(8)+4),rnd(8)-4,rnd(2)-1)
	    sfx(2)
	   end
	   hitlock=t+10
	  end
	    
	  if myen.invuln<=0 then  
	   score+=1
	 	 myen.hp-=1
	 	 if myen.boss==false then
	 	  myen.invuln=30
	 	  sfx(4)
		  end
		  if myen.hp<=0 then
     kill_en(myen)
		  end
   else
	   myen.invuln-=1
	  end
	 end
 end

--collision ship x enemy phaser
 if invuln<=0 and ship_dead==false then
  for myen in all(wave) do
   if myen.type=="bc" and myen.phposx>0 and myen.phposy>0  then
    local hitbox={}
    hitbox.x=ship_x+2
    hitbox.y=ship_y+2
    hitbox.colw=2
    hitbox.colh=2
    if phcol(myen.phorx,myen.phory,myen.phposx,myen.phposy,hitbox) and myen.pht>0 then
     sfx(-1)
     --ship_cont=false
     --core_breach()
     cpaused=true
     sfx(2)
     --shake=8
     myen.pht=0
    end
   end
  end
 end

 --collision ship x enemies
 if invuln<=0 and ship_dead==false then
	 for myen in all(wave) do

   local shipl={}
   shipl.x=ship_x
   shipl.y=ship_y
   shipl.colw=ship_colw
   shipl.colh=ship_colh

	  if col(myen,shipl) then
	   --check if shield is gone
    --if ship_shield<=0 then
     ship_cont=false
     core_breach()
	   --end
	   --ship_shield-=30
	   ship_shield=0
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
 
 --collision ship x enemy shots
 if invuln<=0 and ship_dead==false then
	 for eshot in all(eshots) do
	  
	  --for purposes of collision
	  --detection, tweak ship pos
	  --makes ship collision box
	  --a bit smaller than it
	  --actually is
	  
	  local shipc={}
	  shipc.x=ship_x+1
	  shipc.y=ship_y+1
	  shipc.colw=ship_colw-1
	  shipc.colh=ship_colh-1
	  
	  if col(eshot,shipc) then
	   del(eshots,eshot)
    sfx(5)
    shake=8
	   --check if shield is gone
    --if ship_shield<=0 then
     ship_cont=false
     core_breach()
	   --end
	   --ship_shield-=30
	   ship_shield=0
	   sfx(2)
	   --invuln=60
	  end
	 end
 end
 
 --move ship
 ship_x+=ship_sx
 ship_y+=ship_sy
 
 --prevent ship from moving
 --off the edge of the screen
 if ship_x>120 then
 	ship_x=120
 end
 if ship_x<0 then
  ship_x=0
 end
 if ship_y<7 then
  ship_y=7
 end
 if ship_y>110 then
  ship_y=110
 end
 
 --move torps
 for torp in all(torps) do
  move(torp)
  --delete torp as it moves
  --off screen
  if torp.y<-8 then
   del(torps,torp)
  end 
 end

 --move enemy shot
 for eshot in all(eshots) do
  move(eshot)
 
  if eshot.y>128 or eshot.x<-8 or eshot.x>128 or eshot.y<-8 then
   del (eshots,eshot)
  end
 end

 chng_mission()
 
 anim_stars()
 
end

function update_start()

 if not btn(x) and not btn(🅾️) then 
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

 if not btn(x) and not btn(🅾️) then 
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
  ship_warp=true
 end
 
 if introt>=90 then
  mode="game"
 end
end

-->8
--draw

function draw_game()
 
 --if (cpaused) return

 if cpaused then
   if pdeb==false then
    local sx2=ship_x+7
    local sy2=ship_y+7
    rectfill(0,10,100,34,0)
    print("ship tl:"..ship_x.."/"..ship_y,0,10,8)
    print("ship br:"..sx2.."/"..sy2,0,16,8)
    for myen in all(wave) do
     print("ph ori:"..myen.phorx.."/"..myen.phory,0,22,8)
     print("ph end:"..myen.phposx.."/"..myen.phposy,0,28,8) 
    end
    pdeb=true
   end
  return
 end

 cls(0)
 
 if mode=="intro" and introt<45 then
  starfield(true)
 else
  starfield()
 end
 
 draw_ship()
 
 --drawing enemies
 for myen in all(wave) do
  
  if myen.type=="bs" then
   myen.spr=myen.ani[t\50%4+1]
  elseif myen.type=="bc" then
   myen.spr=myen.ani[t\50%4+1] 
  else
   if myen.glow>0 then
    myen.glow-=1
    myen.spr=myen.glowspr
   else
    myen.spr=myen.ani[t\30%4+1]
   end
  end
  
  --enemy invuln fx

  if myen.invuln>0 then
   invulnfx(myen)
  else
   draw_spr(myen)     
  end

 end
 
 --animate torpedo
 anim(torps)
 
 --torpedo flash
  if ship_flash>0 then
   circfill(ship_x+4,ship_y-2,ship_flash,8)
   circfill(ship_x+3,ship_y-2,ship_flash,9)
   ship_flash-=1
  end

 --enemy muzzle flash
 --has to be named
 --type-muzzle
 --examples: tic-muzzle,
 --ti-muzzle, bc-muzzle

 for myen in all(wave) do
  flash(myen, myen.type.."-muzzle")
 end
 
 --ship phaser
 draw_ph("ship")
 
 --particles
 draw_part()
 
 --draw enemy shots
 anim(eshots)
 
 draw_ph("bots")
 
 --reset phaser target point
 if phend!=-128 and t%6==0 then
  phend=-128
 end
 
 draw_ui()
 
 if bot_timer>0 then
  bot_timer-=1
 else
	 if bot_speech>0 then
	  assimilation()
	  bot_speech-=1
	 end
 end

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
--ui

function pcars_topbar(col)
	rectfill (0,0,127,6,0)
	rectfill(0,0,122,6,col)
	circfill(124,3,3,col)
	rectfill(5,0,7,6,0)
	print("red alert",10,1,0)
end

function pcars_btmbar(col,mode)
	rectfill(0,121,127,127,0)
	if mode==1 then
	 rectfill(0,121,127,127,0)
	 rectfill(0,121,122,127,col)
	 rectfill(5,121,7,127,0)
 elseif mode==2 then
		rectfill(0,121,4,127,col)
		rectfill(8,121,42,127,5)
		rectfill(46,121,93,127,5)
		rectfill(97,121,115,127,5)
		rectfill(119,121,122,127,col)
		local tcol={5,8}
 elseif mode==3 then
		rectfill(0,121,4,127,col)
		local scol={10,10}
		if ship_shield>60 then
		 scol={10,10}
		elseif ship_shield>20 then
		 scol={9,9} 
		elseif ship_shield>0 then
		 scol={8,8}
		elseif ship_shield<=0 then 
		 scol={8,5}
		end
		rectfill(8,121,42,127,scol[t\15%2+1])
		rectfill(97,121,115,127,2)
		rectfill(119,121,122,127,col)
		if ship_shield>0 then
		 print("shd "..ship_shield.."%",10,122,0)
		else
		 print("shd ".."off",10,122,0) 
		end
		if ship_torp then
		 rectfill(46,121,93,127,10)
		 print("trp ready",52,122,0)
		else
		 local tcol={8,5}
		 rectfill(46,121,93,127,tcol[t\15%2+1])
		 print("trp loading",48,122,0)
		end
		 print("up 0",99,122,0)
 end
 circfill(124,124,3,col)
end

function pcars_modal(col)
 rectfill(5,121,7,127,0)
	rectfill(8,10,114,117,0)
	rectfill(10,10,110,16,col)
	rectfill(10,111,110,117,col)	 
	circfill(11,13,3,col)
	circfill(111,13,3,col)
	circfill(11,114,3,col)
	circfill(111,114,3,col)	 
	rectfill(16,10,19,16,0)
	rectfill(103,10,106,16,0)
	rectfill(16,111,19,117,0)
	rectfill(103,111,106,117,0)
	rectfill(42,111,45,117,0)
 rectfill(81,111,84,117,0)
 local tcol={9,8}
	rectfill(46,111,80,117,tcol[t\15%2+1])
	print("any key",50,112,0)
end

function pcars_btn(y,col1,col2,txt) 
	local tcol={5,col1}
	rectfill(35,y,65,y+6,tcol[t\15%2+1])
	rectfill(29,y,31,y+6,col2)
	circfill(27,y+3,3,col2)
	print("any key",37,y+1,0)
	rectfill(69,y,91,y+6,col2)
	rectfill(95,y,100,y+6,col2) 
	circfill(99,y+3,3,col2)
	print(txt,71,y+1,0)
end

function draw_ui()
 if mode=="game" then
  if dbs_hideui==false then
   pcars_topbar(8)
   prnt_score()
		 pcars_btmbar(8,3)
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
	 elseif imp==3 then
	  b1_col=8 
	  b2_col=15
	 elseif imp==4 then
	  b2_col=8
	  b3_col=15
	 elseif imp==5 then 
	  b1_col=2
	  b3_col=8 
	  b4_col=15
	 elseif imp==6 then 
	  b2_col=2
	  b4_col=8
	 elseif imp==7 then 
	  b1_col=5
	  b3_col=2
	 elseif imp==8 then 
	  b2_col=5
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
	 
	 pcars_btn(79,8,9,"respd")
	 
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

  pcars_topbar(8)
  prnt_score()
	 print("performance evaluation",20,83,9)
	 print("----------------------",20,87,9)
	 if score>0 then
	  print("your score  : "..scoredisp.."0",20,92,8)
	 else
	 	print("your score  : "..scoredisp,20,92,8)
	 end
	 print("died to wave: "..wavecount,20,99,8 )
	 print("rank        :",20,106,8)
	 
	 printrank(score)
	 pcars_btmbar(8,1)

	 print("your ship lost",36,30,2)
	 print("core containment",32,36,8)
	 print("and was destroyed.",29,42,2)
	 
	 pcars_btn(62,8,9,"aknwl")
	 
 elseif mode=="intro" then
  
  if imode<3 then
		 pcars_topbar(8)
		 pcars_btmbar(8,1)
		else
		 pcars_topbar(8)		
   prnt_score()
   pcars_btmbar(8,2)
		end 
		if imode<3 then		 
		 pcars_modal(8)
		 spr(202,46,19,4,4)
		 print("incoming message from",20,54,9)
		 print("fleet command:",35,60,9)
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

function cprint(txt,x,y,c)
 print(txt,x-#txt*2,y,c)
end

function assimilation()
 if bot_snd then
  sfx(12)
  bot_snd=false
 end
 cprint("lower your shields and",64,52,11)
 cprint("prepare to be assimilated.",64,58,11)
 cprint("resistance is futile.",64,64,11)
end

function prnt_score()
 local scx
 local scl
 scl=tostr(scoredisp)
 if (#scl==1) scx=121
 if (#scl==2) scx=117
 if (#scl==3) scx=113
 if (#scl==4) scx=109
 if (#scl==5) scx=105
 if score>0 then
  print(scoredisp.."0",scx-4,1,0)
 else
  print(scoredisp,scx,1,0)
 end
end

function printrank(scr)

 --if score<100 then
  --crewman
  print("🅾️",76,106,9)
 --elseif score<500 then
  --ensign
 -- print("🅾️",76,106,9)
 -- rectfill(77,107,80,109,9)
 --end
  
  --[[
  ranks:
   🅾️         crewman
   ❎         ensign
   🅾️❎       lt jg
   ❎❎       lt
   🅾️❎❎     lt cmdr
   ❎❎❎     commander
   ❎❎❎❎   captain
   ★         commodore
   ★★       rear adm
   ★★★     vice adm
   ★★★★   admiral
   ★★★★★ fleet adm
  ]]
end

-->8
--waves & enemies

function chk_wav()
 if ship_dead==false and mode=="game" and #wave==0 and wavtime==0 then
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

 spwn_wav(wavecount)
end

function kill_en(myen)
	del(wave,myen)
	
	if myen.boss then
	 create_part("bigexplod",myen.x+rnd(32),myen.y+rnd(32))
	 create_part("spark",myen.x+rnd(32),myen.y+rnd(32))
	 create_part("bigexplod",myen.x+rnd(32),myen.y+rnd(32))
	 create_part("spark",myen.x+rnd(32),myen.y+rnd(32))
	 create_part("bigexplod",myen.x+rnd(32),myen.y+rnd(32))
	 create_part("spark",myen.x+rnd(32),myen.y+rnd(32))
  sfx(6)
	else
	 sfx(3)
	 create_part("explod",myen.x,myen.y)
	 create_part("spark",myen.x,myen.y)
  score+=20
 end
 
 if myen.missiom=="attack" then
  score+=10
  pick_attacker()
 end
end

function hitexplod(obj)
 if obj.boss then
  create_part("smol",obj.x+(flr(rnd(16))+8),obj.y+(flr(rnd(20)+8)))
 else
  create_part("smol",obj.x+5,obj.y+12)
 end
 sfx(2)
end

function add_en(enx,eny,tary,entype,enwait)
 
--[[
enemy hp:

ti:3  tic:6    bd:20
aq:4  aqc:8    bs:30
di:6  dic:12   bc:40
fr:4  th:4
mo:10 
re:6		rec:20 
]] 
 

 if entype=="ti" then
  local myen=dclr"sx,sy,invuln,sprw,sprh,colw,colh,warpsnd,glow,firefreq,firetmr,flash,torpx,torpy,hp,glowspr|0,1,0,1,1,8,8,false,0,90,0,0,0,0,4,17|out"
  myen.x=enx
  myen.y=eny
  myen.tarx=enx+rnd(14)-7
  myen.tary=tary+flr(rnd(20)) 
  myen.wait=enwait
  myen.type=entype
  myen.ani={16,17,16,17}
  myen.mission="approach"
 elseif entype=="tic" then
  local myen=dclr"sx,sy,invuln,sprw,sprh,colw,colh,warpsnd,glow,firefrq,firetmr,flash,torpx,torpy,hp,glowspr|0,1,0,2,2,16,16,false,0,90,0,0,0,0,16,34|out"
  myen.x=enx
  myen.y=eny
  myen.tarx=enx+rnd(14)-7
  myen.tary=tary+flr(rnd(20)) 
  myen.wait=enwait
  myen.type=entype
  myen.ani={32,34,32,34}
  myen.mission="approach"
 elseif entype=="aq" then
  local myen=dclr"sx,sy,invuln,sprw,sprh,colw,colh,warpsnd,glow,firefrq,firetmr,flash,torpx,torpy,hp,glowspr|0,1,0,1,1,8,8,false,0,90,0,0,0,0,1,19|out"
  myen.x=enx
  myen.y=eny
  myen.tarx=enx+rnd(14)-7
  myen.tary=tary+flr(rnd(20)) 
  myen.wait=enwait
  myen.type=entype
  myen.ani={18,19,18,19}
  myen.mission="approach"
 elseif entype=="di" then
  local myen="sx,sy,invuln,sprw,sprh,colw,colh,warpsnd,glow,firefrq,firetmr,flash,torpx,torpy,hp,glowspr|0,1,0,1,1,8,8,false,0,90,0,0,0,0,4,19|out"
  myen.x=enx
  myen.y=eny
  myen.tarx=enx+rnd(14)-7
  myen.tary=tary+flr(rnd(20)) 
  myen.wait=enwait
  myen.type=entype
  myen.ani={20,21,20,21}
  myen.mission="approach"
 elseif entype=="fr" then
  local myen=dclr"sx,sy,invuln,sprw,sprh,colw,colh,warpsnd,glow,firefrq,firetmr,flash,torpx,torpy,hp,glowspr|0,1,0,1,1,8,8,false,0,90,0,0,0,0,4,23|out"
  myen.x=enx
  myen.y=eny
  myen.tarx=enx+rnd(14)-7
  myen.tary=tary+flr(rnd(20)) 
  myen.wait=enwait
  myen.type=entype
  myen.ani={22,23,22,23}
  myen.mission="approach"
 elseif entype=="bs" then
  local myen=dclr"sx,sy,invuln,sprw,sprh,colw,colh,warpsnd,glow,firefrq,firetmr,flash,torpx,torpy,hp,glowsp|0,1,0,2,2,16,16,false,0,15,0,0,0,0,20,23|out"
  myen.x=enx-7
  myen.y=eny
  myen.tarx=enx+rnd(14)-7
  myen.tary=tary+flr(rnd(20)) 
  myen.wait=enwait
  myen.type=entype
  myen.ani={64,66,64,66}
  myen.mission="approach"
 elseif entype=="re" then
  local myen=dclr"sx,sy,invuln,sprw,sprh,colw,colh,warpsnd,glow,firefrq,firetmr,flash,torpx,torpy,hp,glowsp|0,1,0,1,1,8,8,false,0,90,0,0,0,0,4,31|out"
  myen.x=enx
  myen.y=eny
  myen.tarx=enx+rnd(14)-7
  myen.tary=tary+flr(rnd(20)) 
  myen.wait=enwait
  myen.type=entype
  myen.ani={30,31,30,31}
  myen.mission="approach"
 elseif entype=="bc" then
  local myen=dclr"sx,sy,invuln,sprw,sprh,colw,colh,warpsnd,glow,firefrq,firefrq2,firetmr,firetmr2,flash,torpx,torpy,hp,glowsp,tarx,tary,boss,pht,phtarx,phtary,phposx,phposy,phorx,phory|0,1,0,4,4,32,32,false,0,150,360,0,0,0,0,0,50,17,48,14,true,0,0,0,0,0,0,0|out"
  myen.x=enx
  myen.y=eny
  myen.wait=enwait
  myen.type=entype
  myen.ani={68,72,68,72}
  myen.mission="approach"
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

function create_wav(thiswav)
 
 local encount=0
 local enlst={}
 for i=1,4 do
  if thiswav[i]!=0 then
   encount+=1
   local thisen=thiswav[i]
   add(enlst,thisen)
  end
 end

 local ens=place_ens(encount) 
 
 if enlst[1]=="bc" then
  add_en(48,-8,10,enlst[1],0)
 else
  add_en(ens[1],-8,10,enlst[1],0)
  if (encount>1) add_en(ens[2],-8,10,enlst[2],0)
  if (encount>2) add_en(ens[3],-8,10,enlst[3],0)
  if (encount>3) add_en(ens[4],-8,10,enlst[4],0)
 end

end

function spwn_wav(wav_num)

--[[
wave design:

 1     ti        16     mo
 2    ti ti      17  mo    mo
 3 ti ti ti ti   18 mo mo mo mo
 4 ti  tic  ti   19     re
 5    aq aq      20  re    re
 6  aq aqc aq    21 re  re  re
 7 aq aqc aqc aq 22 re re re re
 8  aqc aqc aqc  23 re  rec  re
 9     di        24 re recrec re
10 di di di di   25     bd
11  di dic di     
12 di dic dic di 38     bs
13     fr     
14 fr        fr  47     bc
                    
26-37 repeat waves 3,4,7,8,10,
      12,14,17,18,22,24,25

39-46 repeat waves 8,11,13,15,
      18,20,23,25
]]

 if wav_num==1 then
  create_wav({"ti",0,0,0})
 elseif wav_num==2 then
  create_wav({"ti","ti",0,0})
 elseif wav_num==3 then 
  create_wav({"ti","ti","ti","ti"})
 elseif wav_num==4 then
  create_wav({"ti","tic","ti",0})
 elseif wav_num==5 then
  create_wav({"aq","aq",0,0})
 elseif wav_num==6 then
  create_wav({"aq","aqc","aq",0})
 elseif wav_num==7 then
  create_wav({"aq","aqc","aqc","aq"})
 elseif wav_num==47 then
  create_wav({"bc",0,0,0})
  bot_timer=90
  bot_speech=180
  btnlock=t+280
  bot_snd=true
 end
 
--higher attack frequency
--on later waves

 if wav_num<8 then
  attackfreq=60
 else
  attackfreq=30
 end
 
end


function move_en(myen)
 
 if myen.y>1 and myen.warpsnd==false then
  if myen.boss then
   sfx(11)
  else
   sfx(8) 
  end
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
  
  local dx=(myen.tarx-myen.x)/10
  local dy=(myen.tary-myen.y)/10
  
  if myen.boss then
   dy=min(dy,1)
  end
  myen.x+=dx
  myen.y+=dy

  --enemy approach w/0 easing
  --based on speed
  --myen.y+=myen.sy
  
  if abs(myen.y-myen.tary)<0.4 then
   myen.y=myen.tary
   
   if myen.boss then
    myen.mission="boss"
    myen.firetmr=t+270
    myen.firetmr2=t+800
   else 
    myen.mission="station"
    myen.firetmr=t+60
   end
  end
  
 elseif myen.mission=="station" then
  --station keeping

  if myen.type=="ti" then
   --basic enemy
  
   fire(myen,0,2)
 
  elseif myen.type=="tic" then
   aimedfire(myen,2)
  end

 elseif myen.mission=="boss" then
  
  fire_ph("bots",myen)
  aimedfire_b(myen,2)

 elseif myen.mission=="attack" then
  --attack maneuvers

  if myen.type=="ti" then
   --basic enemy
 
   fire(myen,0,2)
   
   myen.sy=0.1
   myen.sx=sin(t/300)
   if myen.x<32 then
    myen.sx+=1-(myen.x/32)
   end
   if myen.x>88 then
    myen.sx-=(myen.x-88)/32
   end
   move(myen)
   
   
  elseif myen.type=="aq" then
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
   
  elseif myen.type=="re" then
   --kamikaze enemy
   if myen.sx==0 then
    --flying down
    myen.sy=1
    if ship_y<=myen.y then
     myen.sy=0
     if ship_x<myen.x then
      myen.sx=-1
     else
      myen.sx=1
     end
    end
   end
   move(myen)
 
  elseif myen.type=="tic" then
  
   aimedfire(myen,2)
   
  elseif myen.type=="fr" then
   
   myen.sy=0.3  
   firespread(myen,10,2,rnd())
   move(myen)

  end
 end
end

function chng_mission()

 if mode!="game" or #wave==0 then
  return
 end
 
 if t%attackfreq==0 then
  pick_attacker()
 end
end

function pick_attacker()
  --local myen=rnd(wave)
  
  --oldest enemy attacks first
  local myen=wave[1]
  if myen.mission=="station" then
   myen.mission="attack"
   myen.wait=10
   myen.glow=10
  end
end

-->8
--shots

function mkshot(myen,ang,spd,stype)
 local eshot={}
 eshot.x=myen.x
 eshot.y=myen.y
 eshot.sx=sin(ang)*spd
 eshot.sy=cos(ang)*spd
 eshot.sprw=1
 eshot.sprh=1
 if stype=="spread" then
  eshot.colw=4
  eshot.colh=4
  eshot.spr=112
  eshot.ani={112,113,114}
 elseif stype=="aimed" then
  if myen.type=="tic" then
   eshot.x=myen.x+12
   eshot.y=myen.y+16
  end
  eshot.colw=6
  eshot.colh=6
  eshot.spr=96
  eshot.ani={96,97,98}
  if myen.boss then
   eshot.spr=76
   eshot.ani={76,77,78}
   local shotx=myen.x+(flr(rnd(14)+8))
   local shoty=myen.y+(flr(rnd(16)+12))
   eshot.x=shotx
   eshot.y=shoty
   myen.torpx=shotx
   myen.torpy=shoty
  end
 else
  eshot.colw=8
  eshot.colh=6
  eshot.spr=99
  eshot.ani={99}
 end
 add(eshots,eshot)
 return eshot
end

function fire_rnd(myen)
 local frnd=rnd(60)
 local freq=myen.firefrq 
 myen.firetmr=t+frnd+freq 
end

function fire_rnd2(myen)
 local frnd=rnd(80)
 local freq=myen.firefrq2 
 myen.firetmr2=t+frnd+freq
end

function fire(myen,ang,spd)

 if t>myen.firetmr and ship_dead==false then
  sfx(9)
  myen.flash=3
  
  fire_rnd(myen)
  mkshot(myen,ang,spd,"normal")
 else
  return
 end
end

function firespread(myen,num,spd,base)
 if t>myen.firetmr and ship_dead==false then 
  sfx(9)
  myen.flash=3
  
  fire_rnd()

  for i=1,num do
   if base==nil then
    base=0
   end
   ang=1/num*i+base
   mkshot(myen,ang,spd,"spread")
	 end
	 
 else
  return
 end
end

function aimedfire(myen,spd)

 if t>myen.firetmr and ship_dead==false then
  sfx(9)
  myen.flash=5
  fire_rnd(myen)
  local eshot=mkshot(myen,0,spd,"aimed")
  local ang=atan2((ship_y+5)-eshot.y,(ship_x+3)-eshot.x)
  eshot.sx=sin(ang)*spd
  eshot.sy=cos(ang)*spd
 else
  return
 end
 
end

function aimedfire_b(myen,spd)
  
  if t>myen.firetmr2 and ship_dead==false then
  sfx(9)
  myen.flash=5
  fire_rnd2(myen)
  local eshot=mkshot(myen,0,spd,"aimed")
  local ang=atan2((ship_y+5)-eshot.y,(ship_x+3)-eshot.x)
  eshot.sx=sin(ang)*spd
  eshot.sy=cos(ang)*spd
 else
  return
 end
 
end

function flash(obj,ftype)
 if ftype=="ti-muzzle" then
  if obj.flash>0 then
   circfill(obj.x+2,obj.y+7,obj.flash,3)
   circfill(obj.x+3,obj.y+7,obj.flash,11)
   circfill(obj.x+6,obj.y+7,obj.flash,3)
   circfill(obj.x+7,obj.y+7,obj.flash,11)
   obj.flash-=1
  end
 elseif ftype=="tic-muzzle" then
  if obj.flash>0 then
   circfill(obj.x+7,obj.y+16,obj.flash,8)
   circfill(obj.x+8,obj.y+16,obj.flash,9)
   obj.flash-=1
  end  
 elseif ftype=="bc-muzzle" then
  if obj.flash>0 then
   circfill(obj.torpx,obj.torpy,obj.flash,3)
   circfill(obj.torpx+1,obj.torpy,obj.flash,11)
   obj.flash-=1
  end  
 else
  return
 end
end

function draw_ph(phtype)
 if phtype=="ship" then
  if ship_pht>0 then
   line(ship_x+2,ship_y,ship_xf+2,phend,9)
   ship_pht-=1
  end
 elseif phtype=="bots" then 
  for myen in all(wave) do
	  if myen.type=="bc" then
	   if myen.pht>0 then
     if flr(myen.phposx)==myen.phtarx and flr(myen.phposy)==myen.phtary then
      myen.pht=0
      sfx(-1)
      return
     else
      if flr(myen.phposx)>myen.phtarx then
       myen.phposx-=1
      end
      if flr(myen.phposx)<myen.phtarx then
       myen.phposx+=1 
      end
      if flr(myen.phposy)>myen.phtary then
       myen.phposy-=1
      end
      if flr(myen.phposy)<myen.phtary then
       myen.phposy+=1
      end
     end
     if sin(t/3)<0.5 then
      line(myen.phorx,myen.phory,myen.phposx,myen.phposy,12)
      circfill(myen.phorx,myen.phory,1,12)
     else
      line(myen.phorx,myen.phory,myen.phposx,myen.phposy,7)
      circfill(myen.phorx,myen.phory,1,7)
     end
     myen.pht-=1
	   end
	  end 
  end
 end
end

function fire_ph(phtype,myen)
 if phtype=="ship" then
	 sfx(0)
	 ship_pht=15
	 ship_xf=ship_x
	elseif phtype=="bots" then
	 if t>myen.firetmr and ship_dead==false then
	  sfx(13)
	  myen.pht=90
	  myen.phtarx=ship_x+3
	  myen.phtary=ship_y+3
   
   print (coinflip(),20,20,8)

   if coinflip() then
    myen.phorx=myen.x+5
    myen.phory=myen.y+10
   else
    myen.phorx=myen.x+25
    myen.phory=myen.y+18
   end
   local posa=30+rnd(10)
   local posb=20+rnd(10)
   if ship_x<=64 then
    myen.phposx=flr(ship_x+posa)
    myen.phposy=flr(ship_y+posb)
   else
	   myen.phposx=flr(ship_x-posa)
	   myen.phposy=flr(ship_y-posb)
	  end
   fire_rnd(myen)
	 end
	end
end
-->8
--tools

function starfield(imp)
 --creates background stars 
 for i=1,#stars do
  local mystar=stars[i]
  --colour stars based on
  --their speeds
  local starcol=7
  if imp then
   if mystar.spd<0.2 then
    starcol=1
   elseif mystar.spd<0.3 then
    starcol=2
   elseif mystar.spd<0.4 then
    starcol=12
   elseif mystar.spd<0.5 then
    starcol=6
   end
  else
   if mystar.spd<0.6 then
    starcol=1
   elseif mystar.spd<0.8 then
    starcol=2
   elseif mystar.spd<1 then
    starcol=12
   elseif mystar.spd<1.3 then
    starcol=6
   end
   --create warp trails
   if mystar.spd>=1.9 then
    line(mystar.x,mystar.y,mystar.x,mystar.y-mystar.trl,mystar.trlcol)
   end
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

function invulnfx(myen)
 local p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12=3,8,5,8,11,8,8,2,14,2,11,9
 local xoff1,xoff2=2,9
 local yoff1,yoff2=4,11
 local col=8
 
 if myen.type=="bs" then
  if sin(t/7)<0.5 then
   draw_spr(myen)
   fillp(0xfdbf.8)
   circfill(myen.x+8,myen.y+8,7,3)    
   fillp()    
  else
   draw_spr(myen)
  end      
 else
  if sin(t/7)<0.5 then
   fillp(0xd7b6)
   if myen.type=="aq" then
    col=11
    p1,p2,p3,p4,p5,p6,p7,p8,p9,p10=5,3,6,3,7,3,10,3,11,3
   elseif myen.type=="di" then
    col=9
   end
   ovalfill(myen.x-xoff1,myen.y-yoff1,myen.x+xoff2,myen.y+yoff2,col)
   fillp()
   if myen.type=="di" then
    pal(4,9)
    pal(p3,9)
    pal(9,9)
    pal(9,10)
    pal(10,9)
    pal(p11,p12)
   elseif myen.type=="fr" then
    pal(2,9)
    pal(5,8)
   else
    pal(p1,p2)
    pal(p3,p4)
    pal(p5,p6)
    pal(p7,p8)
    pal(p9,p10)
   end
   draw_spr(myen)
   pal()
   if myen.type=="fr" then
    fillp(0xd7b6)
    oval(myen.x-2,myen.y-4,myen.x+9,myen.y+11,2)    
    fillp()
   else
    oval(myen.x-xoff1,myen.y-yoff1,myen.x+xoff2,myen.y+yoff2,col)
   end
  else
   if myen.type=="ti" then
    p2,p4,p6=7,6,7
   elseif myen.type=="aq" then
    p1,p2,p4,p5,p6=6,7,6,10,7
   elseif myen.type=="di" then
    p1,p2,p3,p4,p5,p6,p7,p8,p9,p10=9,7,10,7,4,6,5,6,8,6
   end
   pal(p1,p2)
   pal(p3,p4)
   pal(p5,p6)
   if myen.type=="di" then
    pal(p7,p8)
    pal(p9,p10)
   end
   draw_spr(myen)
   pal()
   oval(myen.x-xoff1,myen.y-yoff1,myen.x+xoff2,myen.y+yoff2,col)
  end
 end
end

function draw_spr(sp)
 spr(sp.spr,sp.x,sp.y,sp.sprw,sp.sprh)
end

function anim(obj)
 for myobj in all(obj) do
  myobj.spr=myobj.ani[t\1%#myobj.ani+1]
  myobj.sprw=1
  myobj.sprh=1
  draw_spr(myobj)
 end
end

function col(a,b)
 if a.y>b.y+b.colh then return false end
 if b.y>a.y+a.colh then return false end
 if a.x>b.x+b.colw then return false end
 if b.x>a.x+a.colw then return false end
 return true
end

function phcol(phx1,phy1,phx2,phy2,obj)
 if linecol(phx1,phy1,phx2,phy2,obj.x,obj.y,obj.x,obj.x+obj.colw) then return true end
 if linecol(phx1,phy1,phx2,phy2,obj.x+obj.colw,obj.y,obj.x+obj.colw,obj.y+obj.colh) then return true end
 if linecol(phx1,phy1,phx2,phy2,obj.x,obj.y,obj.x+obj.colw,obj.y) then return true end
 if linecol(phx1,phy1,phx2,phy2,obj.x,obj.y+obj.colh,obj.x+obj.colw,obj.y+obj.colh) then return true end
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
 ship_dead=true
 shake=32
 create_part("breach",ship_x,ship_y)
 create_part("bspark",ship_x,ship_y) 
end

function create_part(ptype,px,py,psx,psy)
 local ltype=ptype
 local myp={}
 myp.type=ltype
 myp.age=1

 local xoff,yoff,sxoff,syoff,ageoff=4,4,0,rnd(0.6,1),20+rnd(10)

 if ltype=="hit" then
  yoff,sxoff,syoff,ageoff=6,rnd(2)-1,psy,5+rnd(5)
 elseif ltype=="breach" then 
  ageoff=50
 elseif ltype=="spark" then
  sxoff,syoff,ageoff=(rnd()-0.5)*2,(rnd()-0.5)*2,15+rnd(15)
 elseif ltype=="bspark" then
  sxoff,syoff,ageoff=(rnd()-0.5)*3,(rnd()-0.5)*3,40+rnd(5)
 elseif ltype=="bigexplod" then
  ageoff=40+rnd(20)
 end

 myp.x=px
 myp.y=py
 myp.sx=sxoff
 myp.sy=syoff
 myp.maxage=ageoff
 
 if ltype=="spark" or ltype=="bspark" then
  for i=1,myp.maxage do
   myp.x=px+xoff
   myp.y=py+yoff
   myp.sx=sxoff
   myp.sy=syoff
   myp.maxage=ageoff
  end
 end

 add(particles,myp)
end

function draw_part()
 for myp in all(particles) do

  if myp.type=="explod" or myp.type=="bigexplod" or myp.type=="smol" or myp.type=="breach" then
   local shock=myp.age-9
   local shock2=shock-6

   local xoff1,xoff2,xoff3,xoff4,yoff1,yoff2,yoff3,yoff4,col1,col2,fill=5,9,4,0,0,0,0,0,9,8,"0xdfbf.8"

   if myp.age<2 then
    if myp.type=="smol" then
     xoff1,xoff2,xoff3,xoff4,yoff1,yoff2,yoff3,yoff4=8,12,0,1,-1,1,8,5
    elseif myp.type=="breach" then
     xoff1,xoff2,xoff3,xoff4,yoff1,yoff2,yoff3,yoff4,col1=20,24,2,3,1,3,20,17,7
    else
     xoff1,xoff2,xoff3,xoff4,yoff1,yoff2,yoff3,yoff4=10,14,2,3,1,3,10,7
    end
   elseif myp.age<5 then
    if myp.type=="smol" then
     xoff1,xoff2,yoff1,yoff2,col1,fill=3,7,1,5,10,"0xa5a5.8"
    elseif myp.type=="breach" then
     yoff1,yoff2,col1,fill=10,14,7,"0xa5a5.8"
    else
     yoff1,yoff2,col1,fill=2,6,10,"0xa5a5.8"
    end
   elseif myp.age<7 then
    if myp.type=="smol" then 
     xoff1,xoff2,yoff1,yoff2,col1,fill=3,7,2,6,8,"0xbebe.8"
    elseif myp.type=="breach" then
     yoff1,yoff2,col1,fill=11,15,12,"0xbebe.8"
    else
     yoff1,yoff2,col1,fill=3,8,8,"0xbebe.8"
    end
   elseif myp.age<10 then
    if myp.type=="smol" then
     xoff1,xoff2,yoff1,yoff2,col1=3,7,3,7,8
    elseif myp.type=="breach" then
     yoff1,yoff2,col1,fill=12,16,12,"0xdfbf.8"
    else
     yoff1,yoff2,col1,fill=4,9,8,"0xdfbf.8"
    end
   elseif myp.age<13 then
    if myp.type=="smol" then
     xoff1,xoff2,yoff1,yoff2,col1=3,7,4,8
    elseif myp.type=="breach" then
     yoff1,yoff2,yoff3,col1,col2=6,11,4,2,7
    else
     yoff1,yoff2,yoff3,col1,col2=6,11,4,8,9
    end
   elseif myp.age<21 and myp.type=="explod" then
    shock2+=1
    xoff1,yoff1=4,4
   elseif myp.age<26 and myp.type=="explod" then
    shock2+=3
    xoff1,yoff1=4,4
   elseif myp.age<51 then
    shock2+=1
    xoff1,yoff1,col1,col2=4,4,7,12
   elseif myp.age<61 then
    shock2+=3
    xoff1,yoff1,col1,col2=4,4,7,12
   end

   if myp.age<2 then
    ovalfill(myp.x-xoff1,myp.y+yoff1,myp.x+xoff2,myp.y+yoff2,col1)  
    ovalfill(myp.x+xoff3,myp.y+yoff3,myp.x+xoff4,myp.y-yoff4,col1)
   elseif myp.age<5 and myp.type=="breach" then
    fillp(fill)
    ovalfill(myp.x-xoff1,myp.y-yoff1,myp.x+xoff2,myp.y+yoff2,col1)
    fillp()
   elseif myp.type=="smol" or myp.type=="breach" then
    if myp.age<7 then
     fillp(fill)
     ovalfill(myp.x-xoff1,myp.y-yoff1,myp.x+xoff2,myp.y+yoff2,col1)
     fillp()
    end
   elseif myp.age<10 then
    fillp(fill)
    ovalfill(myp.x-xoff1,myp.y-yoff1,myp.x+xoff2,myp.y+yoff2,col1)  
    fillp()
   elseif myp.age<13 then
    fillp(fill)
    ovalfill(myp.x-xoff1,myp.y-yoff1,myp.x+xoff2,myp.y+yoff2,col1)  
    fillp()
    if myp.type=="explod" or myp.type=="breach" then
     circ(myp.x+xoff3,myp.y+yoff3,shock,col2)
    end
   elseif myp.age<61 then
    circ(myp.x+xoff1,myp.y+yoff1,shock,col1)
    circ(myp.x+xoff1,myp.y+yoff1,shock2,col2)
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

 if ship_cont then
  if invuln<=0 then
   spr(ship_spr,ship_x,ship_y,1,1)
   if mode=="intro" and introt>685 then
    pset(ship_x,ship_y+7,12)
    pset(ship_x+7,ship_y+7,12)
   end
   if ship_warp then
    spr(tailspr[t\3%3+1],ship_x,ship_y+7)
   end
  else


   --invuln state
   
   local col=7
   if sin(t/7)<0.5 then
    col=12
    fillp(0xd7b6)
    ovalfill(ship_x-3,ship_y-6,ship_x+10,ship_y+16,12)
    fillp()
    pal(5,12)
    pal(6,12)
    pal(7,12)
    pal(8,2)
   else
    pal(5,6)
    pal(6,7)
    pal(8,7)
   end
   draw_spr(ship)
   pal()
   spr(tailspr[t\3%3+1],ship_x,ship_y+7)
   oval(ship_x-3,ship_y-6,ship_x+10,ship_y+16,col)
  end
 end
end

function move(obj)
 obj.x+=obj.sx
 obj.y+=obj.sy
end

function scrshake()

 local shakex,shakey=rnd(shake)-(shake/2),rnd(shake)-(shake/2)
 
 camera(shakex, shakey)

 if shake>10 then
  shake*=0.9
 else
  shake-=1
  if shake<1 then
   shake=0
  end
 end
end

function coinflip()
 if flr(rnd(2))==1 then
  return true
 end
end

--two functions to declare
--global variables
--and tables
function dclr(d)
 local k,v,n = unpack(split(d,"|"))
 k,v = split(k),split(v)
 local t=n and {} or _env
 for i=1,#k do
  t[k[i]]=pars(v[i])
 end
 if (n=="out") return t
 if (n) _env[n]=t
end

function pars(v)
 if (v=="{}") return {}
 return v!="false" and v
end
function debug()

 if dbs_info then
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
   --dead=tostr(ship_dead)
   --print("dead:  "..dead,0,44,15)
  end
 end

end
__gfx__
00000000000660000066000000006600800800000800000000800000c000000cc000000cc000000c0c0000c00c0000c00c0000c00c0000c00c0000c00c0000c0
00000000007667000766700000076670099000000998000089900000cc0000cc1c0000c1cc0000cc0c000cc001000c100c000cc00cc000c001c000100cc000c0
007007000665566006556000000655600990000089900000099800001c0000c111000011cc0000cc01000c10010001100c000cc001c00010011000100cc000c0
0007700006655660065560000006556080080000008000000800000011000011010000101c0000c1010001100000010001000c10011000100010000001c00010
00077000006666000066600000066600000000000000000000000000010000101000000111000011000001000100001001000110001000000100001001100010
00700700885665880866588008856680000000000000000000000000100000010100001001000010010000100000010000000100010000100010000000100000
00000000670550760755076006705570000000000000000000000000010000100000000010000001000001000000000001000010001000000000000001000010
00000000170000710700071001700070000000000000000000000000000000000000000001000010000000000000000000000100000000000000000000100000
00588500005ee50000000000000000000005500000055000000220000002200000536500005b650060000006600000060005500000055000000dd000000dd000
03b33b3003b33b30300aa003b00aa00b0004400000044000092222900a2222a003b6553006365b3068000086690000966006600660066006c055550ce055550e
54bbbb4554bbbb455066660550666605000440000004400092255229a225522a0656b6500656565068800886689009866056650660566506c05dd50ce05dd50e
350550533505505360655606606556060089980000799700225555222255552200656500006565000686686006866860656666566566665615dddd5115dddd51
4005500440055004a765567aa765567a0099990000999900250550522505505200565b000056530006666660066666606566665665666656c511115ce511115e
4003300440033004a667766aa667766a449aa944449aa94420022002200220020563566005635660005665000056650060d66d0660d66d0610dddd0110dddd01
b00bb00bb00bb00b0766667007666670044994400449944000299200002992000656b350065b3650005555000055550010dddd01c0dddd0c00d11d0000d11d00
000bb000000bb00000777700007777000044440000444400002002000020020000b56500006565000005500000055000000dd000000dd0000001100000011000
400000000000000440000000000000040000000bb00000000000000bb000000000000050050000000000005005000000000000c00c000000000000e00e000000
635500055000553663550005500055360000005bb50000000000005bb500000000000040040000000000004004000000000000c00c000000000000e00e000000
63548805508845366354ee0550ee45360000053bb35000000000053bb35000000000004994000000000000499400000001000510015000100100051001500010
605465655656450660546565565645060000b335533b00000000b335533b0000000000099000000000000009900000001100d5d55d5d00111100d5d55d5d0011
6054656556564506605465655656450600003333333300000000333333330000000000099000000000000009900000001155d5dddd5d55111155d5dddd5d5511
400b66666666b004400b66666666b0040005333333335000000533333333500000000009900000000000000990000000c1dd156dd651dd1ce1dd156dd651dd1e
00006355553600000000635555360000a05333333333350a705333333333350700000009900000000000000990000000c105d65dd56d501ce105d65dd56d501e
0000563553650000000056355365000055335bb33bb5335555335bb33bb53355000008899880000000000779977000000100d51dd15d00100100d51dd15d0010
00000566665000000000056666500000333b50033005b333333b50033005b333000005999950000000000599995000000000dd1661dd00000000dd1661dd0000
0000000440000000000000044000000035b0000330000b5335b0000330000b530000059aa95000000000059aa95000000000055dd55000000000055dd5500000
00000003300000000000000330000000300000033000000330000003300000030a559449944955a00a559449944955a0000000d11d000000000000d11d000000
00000003300000000000000330000000a00000033000000aa00000033000000a00555554455554000055555445555400000000d55d000000000000d55d000000
000000533500000000000053350000000000003333000000000000333300000000044499994440000004449999444000000001d55d100000000001d55d100000
00000546645000000000054664500000000000333300000000000033330000000000499aa99400000000499aa9940000000001d00d100000000001d00d100000
00005666666500000000566666650000000000b55b000000000000b55b0000000000009aa90000000000009aa900000000000150051000000000015005100000
000000588500000000000058850000000000000bb00000000000000bb000000000000009900000000000000990000000000000d00d000000000000d00d000000
00000535565000000000053556500000000000000000001111100000000000000000000000000011111000000000000000030000030000000030000000000000
00055563556550000005556b55655000000000000000155665551000000000000000000000001556655510000000000003003000003003000003000000000000
00566556b555350000566556355555000000000000155663535555100000000000000000001556655b5535100000000030bb000000bb300003bb030000000000
05556566556565300555656655656560000000001556655555566655100000000000000015566555555666551000000000bb030003bb000030bb300000000000
0b56555565565b5005565555655653500000000156665565535653555100000000000001566655655b5655555100000003003000300300000030000000000000
3565565563533565356556556b56556500000156335565556665555665510000000001563b556555666555566551000000300000000030000003000000000000
55535566565653565b5555665656b55600015565555335665665536b56651000000155655553b56656655b635665100000000000000000000000000000000000
665b533555566655665553b5555666550015636556655535b535655555365510001565655665555535b5655555b6551000000000000000000000000000000000
556556666b65556555655666666555650156655565566566536565556556665101566555655665665b6565556556665100000000000000000000000000000000
53356556666b53565b3565566b665b56016555655b53565355553665565535610165556553555655555556655655556100000000000000000000000000000000
55566b553356565555566555555656550136555566535663635536665555556101b65555665b566b6355b6665555556100000000000000000000000000000000
0565566666555650056556666655565001655655566555b3536556566556663101655655566555355b655656655666b100000000000000000000000000000000
05565565353555300556556353555550015555655565655665565565556565510155556555656556655655655565655100000000000000000000000000000000
00555656555665000055565655566500016535556555665556566555655655510165b55565556655565665556556555100000000000000000000000000000000
0005b55656b55000000535565665500001555555636556663565556655555b61015555556b655666b56555665555536100000000000000000000000000000000
00000566655000000000056665500000016536553566655665555635535553610165565535666556655556b55555556100000000000000000000000000000000
9000090000900000000900003300003301b55656635636555556565555b53331013556566b5636555556565555353b5100000000000000000000000000000000
0288200000280000008200003300003301555636655555665636566555653561015556b665555566565656655565b56100000000000000000000000000000000
089980000899290092998000bb0000bb01653656555655b556565655563653610165b656555655b55656565556b65b6100000000000000000000000000000000
08998000929980000899290077000077016553535655556655565b565656565101655b5b5655556655565b565656565100000000000000000000000000000000
02882000008200000028000077000077016356b6566b555656555556565656b10165563656635556565555565656563100000000000000000000000000000000
900009000009000000900000bb0000bb016556565536655656b55b56565656610165565655b6655656b55b565656566100000000000000000000000000000000
0000000000000000000000000000000001565536566565555556665536355561015655365665655555566655b6b5556100000000000000000000000000000000
0000000000000000000000000000000000155336536653565656656535533510001553b655665b5656566565355b551000000000000000000000000000000000
cddc00000cd0000000c00000000000000000155655636556555555655b66510000001556556b6556555555655366510000000000000000000000000000000000
d77d0000d77c0000c770000000000000000000155656635656556555665100000000001556566556565565556651000000000000000000000000000000000000
d77d0000c77d0000077c00000000000000000001556555555535556655100000000000015565555555b555665510000000000000000000000000000000000000
cddc00000dc000000c00000000000000000000000156656655356655100000000000000001566566555566551000000000000000000000000000000000000000
00000000000000000000000000000000000000000015b5555b565510000000000000000000153555535655100000000000000000000000000000000000000000
00000000000000000000000000000000000000000000155656651000000000000000000000001556566510000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000001555510000000000000000000000000015555100000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000111000000000000000000000000000001110000000000000000000000000000000000000000000000
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
46030000003500135002350023500235002350033500335004350043500435005350053500635008350093500b3500c3500d3500f3501135013350173501c3502035023350293502b2502b2502b2203921007210
460200003c2513c2513c2513c2513a2513825136251322512d251262411c24116241112410c241092310623103231032310222101221012210121101201002010020100201012010120101201012010020100201
160100000a3530b3530c3530e3431134315343193531f353263532d3532f3632f3632f3333532333333333333333322333303333533335333303431a323113131233314323003030030320303063031830301303
000300002d2502c2502b25039250392501720019200192002c2502b2502225019250222501925017200002002b250292502025018250202501925000200002000020000200002000020000200002000020000200
440a00000705007050070500705007040060400604006040060400604006040060400604006040060400603006020060100000000000020000200002000020000200002000020000200002000020000200000000
5e1700000a2500a2500a2500a2500a2500a2500a2500a2500a2500a2500a2500a2500a2500a2500a2500a2500a2500a2500a2500a2500a2500a2500a2500a2500a2500a2500a2500a2500a2500a2500a2500a250
2e020020181501515012150101500e1500d1500b15009150081500715007150061500515004150041500415004150041500415004150041500415004150041500415005150051500515005150051500415004150
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
002400001a5501a5501a5501f550235502155021550215501d5502855026550265502655026550005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
__music__
00 14494344

