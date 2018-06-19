function salt-upload() {
  vm sy lxcm01 -r $MESOS_EXAMPLE/srv/salt :/srv/
}

function salt-apply() {
  vm ex lxcm01 -r -- salt -t 300 "'$1'" state.apply $2
}

echo 'Functions: salt-upload(), salt-apply()'

