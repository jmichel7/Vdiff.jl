A_NORMAL=NCurses.A_NORMAL;export A_NORMAL
A_ATTRIBUTES=NCurses.A_ATTRIBUTES;export A_ATTRIBUTES
A_CHARTEXT=NCurses.A_CHARTEXT;export A_CHARTEXT
A_COLOR=NCurses.A_COLOR;export A_COLOR
A_STANDOUT=NCurses.A_STANDOUT;export A_STANDOUT
A_UNDERLINE=NCurses.A_UNDERLINE;export A_UNDERLINE
A_REVERSE=NCurses.A_REVERSE;export A_REVERSE
A_BLINK=NCurses.A_BLINK;export A_BLINK
A_DIM=NCurses.A_DIM;export A_DIM
A_BOLD=NCurses.A_BOLD;export A_BOLD
A_ALTCHARSET=NCurses.A_ALTCHARSET;export A_ALTCHARSET
A_INVIS=NCurses.A_INVIS;export A_INVIS
A_PROTECT=NCurses.A_PROTECT;export A_PROTECT
A_HORIZONTAL=NCurses.A_HORIZONTAL;export A_HORIZONTAL
A_LEFT=NCurses.A_LEFT;export A_LEFT
A_LOW=NCurses.A_LOW;export A_LOW
A_RIGHT=NCurses.A_RIGHT;export A_RIGHT
A_TOP=NCurses.A_TOP;export A_TOP
A_VERTICAL=NCurses.A_VERTICAL;export A_VERTICAL
COLOR_BLACK=NCurses.COLOR_BLACK;export COLOR_BLACK
COLOR_RED=NCurses.COLOR_RED;export COLOR_RED
COLOR_GREEN=NCurses.COLOR_GREEN;export COLOR_GREEN
COLOR_YELLOW=NCurses.COLOR_YELLOW;export COLOR_YELLOW
COLOR_BLUE=NCurses.COLOR_BLUE;export COLOR_BLUE
COLOR_MAGENTA=NCurses.COLOR_MAGENTA;export COLOR_MAGENTA
COLOR_CYAN=NCurses.COLOR_CYAN;export COLOR_CYAN
COLOR_WHITE=NCurses.COLOR_WHITE;export COLOR_WHITE
COLOR_PAIR=NCurses.COLOR_PAIR;export COLOR_PAIR

