
service_name="Unfs"
default_port=2049

wait_for_running() {
  container=$1
  until docker exec ${container} bash -c "ps aux | grep [u]nfsd"
  do
    sleep 1
  done
}

wait_for_listening() {
  container=$1
  ip=$2
  port=$3
  until docker exec ${container} bash -c "nc -q 1 ${ip} ${port} < /dev/null"
  do
    sleep 1
  done
}

wait_for_stop() {
  container=$1
  while docker exec ${container} bash -c "ps aux | grep [u]nfsd"
  do
    sleep 1
  done
}

verify_stopped() {
  container=$1
  run docker exec ${container} bash -c "ps aux | grep [u]nfsd"
  echo_lines
  [ "$status" -eq 1 ]
}

insert_test_data() {
  container=$1
  ip=$2
  port=$3
  key=$4
  data=$5
  run docker exec ${container} bash -c "echo '${data}' > /data/var/db/unfs/${key}.txt"
}

update_test_data() {
  container=$1
  ip=$2
  port=$3
  key=$4
  data=$5
  run docker exec ${container} bash -c "echo '${data}' > /data/var/db/unfs/${key}.txt"
}

verify_test_data() {
  container=$1
  ip=$2
  port=$3
  key=$4
  data=$5
  run docker exec ${container} bash -c "mkdir -p /mnt/unfs"
  run docker exec ${container} bash -c "mount -t nfs -o rw,intr,proto=tcp,vers=3,nolock ${ip}:/data/var/db/unfs /mnt/unfs"
  [ "$status" -eq 0 ]
  run docker exec ${container} bash -c "cat /mnt/unfs/${key}.txt"
  echo_lines
  [ "${lines[0]}" = "${data}" ]
  [ "$status" -eq 0 ]
  run docker exec ${container} bash -c "umount /mnt/unfs"
}

verify_plan() {
  expected=$(cat <<-END
{
  "redundant": false,
  "horizontal": false,
  "users": [
    {
      "username": "gonano",
      "meta": {
      }
    }
  ],
  "ips": [
    "default"
  ],
  "port": 22,
  "mount_protocol": "nfs",
  "behaviors": [
    "migratable",
    "backupable",
    "mountable"
  ]
}
END
)
  [ "$output" = "$expected" ]
}
