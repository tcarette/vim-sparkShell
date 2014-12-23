" Interact with spark shell quick and dirty
let g:tmuxcnf   = '-f "' . $HOME . "/.tmux.conf" . '"'
let g:tmuxsname = "Spark"
if !exists("g:termcmd")
  let g:termcmd   = "gnome-terminal --title Spark-shell -e"
endif

function WarningMsg(wmsg)
    echohl WarningMsg
    echomsg a:wmsg
    echohl Normal
endfunction
function StartSparkShell(extraSparkShellArgs)

  " Take jars from directory
  if exists("g:jarDir")
    let jarIncl="--jars " . join(split(globpath(g:jarDir,'*.jar'),'\n'),',') 
  else
    let jarIncl = ""
  endif
  let sparkCall = g:sparkHome . "/bin/spark-shell " . jarIncl . a:extraSparkShellArgs

  " Start spark shell in tmux
  let opencmd   = printf("%s 'tmux -2 %s new-session -s %s \"%s\"' &", 
        \                 g:termcmd,  
        \                 g:tmuxcnf, 
        \                 g:tmuxsname,
        \                 sparkCall)
  let log = system(opencmd)
  if v:shell_error
    call WarningMsg(log)
    return
  endif

  return
endfunction
