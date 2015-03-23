" Interact with spark shell quick and dirty
let g:tmuxcnf   = '-f \"' . $HOME . "/.tmux.conf" . '\"'
let g:tmuxsname = "Spark"
let g:inPasteMode = 0

function! WarningMsg(wmsg)
    echohl WarningMsg
    echomsg a:wmsg
    echohl Normal
endfunction
function! StartSparkShell(extraSparkShellArgs)
	" Take jars from directory
	if exists("g:jarDir")
	  let jarIncl="--jars " . join(split(globpath(g:jarDir,'*.jar'),'\n'),',') 
	else
	  let jarIncl = ""
	endif
	let sparkCall = g:sparkHome . "/bin/spark-shell " . jarIncl . " " . a:extraSparkShellArgs
	let tmuxCall  = printf('tmux -2 %s new-session -s %s \"%s\"', 
	        \                 g:tmuxcnf, 
	        \                 g:tmuxsname,
	        \                 sparkCall)
	
	" open terminal and google chrome / gnome and osx
	if has("mac") || has("macunix")
	  if !exists("g:termcmd")
	    let g:termcmd   = "osascript -e 'tell application \"Terminal\" to activate' -e 'tell application \"Terminal\" to do script \"".tmuxCall."\"'"
	  endif
	  let s:openchrome = "& /Applications/Google\\ Chrome.app/Contents/MacOS/Google\\ Chrome --app=http://localhost:4040/"
	else
	  if !exists("g:termcmd")
	    let g:termcmd   = "gnome-terminal --title Spark-shell -e \"" . tmuxCall . "\""
	  endif
	  let s:openchrome = "& google-chrome --app=http://localhost:4040/"
	endif

  " Start spark shell in tmux
  let opencmd   = g:termcmd . " " . s:openchrome
  let log = system(opencmd)
  if v:shell_error
    call WarningMsg(log)
    return
  endif

  " attach specific session to avoid conflict with, e.g., Vim-R sessions
  call tbone#attach_command(g:tmuxsname)

  return
endfunction

function! SparkShellEnterPasteEnv()
  if g:inPasteMode == 0
    let g:inPasteMode = 1
    call tbone#send_keys("0", ":paste\r")
  endif
  return
endfunction

function! SparkShellExitPasteEnv()
  if g:inPasteMode == 1
    call tbone#send_keys("0", "C-d")
    let g:inPasteMode = 0
  else
    echom "Not in paste mode"
  endif
  return
endfunction

function! SparkShellSendMultiLine() range
  call SparkShellEnterPasteEnv()
  for ind in range(a:firstline,a:lastline)
    if len(getline(ind)) > 0
      " stupid way of getting first non-white space character of the line
      if split(getline(ind))[0][0]!~'/\|*'
        execute "silent" ind "Twrite 0"
      endif
    endif
  endfor
  call SparkShellExitPasteEnv()
  return
endfunction
