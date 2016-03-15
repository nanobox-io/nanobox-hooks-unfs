# source docker helpers
. util/docker.sh

echo_lines() {
  for (( i=0; i < ${#lines[*]}; i++ ))
  do
    echo ${lines[$i]}
  done
}

@test "Start Local Container" {
  start_container "simple-single-local" "192.168.0.2"
}

@test "Configure Local Container" {
  run run_hook "simple-single-local" "configure" "$(payload default/configure-local)"
  echo_lines
  [ "$status" -eq 0 ] 
}

@test "Start Local Unfs" {
  run run_hook "simple-single-local" "start" "$(payload default/start)"
  echo_lines
  [ "$status" -eq 0 ]
  # Verify
  run docker exec simple-single-local bash -c "ps aux | grep [u]nfsd"
  echo_lines
  [ "$status" -eq 0 ]
}

@test "Mount Local Unfs" {
  run docker exec simple-single-local bash -c "mkdir -p /mnt/unfs"
  echo_lines
  [ "$status" -eq 0 ]
  run docker exec simple-single-local bash -c "mount -t nfs -o rw,intr,proto=tcp,vers=3,nolock 192.168.0.2:/data/var/db/unfs /mnt/unfs"
  echo_lines
  [ "$status" -eq 0 ]
}

@test "Insert Local Unfs Data" {
  run docker exec "simple-single-local" bash -c "echo 'data' > /data/var/db/unfs/test.txt"
  echo_lines
  run docker exec "simple-single-local" bash -c "cat /mnt/unfs/test.txt"
  echo_lines
  [ "${lines[0]}" = "data" ]
  [ "$status" -eq 0 ]
}

@test "Stop Local Unfs" {
  run run_hook "simple-single-local" "stop" "$(payload default/stop)"
  echo_lines
  [ "$status" -eq 0 ]
  while docker exec "simple-single-local" bash -c "ps aux | grep [u]nfsd"
  do
    sleep 1
  done
  # Verify
  run docker exec simple-single-local bash -c "ps aux | grep [u]nfsd"
  echo_lines
  [ "$status" -eq 1 ] 
}

@test "Stop Local Container" {
  stop_container "simple-single-local"
}

@test "Start Production Container" {
  start_container "simple-single-production" "192.168.0.2"
}

@test "Configure Production Container" {
  run run_hook "simple-single-production" "configure" "$(payload default/configure-production)"
  echo_lines
  [ "$status" -eq 0 ] 
}

@test "Start Production Unfs" {
  run run_hook "simple-single-production" "start" "$(payload default/start)"
  echo_lines
  [ "$status" -eq 0 ]
  # Verify
  run docker exec simple-single-production bash -c "ps aux | grep [u]nfsd"
  echo_lines
  [ "$status" -eq 0 ]
}

@test "Mount Production Unfs" {
  run docker exec simple-single-production bash -c "mkdir -p /mnt/unfs"
  echo_lines
  [ "$status" -eq 0 ]
  run docker exec simple-single-production bash -c "mount -t nfs -o rw,intr,proto=tcp,vers=3,nolock 192.168.0.2:/data/var/db/unfs /mnt/unfs"
  echo_lines
  [ "$status" -eq 0 ]
}

@test "Insert Production Unfs Data" {
  run docker exec "simple-single-production" bash -c "echo 'data' > /data/var/db/unfs/test.txt"
  echo_lines
  run docker exec "simple-single-production" bash -c "cat /mnt/unfs/test.txt"
  echo_lines
  [ "${lines[0]}" = "data" ]
  [ "$status" -eq 0 ]
}

@test "Stop Production Unfs" {
  run run_hook "simple-single-production" "stop" "$(payload default/stop)"
  echo_lines
  [ "$status" -eq 0 ]
  while docker exec "simple-single-production" bash -c "ps aux | grep [u]nfsd"
  do
    sleep 1
  done
  # Verify
  run docker exec simple-single-production bash -c "ps aux | grep [u]nfsd"
  echo_lines
  [ "$status" -eq 1 ] 
}

@test "Stop Production Container" {
  stop_container "simple-single-production"
}