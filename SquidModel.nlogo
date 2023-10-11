breed [squids squid]
breed [predators predator]
breed [lights light]

globals [
 time
 background-color
 moon-color
 squid-xpos
 squid-ypos
 squid-rotpos
 predator-xpos
 predator-ypos
 squid-patch
 predator-patch
 visible?
 expected
]

lights-own [ intensity ]
squids-own [
  bioluminescence
  alive?
]
patches-own [ light-level ]

to setup-squid
  create-squids num-squids
  ask squids [
   set alive? true
   set bioluminescence random-float 1
   set squid-xpos random 64
   set squid-ypos random 32
   setxy squid-xpos squid-ypos
   set size 4
   set heading random 360
  ]
end

to setup-predator
  create-predators num-predators
  ask predators [
   setxy random 64 random 32
   set size 6
   set color gray
  ]
end

to update-predator
  ask predators[
   set predator-patch patch-here
   set predator-xpos xcor
   set predator-ypos ycor
   set heading random 360
   forward 1
  ]
end

to update-squid
  ask squids [
    set expected abs (moonluminance - bioluminescence)
    set squid-patch patch-here
    generate-sfield
      set squid-rotpos random 360
      set squid-xpos xcor
      set squid-ypos ycor
    ifelse alive? = true [
      set heading squid-rotpos
      forward 1
    ] [ set color red ]
    if squid-patch = predator-patch [
      if bioluminescence >= moonluminance [
          set alive? false
      ]
    ]
  ]
end

to make-lights [ number ]
  create-lights number [
    set color 9
    jump 10 + random-float (max-pxcor - 30)
    set intensity random luminance + 20
    set size sqrt intensity
  ]
end

to generate-pfield
  set light-level 0
  ask lights [set-field myself]
  set pcolor scale-color blue ( sqrt light-level ) moonluminance  ( sqrt ( 20 * max [intensity] of lights ) )
end

to generate-sfield
  set light-level 0
  ask lights [set-field myself]
  set color scale-color blue ( sqrt light-level ) bioluminescence ( sqrt ( 20 * max [intensity] of lights ) )
end

to set-field [p]
  let rsquared (distance p) ^ 2
  let amount intensity * scale-factor
  ifelse rsquared = 0
  [ set amount amount * 1000 ]
  [ set amount amount / rsquared ]
  ask p [ set light-level light-level + amount ]
end

to setup
  clear-all
  set-default-shape lights "Circle"
  set-default-shape squids "Squid"
  set-default-shape predators "Shark"
  setup-squid
  setup-predator
  make-lights 1
  ask patches [generate-pfield]
  ask squids [generate-sfield]
  reset-ticks
end

to go
  update-squid
  update-predator
  tick
end
