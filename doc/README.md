# Hacker News Blacklist

A Chrome 22 (& hopefully newer) extension for
http://news.ycombinator.com.

## Features:

* __Collapse uninteresting links__ via title, host name or user name filters.
* Collapse/expand comments.
* __Automatically collapse all read comments__ & jump to 1st unread one.
* Keyboard navigation in comments pages.

  <table border="1">
  <tr>
  <th>Press this key</th>
  <th>To do this</th>
  </tr>
  <tr>
  <td><kbd>'</kbd></td>
  <td>Collapse/expand current comment</td>
  </tr>
  <tr>
  <td><kbd>;</kbd></td>
  <td>Collapse/expand current sub-thread</td>
  </tr>
  <tr>
  <td><kbd>j</kbd></td>
  <td>Move to the next comment</td>
  </tr>
  <tr>
  <td><kbd>k</kbd></td>
  <td>Move to the previous comment</td>
  </tr>
  <tr>
  <td><kbd>l</kbd></td>
  <td>Jump to next user's comment</td>
  </tr>
  <tr>
  <td><kbd>h</kbd></td>
  <td>Jump to previous user's comment</td>
  </tr>
  <tr>
  <td><kbd>.</kbd></td>
  <td>Jump to the next expanded comment</td>
  </tr>
  <tr>
  <td><kbd>,</kbd></td>
  <td>Jump to the previous expanded comment</td>
  </tr>
  <tr>
  <td><kbd>]</kbd></td>
  <td>Jump to the next root comment</td>
  </tr>
  <tr>
  <td><kbd>[</kbd></td>
  <td>Jump to the previous root comment</td>
  </tr>
  <tr>
  <td><kbd>}</kbd></td>
  <td>Jump to the next comment on the same level</td>
  </tr>
  <tr>
  <td><kbd>{</kbd></td>
  <td>Jump to the previous comment on the same level</td>
  </tr>
  </table>

* Mouse clicks on `[-]` & `[+]`:

  <table border="1">
  <tr>
  <th>Click with</th>
  <th>To do this</th>
  </tr>
  <tr>
  <td><kbd>Button1</kbd></td>
  <td>Collapse/expand sub-thread</td>
  </tr>
  <tr>
  <td><kbd>Alt-Button1</kbd></td>
  <td>Collapse/expand sub-thread w/o moving a cursor</td>
  </tr>
  <tr>
  <td><kbd>Ctrl-Button1</kbd></td>
  <td>Move the cursor</td>
  </tr>
  </table>


## Build requirements:

* CoffeeScript installed via npm in global (`-g`) mode.
* jsontool in global mode.
* GNU m4 (on Fedora, make a symlink `ln -s /usr/m4 ~/bin/gm4`).
* xxd utility.
* GNU make.


## Compilation

To compile, run

    $ make compile

To make a .crx file, you'll need a private RSA key named `private.pem`
in the same directory where Makefile is. For testing purposes, generate
it with openssl:

    $ openssl genrsa -out private.pem 1024

and run:

    $ make crx

If everything was fine, `hackernews_blacklist-x.y.z.crx` file will appear.
