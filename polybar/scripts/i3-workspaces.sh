#!/usr/bin/env bash

render_workspaces() {
    i3-msg -t get_workspaces |
        jq -r '
            def display_name:
		{
		  "1": " admin",
		  "2": " scratch",
		  "3": " terminal",
		  "4": " files",
		  "5": " docs",
		  "6": " misc",
		  "7": " media",
		  "8": " chat",
		  "9": " web",
		  "10": " code",
                }[(.num | tostring)]
                // ("workspace " + (.num | tostring));

            sort_by(.num)[]
            | [
                (.num | tostring),
                (
                    (.num | tostring)
                    + ": "
                    + display_name
                ),
                (.focused | tostring),
                (.visible | tostring),
                (.urgent | tostring)
              ]
            | @tsv
        ' |
        while IFS=$'\t' read -r num display focused visible urgent; do
            action_start="%{A1:i3-msg -q workspace number ${num}:}"
            action_end="%{A}"

            if [[ "$urgent" == "true" ]]; then
                printf '%s%%{B#dc322f}%%{F#ffffff} %s %%{F-}%%{B-}%s ' \
                    "$action_start" "$display" "$action_end"

            elif [[ "$focused" == "true" ]]; then
                printf '%s%%{B#268bd2}%%{F#ffffff} %s %%{F-}%%{B-}%s ' \
                    "$action_start" "$display" "$action_end"

            elif [[ "$visible" == "true" ]]; then
                printf '%s%%{B#586e75}%%{F#ffffff} %s %%{F-}%%{B-}%s ' \
                    "$action_start" "$display" "$action_end"

            else
                printf '%s%%{F#93a1a1} %s %%{F-}%s ' \
                    "$action_start" "$display" "$action_end"
            fi
        done

    printf '\n'
}

render_workspaces

i3-msg -t subscribe -m '["workspace","window"]' |
while read -r _; do
    render_workspaces
done
