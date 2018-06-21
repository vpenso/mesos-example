function salt-upload() {
        vm sy lxcm01 -r $MESOS_EXAMPLE/srv/salt :/srv/
}

function salt-apply() {
        local target=${1:-lx}
        vm ex lxcm01 -r -- salt -t 300 -E "$target*" state.apply $2
}

echo 'salt-upload(), salt-apply()'