WINDOW=NCurses.WINDOW;export WINDOW
BUTTON1_RELEASED=NCurses.BUTTON1_RELEASED;export BUTTON1_RELEASED
BUTTON1_PRESSED=NCurses.BUTTON1_PRESSED;export BUTTON1_PRESSED
BUTTON1_CLICKED=NCurses.BUTTON1_CLICKED;export BUTTON1_CLICKED
BUTTON1_DOUBLE_CLICKED=NCurses.BUTTON1_DOUBLE_CLICKED;export BUTTON1_DOUBLE_CLICKED
BUTTON2_RELEASED=NCurses.BUTTON2_RELEASED;export BUTTON2_RELEASED
BUTTON2_PRESSED=NCurses.BUTTON2_PRESSED;export BUTTON2_PRESSED
BUTTON2_CLICKED=NCurses.BUTTON2_CLICKED;export BUTTON2_CLICKED
BUTTON2_DOUBLE_CLICKED=NCurses.BUTTON2_DOUBLE_CLICKED;export BUTTON2_DOUBLE_CLICKED
BUTTON3_RELEASED=NCurses.BUTTON3_RELEASED;export BUTTON3_RELEASED
BUTTON3_PRESSED=NCurses.BUTTON3_PRESSED;export BUTTON3_PRESSED
BUTTON3_CLICKED=NCurses.BUTTON3_CLICKED;export BUTTON3_CLICKED
BUTTON3_DOUBLE_CLICKED=NCurses.BUTTON3_DOUBLE_CLICKED;export BUTTON3_DOUBLE_CLICKED
ALL_MOUSE_EVENTS=NCurses.ALL_MOUSE_EVENTS;export ALL_MOUSE_EVENTS
REPORT_MOUSE_POSITION=NCurses.REPORT_MOUSE_POSITION;export REPORT_MOUSE_POSITION
if TUI
KEY_ALT=NCurses.KEY_ALT;export KEY_ALT
KEY_CTRL=NCurses.KEY_CTRL;export KEY_CTRL
KEY_F=NCurses.KEY_F;export KEY_F
KEY_SDELETE=NCurses.KEY_SDELETE;export KEY_SDELETE
KEY_CTRL_DC=NCurses.KEY_CTRL_DC;export KEY_CTRL_DC
KEY_CTRL_DOWN=NCurses.KEY_CTRL_DOWN;export KEY_CTRL_DOWN
KEY_CTRL_END=NCurses.KEY_CTRL_END;export KEY_CTRL_END
KEY_CTRL_LEFT=NCurses.KEY_CTRL_LEFT;export KEY_CTRL_LEFT
KEY_CTRL_HOME=NCurses.KEY_CTRL_HOME;export KEY_CTRL_HOME
KEY_CTRL_NPAGE=NCurses.KEY_CTRL_NPAGE;export KEY_CTRL_NPAGE
KEY_CTRL_PPAGE=NCurses.KEY_CTRL_PPAGE;export KEY_CTRL_PPAGE
KEY_CTRL_RIGHT=NCurses.KEY_CTRL_RIGHT;export KEY_CTRL_RIGHT
KEY_CTRL_UP=NCurses.KEY_CTRL_UP;export KEY_CTRL_UP
KEY_PAD_PLUS=NCurses.KEY_PAD_PLUS;export KEY_PAD_PLUS
KEY_PAD_DIV=NCurses.KEY_PAD_DIV;export KEY_PAD_DIV
KEY_PAD_TIMES=NCurses.KEY_PAD_TIMES;export KEY_PAD_TIMES
KEY_PAD_MINUS=NCurses.KEY_PAD_MINUS;export KEY_PAD_MINUS
ACS_=NCurses.ACS_;export ACS_
COLS=NCurses.COLS;export COLS
LINES=NCurses.LINES;export LINES
clear=NCurses.clear;export clear
clrtobot=NCurses.clrtobot;export clrtobot
clrtoeol=NCurses.clrtoeol;export clrtoeol
erase=NCurses.erase;export erase
refresh=NCurses.refresh;export refresh
attroff=NCurses.attroff;export attroff
attron=NCurses.attron;export attron
bkgd=NCurses.bkgd;export bkgd
wattroff=NCurses.wattroff;export wattroff
wattron=NCurses.wattron;export wattron
mvaddch=NCurses.mvaddch;export mvaddch
mvhline=NCurses.mvhline;export mvhline
mvvline=NCurses.mvvline;export mvvline
mvwaddch=NCurses.mvwaddch;export mvwaddch
mvwhline=NCurses.mvwhline;export mvwhline
mvwvline=NCurses.mvwvline;export mvwvline
wprintw=NCurses.wprintw;export wprintw
printw=NCurses.printw;export printw
mvprintw=NCurses.mvprintw;export mvprintw
mvwprintw=NCurses.mvwprintw;export mvwprintw
addstr=NCurses.addstr;export addstr
hline=NCurses.hline;export hline
vline=NCurses.vline;export vline
MEVENT=NCurses.MEVENT;export MEVENT
else
export KEY_ALT
export KEY_CTRL
export KEY_F
#KEY_SDELETE=NCurses.KEY_SDELETE;export KEY_SDELETE
#KEY_CTRL_DC=NCurses.KEY_CTRL_DC;export KEY_CTRL_DC
#KEY_CTRL_DOWN=NCurses.KEY_CTRL_DOWN;export KEY_CTRL_DOWN
#KEY_CTRL_END=NCurses.KEY_CTRL_END;export KEY_CTRL_END
export KEY_CTRL_LEFT
#KEY_CTRL_HOME=NCurses.KEY_CTRL_HOME;export KEY_CTRL_HOME
export KEY_CTRL_NPAGE
export KEY_CTRL_PPAGE
export KEY_CTRL_RIGHT
#KEY_CTRL_UP=NCurses.KEY_CTRL_UP;export KEY_CTRL_UP
#KEY_PAD_PLUS=NCurses.KEY_PAD_PLUS;export KEY_PAD_PLUS
#KEY_PAD_DIV=NCurses.KEY_PAD_DIV;export KEY_PAD_DIV
#KEY_PAD_TIMES=NCurses.KEY_PAD_TIMES;export KEY_PAD_TIMES
#KEY_PAD_MINUS=NCurses.KEY_PAD_MINUS;export KEY_PAD_MINUS
export ACS_
export COLS
export LINES
export clear
#clrtobot=NCurses.clrtobot;export clrtobot
export clrtoeol
#erase=NCurses.erase;export erase
export refresh
export attroff
export attron
export bkgd
export wattroff
export wattron
#mvaddch=NCurses.mvaddch;export mvaddch
export mvhline
#mvvline=NCurses.mvvline;export mvvline
#mvwaddch=NCurses.mvwaddch;export mvwaddch
export mvwhline
export mvwvline
#wprintw=NCurses.wprintw;export wprintw
#printw=NCurses.printw;export printw
#mvprintw=NCurses.mvprintw;export mvprintw
#mvwprintw=NCurses.mvwprintw;export mvwprintw
export addstr
export mvwaddstr
export hline
export vline
export MEVENT
end
KEY_DOWN=NCurses.KEY_DOWN;export KEY_DOWN
KEY_LEFT=NCurses.KEY_LEFT;export KEY_LEFT
KEY_UP=NCurses.KEY_UP;export KEY_UP
KEY_RIGHT=NCurses.KEY_RIGHT;export KEY_RIGHT
KEY_HOME=NCurses.KEY_HOME;export KEY_HOME
KEY_BACKSPACE=NCurses.KEY_BACKSPACE;export KEY_BACKSPACE
KEY_DC=NCurses.KEY_DC;export KEY_DC
KEY_IC=NCurses.KEY_IC;export KEY_IC
KEY_SF=NCurses.KEY_SF;export KEY_SF
KEY_SR=NCurses.KEY_SR;export KEY_SR
KEY_NPAGE=NCurses.KEY_NPAGE;export KEY_NPAGE
KEY_PPAGE=NCurses.KEY_PPAGE;export KEY_PPAGE
KEY_ENTER=NCurses.KEY_ENTER;export KEY_ENTER
KEY_BTAB=NCurses.KEY_BTAB;export KEY_BTAB
KEY_BEG=NCurses.KEY_BEG;export KEY_BEG
KEY_END=NCurses.KEY_END;export KEY_END
KEY_SEND=NCurses.KEY_SEND;export KEY_SEND
KEY_SHOME=NCurses.KEY_SHOME;export KEY_SHOME
KEY_SLEFT=NCurses.KEY_SLEFT;export KEY_SLEFT
KEY_SNEXT=NCurses.KEY_SNEXT;export KEY_SNEXT
KEY_SPREVIOUS=NCurses.KEY_SPREVIOUS;export KEY_SPREVIOUS
KEY_SRIGHT=NCurses.KEY_SRIGHT;export KEY_SRIGHT
KEY_MOUSE=NCurses.KEY_MOUSE;export KEY_MOUSE
curses_version=NCurses.curses_version;export curses_version
beep=NCurses.beep;export beep
can_change_color=NCurses.can_change_color;export can_change_color
cbreak=NCurses.cbreak;export cbreak
def_prog_mode=NCurses.def_prog_mode;export def_prog_mode
delwin=NCurses.delwin;export delwin
doupdate=NCurses.doupdate;export doupdate
endwin=NCurses.endwin;export endwin
getbegx=NCurses.getbegx;export getbegx
getbegy=NCurses.getbegy;export getbegy
getcurx=NCurses.getcurx;export getcurx
getcury=NCurses.getcury;export getcury
getmaxx=NCurses.getmaxx;export getmaxx
getmaxy=NCurses.getmaxy;export getmaxy
getmouse=NCurses.getmouse;export getmouse
has_colors=NCurses.has_colors;export has_colors
winch=NCurses.winch;export winch
initscr=NCurses.initscr;export initscr
keypad=NCurses.keypad;export keypad
leaveok=NCurses.leaveok;export leaveok
mousemask=NCurses.mousemask;export mousemask
nodelay=NCurses.nodelay;export nodelay
noecho=NCurses.noecho;export noecho
notimeout=NCurses.notimeout;export notimeout
overwrite=NCurses.overwrite;export overwrite
reset_prog_mode=NCurses.reset_prog_mode;export reset_prog_mode
scrollok=NCurses.scrollok;export scrollok
start_color=NCurses.start_color;export start_color
touchwin=NCurses.touchwin;export touchwin
wclear=NCurses.wclear;export wclear
wclrtobot=NCurses.wclrtobot;export wclrtobot
wclrtoeol=NCurses.wclrtoeol;export wclrtoeol
werase=NCurses.werase;export werase
#wgetch=NCurses.wgetch;export wgetch
#getch=NCurses.getch;export getch
wnoutrefresh=NCurses.wnoutrefresh;export wnoutrefresh
wrefresh=NCurses.wrefresh;export wrefresh
curs_set=NCurses.curs_set;export curs_set
derwin=NCurses.derwin;export derwin
halfdelay=NCurses.halfdelay;export halfdelay
init_color=NCurses.init_color;export init_color
init_pair=NCurses.init_pair;export init_pair
mouseinterval=NCurses.mouseinterval;export mouseinterval
mvwin=NCurses.mvwin;export mvwin
newpad=NCurses.newpad;export newpad
newwin=NCurses.newwin;export newwin
resizeterm=NCurses.resizeterm;export resizeterm
subpad=NCurses.subpad;export subpad
wbkgd=NCurses.wbkgd;export wbkgd
wmove=NCurses.wmove;export wmove
wresize=NCurses.wresize;export wresize
wtimeout=NCurses.wtimeout;export wtimeout
copywin=NCurses.copywin;export copywin
prefresh=NCurses.prefresh;export prefresh
pnoutrefresh=NCurses.pnoutrefresh;export pnoutrefresh
box=NCurses.box;export box
waddch=NCurses.waddch;export waddch
wborder=NCurses.wborder;export wborder
whline=NCurses.whline;export whline
wvline=NCurses.wvline;export wvline
waddstr=NCurses.waddstr;export waddstr
