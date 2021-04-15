#define N 4

byte flag[N]
byte count = 0

active [N] proctype A(){
  byte i = _pid
  byte process = 0
loop:
  //Non-critical section
  flag[i] = 1
l3:
  atomic {
    process = 0
    for(process: 0 .. (N - 1)){
      (flag[process] < 3)
    }
  }
l4: //doorway
  flag[i] = 3 
l5: //entrance to the wating room
  atomic {
    process = 0
    bool condition = false
    for(process: 0 .. (N - 1)){
      condition = ( condition || flag[process] == 1 )
    }
    if
    :: condition ->
      goto l6
    :: !condition ->
      goto l8
    fi
  }
l6: // l6-l7 the waiting room
  flag[i] = 2
  process = 0
l7:
  do
  :: (flag[process] == 4) ->
    break
  :: else ->
    process = ((process + 1 == N) -> 0 : process + 1)
  od
l8: //l8-l12 the inner sanctum
  flag[i] = 4
l9:
  atomic {
    process = 0
    for(process: 0 .. (i - 1) ){
      (flag[process] < 2)
    }
  }
l10: //Critical section
  count = count + 1
  assert(count == 1)
  count = 0
l11:
  atomic {
    process = 0
    for( process : (i + 1) .. (N - 1) ){
      (flag[process] < 2 || flag[process] == 4)
    }
  }
l12:
  flag[i] = 0
  goto loop
}

#define CS l10
#define DOORWAY l4
#define WAITING_ROOM l7


// Property 1
ltl doorway_locks {(
  always(A[0]@CS implies !(A[1]@DOORWAY || A[2]@DOORWAY || A[3]@DOORWAY)) &&
  always(A[1]@CS implies !(A[0]@DOORWAY || A[2]@DOORWAY || A[3]@DOORWAY)) &&
  always(A[2]@CS implies !(A[0]@DOORWAY || A[1]@DOORWAY || A[3]@DOORWAY)) &&
  always(A[3]@CS implies !(A[0]@DOORWAY || A[1]@DOORWAY || A[2]@DOORWAY))
)}


// Property 2
ltl least_index_in_cs {(
  always(A[1]@CS implies !A[0]@WAITING_ROOM) &&
  always(A[2]@CS implies !(A[0]@WAITING_ROOM || A[1]@WAITING_ROOM)) &&
  always(A[3]@CS implies !(A[0]@WAITING_ROOM || A[1]@WAITING_ROOM || A[2]@WAITING_ROOM)) 
)}

// Property 3
ltl flag_4 {(
  always(A[0]@l12 implies ((A[1]@l7 implies flag[1] == 4) && (A[2]@l7 implies flag[2] == 4) && (A[3]@l7 implies flag[3] == 4))) &&
  always(A[1]@l12 implies ((A[0]@l7 implies flag[0] == 4) && (A[2]@l7 implies flag[2] == 4) && (A[3]@l7 implies flag[3] == 4))) &&
  always(A[2]@l12 implies ((A[0]@l7 implies flag[0] == 4) && (A[1]@l7 implies flag[1] == 4) && (A[3]@l7 implies flag[3] == 4))) &&
  always(A[3]@l12 implies ((A[0]@l7 implies flag[0] == 4) && (A[1]@l7 implies flag[1] == 4) && (A[2]@l7 implies flag[2] == 4)))
)}
