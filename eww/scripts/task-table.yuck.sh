#!/usr/bin/env bash

json_string() {
  jq -Rs .
}

echo '(box :orientation "vertical" :class "todo-table"'

echo '  (box :orientation "horizontal" :class "todo-row todo-header" :space-evenly false'
echo '    (label :class "todo-id" :width 30 :text "ID")'
echo '    (label :class "todo-due" :width 70 :text "DUE")'
echo '    (label :class "todo-desc" :hexpand true :xalign 0 :text "TASK")'
echo '    (label :class "todo-actions-spacer" :text ""))'

task status:pending export | jq -r '
  sort_by(-(.urgency // 0))
  | .[0:8][]
  | [
      (.id | tostring),
      (.due // "-"),
      (.description // "(no description)")
    ]
  | @tsv
' | while IFS=$'\t' read -r id due desc; do

  format_task_due() {
    local due="$1"
  
    if [ -z "$due" ] || [ "$due" = "-" ]; then
      echo "-"
      return
    fi
  
    local formatted
    formatted="$(echo "$due" | sed -E 's/^([0-9]{4})([0-9]{2})([0-9]{2})T([0-9]{2})([0-9]{2})([0-9]{2})Z$/\1-\2-\3 \4:\5:\6 UTC/')"
  
    local due_epoch today_epoch days
    due_epoch="$(date -d "$formatted" +%s 2>/dev/null)" || {
      echo "$due"
      return
    }
  
    today_epoch="$(date -d today +%s)"
    days=$(( (due_epoch - today_epoch) / 86400 ))
  
    case "$days" in
      0) echo "today" ;;
      1) echo "tomorrow" ;;
      -*) echo "overdue" ;;
      *)
        if [ "$days" -le 7 ]; then
          echo "${days}d"
        else
          date -d "$formatted" "+%d %b"
        fi
        ;;
    esac
  }

  due="$(format_task_due "$due")"
    
  id_json="$(printf '%s' "${id:-"-"}" | json_string)"
  due_json="$(printf '%s' "${due:-"-"}" | json_string)"
  desc_json="$(printf '%s' "${desc:-"(no description)"}" | json_string)"

  echo '  (box :orientation "horizontal" :class "todo-row" :space-evenly false'
  echo "    (label :class \"todo-id\" :width 30 :text $id_json)"
  echo "    (label :class \"todo-due\" :width 70 :text $due_json)"
  echo "    (label :class \"todo-desc\" :hexpand true :xalign 0 :text $desc_json)"

  echo "    (button :class \"todo-select-button\""
  echo "      :onclick \"eww update active_task_id='$id' active_task_desc='$desc'\""
  echo '      "›")'

  echo "    (button :class \"todo-done-button\""
  echo "      :onclick \"~/.config/eww/scripts/task-action.sh done $id\""
  echo '      "✓")'

  echo "    (button :class \"todo-delete-button\""
  echo "      :onclick \"~/.config/eww/scripts/task-action.sh delete $id\""
  echo '      "✕"))'
done

echo ')'
