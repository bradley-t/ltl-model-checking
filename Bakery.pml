/**
  It looks like this works great
  until the label byte overflows.

  I have limited the number of times 
  a process can run for the following
  two reasons:

  1. Prevent overflow of the ticket variable
  2. Reduce the time to verify the model
  
  Note: The time required to verify four 
  processes is still very large. 3 or less
  proccesses or 2 or less loops will decrease 
  the time significantly
 */

#define NUM_PROCESSES 4
#define MAX_LOOPS 4

bit flag[NUM_PROCESSES]
byte label[NUM_PROCESSES]

byte count = 0

inline find_max() {
  for (i : 0 .. NUM_PROCESSES - 1){
    if
    :: max < label[i] ->
    max = label[i]
    :: else ->
    fi
  }
}

inline lock(_pid) {
  flag[_pid] = 1
  find_max()
  label[_pid] = max + 1
  i = 0
  for( i : 0 .. NUM_PROCESSES - 1 ){
    (flag[i] == 0 || label[i] > label[_pid] || (label[i] == label[_pid] && i <= _pid))
  }
}

inline unlock() {
  flag[_pid] = 0;
}

active [NUM_PROCESSES] proctype A(){
  byte loops = 0
  byte max = 0
  byte i = 0

loop:
  printf("Process %d locking\n", _pid)
locking:
  lock(_pid)
  printf("Process %d entering cs with ticket %d\n", _pid, label[_pid])
cs:
  printf("Process %d unlocking\n", _pid)
  unlock()
  loops = loops + 1
  if
  :: loops < MAX_LOOPS ->
  goto loop
  ::else ->
  fi
  printf("\n\n%d\n\n", _nr_pr)
}

#define PROCS_IN_CS (A[0]@cs + A[1]@cs + A[2]@cs + A[3]@cs)

ltl mutual_exclusion { always( PROCS_IN_CS <= 1 ) }
ltl deadlock { always( timeout -> _nr_pr == 1 ) }
ltl sharing {(
  always( A[0]@locking implies eventually(A[0]@cs) ) &&
  always( A[1]@locking implies eventually(A[1]@cs) ) &&
  always( A[2]@locking implies eventually(A[2]@cs) ) &&
  always( A[3]@locking implies eventually(A[3]@cs) ) 
)}