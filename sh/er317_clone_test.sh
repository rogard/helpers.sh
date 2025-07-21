#!/usr/bin/env bash

fallback_msg_fun()
{
    local msg status symb
    status="$1"
    msg="$2"
    case $status in
    	0) symb=✅;;
    	*) symb=❌;;
    esac
    printf '%s %s\n' "$symb" "$msg" >&2
}

array=('msg_fun')

for name in ${array[@]}; do
    fallback_fun="fallback_${name}"
    if ! declare -F "$name" >/dev/null && declare -F "$fallback_fun" >/dev/null; then
        eval "$(declare -f "$fallback_fun" | sed "s/^$fallback_fun/$name/")"
    fi
done

file='bach.sh'
[[ -f "$file" ]] || {
    msg_fun "$?" "$file not a file"
    exit 1
}

source "$file"

script_dir=$(@real realpath $(@real dirname "${BASH_SOURCE[0]}"))

test-clone() {
    temp_dir="$(@real mktemp -d)"
    trap "@real rm -rf '$temp_dir'" EXIT

    source_name='trash.me'
    source_path="$temp_dir/$source_name"
    @real touch "$source_path"
    @real echo "content" > "$source_path"

    export unique_dir="$temp_dir/unique"
    export trash_dir="$temp_dir/trash"

    @real mkdir -p "$unique_dir"
    @real mkdir -p "$trash_dir"

    script_path="${script_dir}/er317_clone.sh"
    target_path=$("$script_path" "$source_path")

    [[ -f "$target_path" ]]; @assert-success
    @assert-equals $(dirname "$target_path") "$unique_dir"
    [[ -f "$source_path" ]]; @assert-fail

#    @assert-equals 1 1
}

# $ ./er317_clone_test.sh
# 1..1
# not ok 1 - clone
# 
# env: 'bash': No such file or directory
# '  EXIT
# export  unique_dir=/tmp/tmp.iR7GSRCV41/unique
# export  trash_dir=/tmp/tmp.iR7GSRCV41/trash
# Assert Failed:
#      Expected: 0
#       But got: 1
# 
# # -----
# # All tests: 1, failed: 1, skipped: 0


