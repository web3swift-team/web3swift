#!/bin/sh
# Creates symlinks of hooks in .githooks directory in .git/hooks
# If user already has hooks in .git/hooks then hooks from .githooks
# will be added as separate files with different names and a command
# to run these hooks will be added to the respective existing hooks
# on the last line of the file.

current_dir=${PWD##*/}

if [ "$current_dir" != ".githooks" ]; then
	cd .githooks
fi

shopt -s nullglob
raw_githooks=(*)
exclude=(init_hooks.sh)
githooks=( "${raw_githooks[@]/$exclude}" )

for hook in ${githooks[*]}
do
	git_hook_path="../.git/hooks/$hook"

	web3swift_hook_comment="# web3swift git hook to perform actions like SwiftLint and codespell"
	web3swift_hook_path="source $(pwd)/${hook}"

	is_hook_linked=false

	if test -f $git_hook_path; then
		last_line=$( tac ${git_hook_path} | grep -m 1 -E '[^[:space:]]' )
		if [ "$last_line" = "$web3swift_hook_path" ]; then
			is_hook_linked=true
		fi
	else
		touch $git_hook_path
		chmod +x $git_hook_path
		echo "#!/bin/sh\n" >> $git_hook_path
	fi

	if [ "$is_hook_linked" = false ] ; then
		echo "$web3swift_hook_path" >> $git_hook_path
		echo "${hook} is linked successfully."
	else
		echo "${hook} is already linked."
	fi
done