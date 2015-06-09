" Interact with spark shell quick and dirty
let g:tmuxcnf   = '-f \"' . $HOME . "/.tmux.conf" . '\"'
let g:tmuxsname = "Spark"
let g:inPasteMode = 0

if !exists("g:inTmux")
  let g:inTmux = 0
endif

function! WarningMsg(wmsg)
    echohl WarningMsg
    echomsg a:wmsg
    echohl Normal
endfunction
function! StartSparkShell(extraSparkShellArgs)
	" Take jars from directory
	let jarIncl = ""
	if exists("g:jarDir")
    let jarsList = join(split(globpath(g:jarDir,'*.jar'),'\n'),',') 
    if (jarsList != "")
      if executable("cygpath")
	      let jarIncl=" --jars " . join(map(split(globpath(g:jarDir,'*.jar'),'\n'),'"/cygwin64" . v:val'),',')
      else
	      let jarIncl=" --jars " . join(split(globpath(g:jarDir,'*.jar'),'\n'),',') 
      endif
    endif
	endif
	let sparkCall = g:sparkShellPath . jarIncl . " " . a:extraSparkShellArgs

	" open terminal and google chrome / gnome and osx
  if g:inTmux
    call VimuxRunCommand(sparkCall)
  else
		let tmuxCall  = printf('tmux -2 %s new-session -s %s \"%s\"', 
		        \                 g:tmuxcnf, 
		        \                 g:tmuxsname,
		        \                 sparkCall)
		
		if has("mac") || has("macunix")
		  if !exists("g:termcmd")
		    let g:termcmd   = "osascript -e 'tell application \"Terminal\" to activate' -e 'tell application \"Terminal\" to do script \"".tmuxCall."\"'"
		  endif
		  let s:openchrome = "& /Applications/Google\\ Chrome.app/Contents/MacOS/Google\\ Chrome --app=http://localhost:4040/"
		else
		  if !exists("g:termcmd")
		    let g:termcmd   = "gnome-terminal --title Spark-shell -e \"" . tmuxCall . "\""
		  endif
		  let s:openchrome = "& google-chrome --app=http://localhost:4040/ &"
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
  endif

  return
endfunction

function! SparkShellEnterPasteEnv()
  if !g:inPasteMode && !g:pysparkMode
    let g:inPasteMode = 1
    if g:inTmux
      call VimuxRunCommand(":paste\r")
    else
      call tbone#send_keys("0", ":paste\r")
    endif
  endif
  return
endfunction

function! SparkShellExitPasteEnv()
  if g:inPasteMode && !g:pysparkMode
    if g:inTmux
      call VimuxRunCommand("C-d")
    else
      call tbone#send_keys("0", "C-d")
    endif
    let g:inPasteMode = 0
  endif
  return
endfunction

function! SparkShellSendMultiLine() range
  call SparkShellEnterPasteEnv()
  for ind in range(a:firstline,a:lastline)
    let line = substitute(escape(escape(getline(ind),'\'),'`'),"\t","  ","")
    if len(line) > 0
      " stupid way of getting first non-white space character of the line
      if split(line)[0][0]!~'/\|*'
		    if g:inTmux
		      call VimuxRunCommand(line)
		    else
          call tbone#send_keys("0",line."\r")
        endif
      endif
    endif
  endfor
  call SparkShellExitPasteEnv()
  return
endfunction

function! SparkShellSendLine()
  let line = substitute(escape(escape(getline('.'),'\'),'`'),"\t","  ","")
	if g:inTmux
	  call VimuxRunCommand(line)
	else
    call tbone#send_keys("0",line."\r")
  endif
endfunction

function! SparkShellSendKey(key)
	if g:inTmux
	  call VimuxRunCommand(a:key)
	else
    call tbone#send_keys("0",a:key)
  endif
endfunction

function! StopSparkShell()
  call SparkShellExitPasteEnv()
	if g:inTmux
    call VimuxRunCommand("C-d")
	  call VimuxCloseRunner()
	else
    call tbone#send_keys("0", "C-d")
    call system("tmux kill-session -t " . g:tmuxsname)
  endif
endfunction
