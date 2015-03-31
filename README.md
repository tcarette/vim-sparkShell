# vim-sparkShell

This is a very first, basic step for integrating the spark shell with vim.
So far it allows to start a spark shell in tmux, then vim-tbone is used to
send lines to it. There are also functions to enter and exit paste mode.

It's just the minimum for what I wanted. I don't know how far it will
evolve but I thought that maybe somebody might already think it's useful,
as I am.

Note: these are my first vimscript lines and I just discovered tmux...

## Dependencies

* tmux         (tested with version 1.9)
* spark-shell  (tested with version 1.2.0)
* vim-tbone of Tim Pope or [vimux](https://github.com/benmills/vimux.git). In a quick and dirty impulse, I [forked](https://github.com/tcarette/vim-tbone)
tbone to add a carriage return to lines sent to the shell.
* google-chrome (hardcoded in StartSparkShell for opening the jobs)

Tested only with gvim. Note that the use of `gnome-terminal` is also
hard-coded in the plugin. This can be changed by putting and editing the
following variable definition in your vimrc

    let g:termcmd   = "gnome-terminal --title Spark-shell -e"

Extra tip: I forked the [vim-scaladoc](https://github.com/mdreves/vim-scaladoc) of [mdreves](https://github.com/mdreves) to include Spark's scala doc in the index ([here](https://github.com/tcarette/vim-scaladoc))

## Installation and usage

Install the above dependencies.

With pathogen

    ~/.vim/bundle
    git clone git://github.com/tcarette/vim-sparkShell

You can add the following lines to your vimrc.
	
* (Optional) For specifying a directory in which all jars have to be
included. e.g.

		let g:jarDir    = $WORKDIR."/lib/"

* Specifies spark home directory. e.g.

		let g:sparkHome = $HOME."/bin/spark/"

* This option allows to use this vim-sparkShell from within tmux using the vimux plugin. This offers a more portable solution to communicating between vim and the spark shell.

    let g:inTmux         = 1

* Useful mappings

		map <startMap>                  :call StartSparkShell("")<CR>
		map <enter paste>               :call SparkShellEnterPasteEnv()<CR>
		map <sendLine(s)Map>            :call SparkShellSendMultiLine() <CR>
		map <sendAll>                   :silent 1,$ call SparkShellSendMultiLine() <CR>

		nmap <exit paste>               :call SparkShellExitPasteEnv()<CR>
		nmap <killMap>                  :call StopSparkShell()<CR>
		nmap <sendWordUnderCursor>      :call SparkShellSendKey("<C-R><C-W>\r")<CR> 

		vmap <sendSelectionPerChar>    y:call SparkShellSendKey(substitute('<C-R>0',"\"","\\\"","")."\r")<CR>
		vmap <sendSelectionPerLine>     :call SparkShellSendMultiLine() <CR>

		nmap <countObjectUnderCursor>   :call SparkShellSendKey("<C-R><C-W>.count\r")<CR><Esc>
		nmap <take5ObjectUnderCursor>   :call SparkShellSendKey("<C-R><C-W>.take(5).foreach(println)\r")<CR><Esc>
		nmap <seeObjectUnderCursor>     :call SparkShellSendKey("<C-R><C-W>\r")<CR><Esc>
		vmap <seeObjectUnderCursor>    y:call SparkShellSendKey(substitute('<C-R>0',"\"","\\\"","")."\r")<CR>


StartSparkShell takes extra options for the spark shell call.

## Miscellaneous

* Using mintty terminal with cygwin, selecting option "backspace sends ^H" in keys might be necessary
