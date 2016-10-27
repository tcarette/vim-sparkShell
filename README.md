# vim-sparkShell

This is a very first, basic step for integrating the spark shell (or pyspark) with vim.
So far it allows to start a spark shell in tmux, then vim-tbone or vimux is used to
send lines to it. There are also functions to enter and exit paste mode.

It's just the minimum for what I wanted. I don't know how far it will
evolve but I thought that maybe somebody might already think it's useful,
as I am.

Disclaimer: these are my first vimscript lines and I just discovered tmux...

## Dependencies

* tmux         (tested with version 1.9, fails with 1.6)
* spark-shell, pyspark
* vim-tbone of Tim Pope or [vimux](https://github.com/benmills/vimux.git).

It has been tested with macvim, gvim, and vim under cygwin (embedded in tmux), but it might require some tweaking in your vimrc (see below).

Extra tip: I forked the [vim-scaladoc](https://github.com/mdreves/vim-scaladoc) of [mdreves](https://github.com/mdreves) to include Spark's scala doc in the index ([here](https://github.com/tcarette/vim-scaladoc)). And of course, ctags is awesome.

## Installation and usage

Install the above dependencies.

With pathogen

    ~/.vim/bundle
    git clone git://github.com/tcarette/vim-sparkShell

You can add the following lines to your vimrc.
	
* (Optional) For specifying a directory in which all jars have to be
included. e.g.

		let g:jarDir    = $WORKDIR."/lib/"

* Specifies spark path. e.g.

		let g:sparkShellPath = $HOME."/bin/spark/bin/spark-shell"

* This option allows to use this vim-sparkShell from within tmux using the vimux plugin. This offers a more portable solution to communicating between vim and the spark shell.

    let g:inTmux         = 1

* To work with pyspark, define

    let g:pysparkMode = 1

The only difference is that it bypass anythong to do with the spark-shell paste environment

* Useful mappings

The following mappings work for pyspark and spark-shell

		map <startMap>                  :call StartSparkShell("")<CR>
		map <enter paste>               :call SparkShellEnterPasteEnv()<CR>
		map <sendLine(s)Map>            :call SparkShellSendMultiLine() <CR>
		map <sendAll>                   :silent 1,$ call SparkShellSendMultiLine() <CR>

		nmap <exit paste>               :call SparkShellExitPasteEnv()<CR>
		nmap <killMap>                  :call StopSparkShell()<CR>
		nmap <sendWordUnderCursor>      :call SparkShellSendKey("<C-R><C-W>\r")<CR> 

		vmap <sendSelectionPerChar>    y:call SparkShellSendKey(substitute('<C-R>0',"\"","\\\"","")."\r")<CR>
		vmap <sendSelectionPerLine>     :call SparkShellSendMultiLine() <CR>

		nmap <countObjectUnderCursor>   :call SparkShellSendKey("<C-R><C-W>.count()\r")<CR><Esc>
		nmap <seeObjectUnderCursor>     :call SparkShellSendKey("<C-R><C-W>\r")<CR><Esc>
		vmap <seeObjectUnderCursor>    y:call SparkShellSendKey(substitute('<C-R>0',"\"","\\\"","")."\r")<CR>

The following is specific to scala (autocmd FileType scala <...>)

		nmap <take5ObjectUnderCursor>   :call SparkShellSendKey("<C-R><C-W>.take(5).foreach(println)\r")<CR><Esc>

and this one does the same thing in pyspark

		nmap <take5ObjectUnderCursor>   :call SparkShellSendKey("for e in <C-R><C-W>.take(5) : print(e)\r\r")<CR><Esc>

StartSparkShell takes extra options for the spark shell call, e.g.

		let g:sparkOptions = "--master local[2]"

## Miscellaneous - Issues

* Using mintty terminal with cygwin, selecting option "backspace sends ^H" in keys might be necessary

* There is a problem with case classes in Scala repl that yield type mismatch errors when it shouldn't
https://groups.google.com/forum/#!topic/scala-user/lmpM74EWB3E
https://community.cloudera.com/t5/Advanced-Analytics-Apache-Spark/Simple-Scala-code-not-working-in-Spark-shell-repl/td-p/16564
For completeness, the following keyword-related issue is supposed to be fixed
https://issues.apache.org/jira/browse/SPARK-1199
I asked a question about it here
http://stackoverflow.com/questions/29768717/type-mismatch-with-identical-types-in-spark-shell
it seems that a solution is to send case class statement in isolated :paste environment

* In cygwin, sending keys to another tmux pane is very slow. If anybody has a suggestion...
cf. http://unix.stackexchange.com/questions/277856/send-keys-across-tmux-panes-in-vim-in-cygwin-is-painfully-slow
(and it is not this issue: http://superuser.com/questions/252214/slight-delay-when-switching-modes-in-vim-using-tmux-or-screen)
