# source docker helpers
. util/docker.sh

echo_lines() {
  for (( i=0; i < ${#lines[*]}; i++ ))
  do
    echo ${lines[$i]}
  done
}

@test "Start Old Container" {
  start_container "simple-single-old" "192.168.0.2"
}

@test "Configure Old Container" {
  run run_hook "simple-single-old" "configure" "$(payload default/configure-production)"

  [ "$status" -eq 0 ] 
}

@test "Start Old Unfs" {
  run run_hook "simple-single-old" "start" "$(payload default/start)"
  [ "$status" -eq 0 ]
  # Verify
  run docker exec simple-single-old bash -c "ps aux | grep [u]nfsd"
  [ "$status" -eq 0 ]
}

@test "Insert Old Unfs Data" {
  run docker exec "simple-single-old" bash -c "echo 'data' > /data/var/db/unfs/test.txt"
  echo_lines
  run docker exec "simple-single-old" bash -c "cat /data/var/db/unfs/test.txt"
  echo_lines
  [ "${lines[0]}" = "data" ]
  [ "$status" -eq 0 ]
}

@test "Start New Container" {
  start_container "simple-single-new" "192.168.0.3"
}

@test "Configure New Container" {
  run run_hook "simple-single-new" "configure" "$(payload default/configure-production)"
  [ "$status" -eq 0 ] 
}

@test "Start New Unfs" {
  run run_hook "simple-single-new" "start" "$(payload default/start)"
  [ "$status" -eq 0 ]
  # Verify
  run docker exec simple-single-new bash -c "ps aux | grep [u]nfsd"
  [ "$status" -eq 0 ] 
}

@test "Stop New Unfs" {
  run run_hook "simple-single-new" "stop" "$(payload default/stop)"
  [ "$status" -eq 0 ]
  while docker exec "simple-single-new" bash -c "ps aux | grep [u]nfsd"
  do
    sleep 1
  done
  # Verify
  run docker exec simple-single-new bash -c "ps aux | grep [u]nfsd"
  [ "$status" -eq 1 ] 
}

@test "Start New SSHD" {
  # start ssh server
  run run_hook "simple-single-new" "import-prep" "$(payload default/import-prep)"
  echo_lines
  [ "$status" -eq 0 ]
}

@test "Pre-Export Old Unfs" {
  run run_hook "simple-single-old" "export-live" "$(payload default/export-live)"
  echo_lines
  [ "$status" -eq 0 ]
}

@test "Update Old Unfs Data" {
  run docker exec "simple-single-old" bash -c "echo 'date' > /data/var/db/unfs/test.txt"
  echo_lines
  run docker exec "simple-single-old" bash -c "cat /data/var/db/unfs/test.txt"
  echo_lines
  [ "${lines[0]}" = "date" ]
  [ "$status" -eq 0 ]
}

@test "Stop Old Unfs" {
  run run_hook "simple-single-old" "stop" "$(payload default/stop)"
  [ "$status" -eq 0 ]
  while docker exec "simple-single-old" bash -c "ps aux | grep [u]nfsd"
  do
    sleep 1
  done
  # Verify
  run docker exec simple-single-old bash -c "ps aux | grep [u]nfsd"
  [ "$status" -eq 1 ] 
}

@test "Export Old Unfs" {
  run run_hook "simple-single-old" "export-final" "$(payload default/export-final)"
  echo_lines
  [ "$status" -eq 0 ]
}

@test "Stop New SSHD" {
  # stop ssh server
  run run_hook "simple-single-new" "import-clean" "$(payload default/import-clean)"
  [ "$status" -eq 0 ]
  while docker exec "simple-single-new" bash -c "ps aux | grep [s]shd"
  do
    sleep 1
  done
}

@test "Restart New Unfs" {
  run run_hook "simple-single-new" "start" "$(payload default/start)"
  [ "$status" -eq 0 ]
  # Verify
  run docker exec simple-single-new bash -c "ps aux | grep [u]nfsd"
  [ "$status" -eq 0 ]
}

@test "Verify New Unfs Data" {
  run docker exec "simple-single-new" bash -c "cat /data/var/db/unfs/test.txt"
  echo_lines
  [ "${lines[0]}" = "date" ]
  [ "$status" -eq 0 ]
}

@test "Stop Old Container" {
  stop_container "simple-single-old"
}

@test "Stop New Container" {
  stop_container "simple-single-new"
}