#define N 4

mtype = {elected, election}
chan queue [N] = [20] of {mtype, byte}

byte election_result[N]

inline announce_elected(_pid){
  elected_process = _pid
  printf("pid %d was elected\n", _pid)
  queue[((_pid - 1) >= 0 -> _pid - 1 : N - 1)]!elected(_pid)
  queue[_pid]??elected(eval(_pid))
  goto end
}

active [N] proctype A(){
  byte recieved
  byte elected_process
  byte next = ((_pid - 1) >= 0 -> (_pid - 1) : (N - 1))
  byte d = _pid
  byte e
  byte f

active_p:
  do
  :: queue[_pid]??[elected(elected_process)] ->
  queue[_pid]??elected(elected_process)
  queue[next]!elected(elected_process)
  goto end
  :: else ->
    queue[next]!election(d)
    queue[_pid]?recieved(e)
    if
    :: recieved == election ->
    :: recieved == elected ->
    elected_process = e
    queue[next]!elected(elected_process)
    goto end
    fi
    if
    :: e == _pid ->
    announce_elected(_pid)
    :: e != _pid ->
    fi
    if
    :: d > e ->
    queue[next]!election(d)
    :: d <= e ->
    queue[next]!election(e)
    fi
    queue[_pid]?recieved(f)
    if
    :: recieved == election ->
    :: recieved == elected ->
    elected_process = f
    queue[next]!elected(elected_process)
    goto end
    fi
    if
    :: f == _pid ->
    announce_elected(_pid)
    :: f != _pid ->
    fi
    if
    :: (e >= d && e >= f) ->
    d = e
    :: e < d || e < f ->
    goto relay_p
    fi
  od
relay_p:
  queue[_pid]?recieved(d)
  if
  :: recieved == election ->
  :: recieved == elected ->
  elected_process = d
  queue[next]!elected(elected_process)
  goto end
  fi
  if
  :: d == _pid ->
  announce_elected(_pid)
  :: d != _pid ->
  queue[next]!election(d)
  fi
  goto relay_p
end:
  election_result[_pid] = elected_process
}

#define max_pid (N - 1)
#define election_over (_nr_pr == 1)
#define universal_leader 

ltl one_leader { always( election_over implies (
  election_result[0] == election_result[1] &&
  election_result[1] == election_result[2] &&
  election_result[2] == election_result[3]
))}
ltl leader_eventually_elected { eventually( election_over ) }
ltl highest_pid_elected { always( election_over implies (election_result[0] == max_pid) )}