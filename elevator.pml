#define NUM_FLOORS 4
#define N NUM_FLOORS
#define None N

#define TOTAL_ELEVATOR_CALLS 200

#define OPEN 1
#define CLOSED 0

#define ON 1
#define OFF 0


mtype = { call_elevator }

byte n_floor
byte servicing_floor_ = None
byte doors_open = None
byte current_floor = 0
bit elevator_doors[ NUM_FLOORS ]
bit indicator_light[ NUM_FLOORS ]
chan button[ NUM_FLOORS ] = [1] of { mtype }

inline service_floor() {
  printf("Servicing floor %d\n", current_floor)
  servicing_floor_ = current_floor
  elevator_doors[current_floor] = OPEN
  doors_open = current_floor
  button[current_floor]?call_elevator
  doors_open = None
  elevator_doors[current_floor] = CLOSED
  indicator_light[current_floor] = OFF 
  servicing_floor_ = None
}
inline move_elevator(floor) {
  current_floor = floor
  printf("Elevator moved to floor %d\n", floor)
}

active proctype elevator() {

  do
  :: current_floor > 0 ->
    move_elevator(current_floor - 1)
    if
    :: button[current_floor]?[call_elevator] ->
    service_floor()
    :: else ->
    fi
  :: else ->
find_called_floor:
    n_floor = N - 1
    do
    :: button[n_floor]?[call_elevator] ->
    move_elevator(n_floor)
    service_floor()
    break
    :: else ->
      if
      :: n_floor > 0 ->
        n_floor = n_floor - 1
      :: else ->
        n_floor = N - 1
      fi
    od
  od
}

active proctype people() {
  byte floor;
loop:
    select(floor : 1 .. (N - 1))
    if
    :: !button[floor]?[call_elevator] ->
      printf("Calling elevator to floor %d\n", floor)
      button[floor]!call_elevator
      indicator_light[floor] = ON
    :: else ->
    fi
    goto loop
}

ltl doors_only_open_with_elevator_present {
  always(doors_open != None implies doors_open == current_floor)
}

ltl floor_eventually_served {
  always(
    (button[0]?[call_elevator] implies eventually(current_floor == 0)) &&
    (button[1]?[call_elevator] implies eventually(current_floor == 1)) &&
    (button[2]?[call_elevator] implies eventually(current_floor == 2)) &&
    (button[3]?[call_elevator] implies eventually(current_floor == 3)) 
  )
}

ltl elevator_returns { always( eventually( current_floor == 0 ) ) }

ltl top_floor_served_first { 
  always( 
    ( elevator@find_called_floor && button[N - 1]?[call_elevator] ) 
    implies 
    (  servicing_floor_ == None  U  servicing_floor_ == N - 1 ) 
  ) 
}

