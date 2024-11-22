# the following are global variables deliberately to persist between Vdir_pick
global gside::Int=1 # which side is the cursor in
global show_filter::String="=lr<>?" # what items to show

const vdhelp="""
  This  screen displays two  directories being compared,  lined up by name.
  The size and the date of each entry are shown in the panels.
  The  central  column shows: 
    {HL =} if the entries are equal (subject to the current options), 
    {HL >} if they differ and the left entry is more recent,
    {HL <} if they differ and the right entry is more recent,
    {HL l} if the entry is present only in the left  directory,  
    {HL r} if the entry is present only in the right directory,
    {HL ?} if the entries have not yet been completely compared.
  If a name is too wide to be entirely displayed in the central column, the
  keys {HL →} and {HL ←} will scroll right and left that name.

             {BOX  Moving around: }

  {HL Tab}           Move selection bar to the other directory.
  {HL ↑},{HL k}           Move selection bar one line up.
  {HL ↓},{HL j}           Move selection bar one line down.
  {HL PgUp}          Move selection bar one screen up.
  {HL PgDn},{HL ^F},{HL Space} Move selection bar one screen down.
  {HL ^U}/{HL ^D}         Move selection bar one half-screen up/down.
  {HL ^PgUp},{HL Home}    Go to top of directory display.
  {HL ^PgDn},{HL \$},{HL End}   Go to bottom of directory display.
  {HL +}             Go to the next entries which differ.
  {HL -}             Go to the previous entries which differ.

             {BOX  Changing the display: }

  {HL F4}            Toggle between: show a full comparison of the directories/
                 show only entries present in both and unequal.
  {HL =}             Toggle between: show/don't show equal entries.
  {HL l}             Toggle between: show/don't show entries only on left.
  {HL r}             Toggle between: show/don't show entries only on right.
  {HL >}             Toggle between: show/don't show entries newer on left.
  {HL <}             Toggle between: show/don't show entries newer on right.
  {HL AltN}          Sort entries alphabetically.
  {HL AltE}          Sort entries by extension.
  {HL AltS}          Sort entries by size (in current column).
  {HL AltT}          Sort entries by time (in current column).

             {BOX  Acting on the files in the display: }

  {HL Enter}         Compare the current entries, or, if the other entry is
                 absent, browse the current entry.
  {HL R}             Recursively compare the current directory entries.
  {HL F3}            Browse the current entry.
  {HL Del},{HL d}         Delete the current entry.
  {HL c}             Copy the current entry to the other directory. 
  {HL C}             Copy non-recursively the current entry to the other 
                 directory, that is copy directories but not their contents.
  {HL e},{HL F5}          Call editor on current file.
               (the command to do that can be specified in the option menu).
  {HL v}             Call editor on both files in 2 windows.
               (the command to do that can be specified in the option menu)

             {BOX  Miscellaneous: }

  {HL h},{HL F1}          Display this message
  {HL F9}            Escape to the Shell.
  {HL Esc},{HL q}         Exit this screen.

             {BOX  Mouse actions: }

   You can click on any menu item, and on the arrows in the scroll bars.
   Clicking on an entry sets the cursor there. Double-clicking on an entry
   does the same as Enter.  
   You can click on {HL name}, {HL ext}, {HL size} or {HL date} to sort accordingly.
"""

push!(opt.h,
:onlylength=>Dict(:name=>"just_size",
  :shortdesc=>"files are assumed identical if they have same size.",
  :longdesc=>"This  leads  to  the  fastest  possible  directory  comparison  in
   exchange  for  uncertainty  in  the  correctness of the comparison.",
  :value=>false,
  :level=>OK),
:length_and_timestamp=>Dict(:name=>"just_size_and_timestamp",
:shortdesc=>"files are assumed identical if they have same size and timestamp.",
:longdesc=>"This  leads  to  a  fast  directory  comparison  in exchange  for
some small uncertainty in the  correctness of the comparison. This option  can
 be very useful when comparing directory trees across slow networks or drives.",
:value=>true,
:level=>OK)
)

# sorted arrays -- return 2-tuples (entry,matched) or (entry,nothing)
function sorted_merge(a::AbstractVector,b::AbstractVector;by=identity)
  i=1;j=1
  res=Tuple{Union{eltype(a),Nothing},Union{eltype(b),Nothing}}[]
  while i<=length(a) && j<=length(b)
    if by(a[i])<by(b[j]) push!(res,(a[i],nothing));i+=1
    elseif by(a[i])>by(b[j]) push!(res,(nothing,b[j]));j+=1
    else push!(res,(a[i],b[j]));i+=1;j+=1
    end
  end
  while i<=length(a) push!(res,(a[i],nothing));i+=1 end
  while j<=length(b) push!(res,(nothing,b[j]));j+=1 end
  res
end

function printsz(s,width)
  if isnothing(s) return " "^width  end
  res=""
  if iszero(s.mode&Base.Filesystem.S_IRUSR)
    width-=1
    res*="r"
  end
# int i=0;if(flg&S_IFSYS)i++;if(flg&S_IFHID)i+=2;
# if(i){lg--;pos+=sprintf(pos,"%c",(unsigned char)"\0\xb0\xb1\xb2"[i]);}
  if myisdir(s) res*=lpad("< DIR >",width)
  else res*=lpad(nbK(s.size),width)
  end
  res
end

function printtm(s,width)
  if isnothing(s) return " "^width  end
  if width>=18 Dates.format(unix2datetime(s.mtime),"dd u yy HH:mm:SS")
  elseif width>=15 Dates.format(unix2datetime(s.mtime),"dd u yy HH:mm")
  else Dates.format(unix2datetime(s.mtime),"dd u yy")
  end
end

# a pair of File::Stat f[2], filename and cmp
# to which can be added son if recursively examining
@ExtObj mutable struct PathPair  
  filename::String
  cmp::Char
  f::NTuple{2,Union{Base.Filesystem.StatStruct,Nothing}}
  PathPair(filename,cmp,f)=new(filename,cmp,f,Dict{Symbol,Any}())
end

function PathPair(f0,f1)
  hasf0=!isnothing(f0)
  hasf1=!isnothing(f1)
  filename=hasf0 ? f0.filename : f1.filename
  if hasf0 && hasf1
    if isdir(f0)!=isdir(f1) cmp=f0.stat.mtime>f1.stat.mtime ? '>' : '<'
    else cmp='?'
    end
  else cmp=hasf0 ? 'l' : 'r'
  end
  PathPair(filename,cmp,(hasf0 ? f0.stat : nothing,hasf1 ? f1.stat : nothing))
end

Base.getindex(p::PathPair,i)=p.f[i]

Base.setindex!(p::PathPair,s,i)=p.f=i==1 ? (s,p.f[2]) : p.f=(p.f[1],s)

function stripspace(s)
  res=Char[]
  inspace=true
  for c in s
    if isvalid(c) && isspace(c) if !inspace push!(res,' '); inspace=true; end
    else push!(res,c); inspace=false
    end
  end
  if inspace && !isempty(res) String(res[1:end-1])
  else String(res)
  end
end

function higher_compare(n0,n1;show=false)
  eqsize=filesize(n0)==filesize(n1)
  peq=if opt.onlylength || !eqsize eqsize
  else
    t=abs(round(Int,mtime(n0))-round(Int,mtime(n1)))
    eqtime=(t<=3600*9 && t%3600 in [-1,0,1])
    opt.length_and_timestamp && eqtime
  end
  if !show && peq newcmp=true
  else newcmp=compare_files(n0,n1;probably_equal=peq,info=infohint)
  end
  if show
    if newcmp werror("files are identical")
    else newcmp=vdifff(n0,n1)
    end
  end
  newcmp
end

# compare files using options in opt
# ignore_endings => ignore different endings mac/linux/windows
# ignore_blkseq => ignore differences in whitespace in same line
# ignore_blklin => ignore blank lines
# ignore_case => ignore case differences
function compare_files(n0,n1; info::Function=println,probably_equal=false)
  hint(m)=info("$(basename(n0)):$(nbK(m)) compared")
  newcmp=true
  sz=0
  try
    a=open(n0);b=open(n1)
    if !any(o->getproperty(opt,o),(:ignore_endings,:ignore_blkseq,:ignore_blklin,:ignore_case))
      if opt.length_and_timestamp && probably_equal newcmp=true
      else
      while !eof(a) && !eof(b)
        l1=read(a,BLOCKSIZE)
        l2=read(b,BLOCKSIZE)
        if l1!=l2 newcmp=false;break end
        sz+=BLOCKSIZE
        hint(sz)
      end
      newcmp=eof(a)==eof(b) && newcmp
      end
    else
      low(s)=all(isvalid,s) ? lowercase(s) : s
      prev=0
      while !eof(a) && !eof(b)
        l1=readline(a)
        l2=readline(b)
        if opt.ignore_endings l1=chomp(l1);l2=chomp(l2) end
        if opt.ignore_blkseq l1=stripspace(l1);l2=stripspace(l2) end 
        if opt.ignore_case l1=low(l1);l2=low(l2) end
        if l1!=l2 newcmp=false;break end
        sz+=length(l1)
        if sz-prev>BLOCKSIZE hint(sz);prev=sz;end
      end
      newcmp=eof(a)==eof(b) && newcmp
    end
    close(a);close(b)
  catch e
    error("$e doing compare")
    return false
  end
  newcmp
end

function list_from_dirs(n1,n2,old=nothing)
  left,right=map(n->sort!(map(f->Filedesc(joinpath(n,f)),readdir(n))),(n1,n2))
  pairs=map(p->PathPair(p...),sorted_merge(left,right))
  if !isnothing(old) # copy still-valid comparison info from old pairs
    for (n,o) in sorted_merge(pairs,old;by=x->x.filename)
      if !isnothing(o) && n.cmp=='?' && o[1]==n[1] && o[2]==n[2]
        n.cmp=o.cmp
        if haskey(o,:son) n.son=o.son end
      end
    end
  end
  pairs
end
 
function Base.show(io::IO,f::PathPair)
  print(io,"(",join(map(x->isnothing(x) ? "-" : myisdir(x) ? 'D' : 'F',f.f),""),f.cmp,")",f.filename)
end

function extension(p::PathPair)
  m=match(r"\.([a-zA-Z_]*)",p.filename)
  isnothing(m) ? "" : m[1]
end

function restat(p::PathPair,names)
  for i in 1:2
    try
      p[i]=stat(joinpath(names[i],p.filename))
    catch exc
      werror("$exc doing stat")
      p[i]=nothing
      p.cmp="lr"[i] 
    end
  end
end

global vdmenu::Menu
function initvdmenu() #setup menu
  if !isdefined(Main,:dmenu) 
  wmove(stdscr,0,0)
  cm=Menu(infohint)
  add(cm," &File ",
    ["&Compare\tEnter",KEY_ENTER,"Compare the files/directories at cursor"],
    ["&Recursively compare\tR",'R',"Recursively compare the directories at cursor"],
    ["&Edit\te,F5",'e',"Call editor on current file"],
    ["Edit &both\tv",'v',"Call editor on both current files"],
    ["&Delete\tDel,d",'d',"Delete current file"],
    ["C&opy\tc",'c',"Copy current file to other side"],
    ["Bro&wse\tF3",KEY_F(3),"Browse current file"],
     "-",
    ["E&xit screen\tEsc",0x1b,"Exit current screen"])
  add(cm," &View ",
    [show_filter=="<>?" ? "&Full compare\tF4" : "&Common unequal\tF4",KEY_F(4),
     show_filter=="<>?" ?
	    "Show a full comparison of the directories" :
            "Show only files common to both sides and different"],
    ["&Equal\t=",'=',"Show/do not show files equal on both sides"],
    ["Only on &left\tl",'l',"Show/do not show files present only on left"],
    ["Only on &right\tr",'r',"Show/do not show files present only on right"],
    ["&Newer on left\t>",'>',"Show/do not show files more recent on left"],
    ["Ne&wer on right\t<",'<',"Show/do not show files more recent on right"])
  add(cm," &Options ",OPTMENU,COLORMENU,EDITMENU,EDITBOTHMENU,SAVEOPTMENU)
  add(cm,HELPMENU...,ABOUTMENU)
  # position of next items is adjusted in redraw_panes
  wmove(stdscr,LINES()-3,33)
  add(cm,"&Name",KEY_ALT('N')) 
  add(cm,".&Ext",KEY_ALT('E'))
  for i in 0:1
    wmove(stdscr,LINES()-3,i*(COLS()-29)+4) 
    add(cm,"&Size",KEY_ALT('S')+512*(i+1))
    wmove(stdscr,LINES()-3,i*(COLS()-29)+19)
    add(cm,"&Time",KEY_ALT('T')+512*(i+1))
  end
  global vdmenu=cm
  end
end

@ExtObj mutable struct Vdir_pick
  name::Vector{String}
  p::Pick_list
  ppairs::Vector{PathPair}
  namewidth::Int
  pane_width::Int
  name_column::Int
  panes::Vector{Int}
  cmp_column::Int
  sz_width::Int
  tm_width::Int
  offset::Int
end

function Base.dump(vd::Vdir_pick)
 "#$(length(vd.ppairs)) maxw:$(vd.namewidth) o:$(vd.offset)"
end
 
Base.pairs(vd::Vdir_pick)=vd.p.s.list

function current(vd)
  if length(vd.p.s)>0 return vd.ppairs[pairs(vd)[vd.p.sel_bar]] end
end

function current(vd,side)
  p=current(vd)
  if !isnothing(p) p[side] end
end

function curname(vd,s=gside)
  joinpath(vd.name[s],current(vd).filename)
end

function Vdir_pick(n0,n1;old=nothing)
  initvdmenu()
  lpairs=list_from_dirs(n0,n1,old)
  s=Scroll_list(stdscr,collect(eachindex(lpairs));rows=LINES()-5,cols=COLS()-2,
                begy=2,begx=1)
  p=Pick_list(s)
  namewidth=max(12,maximum(map(x->textwidth(x.filename),lpairs);init=0))
  pane_width=32 # width of a panel including shade
  if namewidth+4>COLS()-2*pane_width pane_width=29 end
  panes=[1,1+COLS()-pane_width] # starts of panes
  namewidth=min(namewidth,COLS()-2*pane_width-4)
  name_column=min(1+pane_width+div(COLS()-2*pane_width-4-namewidth,2),
                  COLS()-namewidth-pane_width-3)
  cmp_column=name_column+namewidth
  sz_width=10
  tm_width=pane_width-sz_width-4
  vd=Vdir_pick([n0,n1],p,lpairs,namewidth,pane_width,name_column,panes,cmp_column,
    sz_width,tm_width,0,Dict{Symbol,Any}())
  vd.height=LINES()-3 
  vd.sort_up=true
  vd.sort='N'
  add_scrollbar(s,vd.name_column-1)
  s.showentry=function(s,pos)
    d=pos<=length(s.list) ? vd.ppairs[s.list[pos]] : nothing
    hl=(pos==p.sel_bar)
    wmove(s.win,x=vd.name_column);add(s.win,hl ? :BAR : :NORM)
    add(s.win,printfname(d,vd.namewidth,vd.offset;norm=hl ? :BAR : :NORM)...)
    wmove(s.win,x=vd.cmp_column);add(s.win,:HL,Int(isnothing(d) ? ' ' : d.cmp))
    for n in 1:2
      hls=(hl && n==gside)
      t=(hl ? "▶" : ACS_(:VLINE))
      wmove(s.win,x=vd.panes[n]-1);add(s.win,:BOX,t)
      if hls add(s.win,:BAR)  end
      if isnothing(d) add(s.win," "^vd.sz_width)
      elseif !isnothing(d[n])
        if !hls add(s.win,:NORM) end
	add(s.win,printsz(d[n],vd.sz_width))
      else
        if !hls add(s.win,:GREY) end
        add(s.win,cpad("-absent-",vd.sz_width))
      end
      if !hls add(s.win,:BOX) end
      add(s.win,ACS_(:VLINE))
      if isnothing(d)
        add(s.win," "^vd.tm_width)
      elseif !isnothing(d[n])
        if !hls add(s.win,:NORM) end
	add(s.win,printtm(d[n],vd.tm_width))
      else
        if !hls add(s.win,:GREY) end
        add(s.win,cpad("--",vd.tm_width))
      end
      add(s.win,:BOX,t)
    end
  end
  vd
end

function next_such(f,vd;advance=true) # next with property f
  l=length(pairs(vd))
  i=min(vd.p.sel_bar,l)
  if i<l && advance i+=1 end
  while i<l && !f(vd.ppairs[pairs(vd)[i]]) i+=1 end
  move_bar_to(vd.p,i)
end

function prev_such(f,vd;retreat=true) # prev with property f
  l=length(pairs(vd))
  i=min(vd.p.sel_bar,l)
  if retreat && i>1 i-=1 end
  while i>0 && (i>length(vd.p.s) || !f(vd.ppairs[pairs(vd)[i]])) i-=1 end
  move_bar_to(vd.p,i)
end

function preserve_sel_bar(f,vd)
  cur=vd.p.sel_bar<=length(pairs(vd)) ? pairs(vd)[vd.p.sel_bar] : nothing
  f(vd)
# rng=searchsorted(list,cur,by=i->by(vd.sort,vd.ppairs[i]))
# vd.p.sel_bar=last(rng)
  if cur!=nothing cur=findfirst(==(cur),pairs(vd)) end
  vd.p.sel_bar=isnothing(cur) ? 1 : cur
  show(vd.p)
  vd.p.s.on_scroll(vd.p.s)
end
  
function update_sort(vd::Vdir_pick,c::Char)
  sdecor(s)=add(stdscr,:HL,s ? ACS_(:DARROW) : ACS_(:UARROW))
  sdecor()=add(stdscr,:BOX,ACS_(:HLINE))
  if vd.sort==c vd.sort_up=!vd.sort_up else vd.sort_up=true end
  vd.sort=c
  wmove(stdscr,vd.height,vd.name_column)
  if vd.sort=='N' sdecor(vd.sort_up) else sdecor() end
  wmove(stdscr,vd.height,vd.name_column+11)
  if vd.sort=='E' sdecor(vd.sort_up) else sdecor() end
  for i in 1:2
    wmove(stdscr,vd.height,vd.panes[i]+2)
    if vd.sort=='S' && gside==i sdecor(vd.sort_up) else sdecor() end
    wmove(stdscr,vd.height,vd.panes[i]+17)
    if vd.sort=='T' && gside==i sdecor(vd.sort_up) else sdecor() end
  end
  function by(sortp,d::PathPair)
   (isnothing(d[gside]) ? !myisdir(d[3-gside]) : !myisdir(d[gside]),
    if sortp=='N' d.filename
    elseif sortp=='E' extension(d)
    elseif sortp=='S' isnothing(d[gside]) ? 0 : d[gside].size
    elseif sortp=='T' isnothing(d[gside]) ? 0 : d[gside].mtime
    end)
  end
  preserve_sel_bar(vd)do vd
    sort!(pairs(vd),by=i->by(vd.sort,vd.ppairs[i]),rev=!vd.sort_up)
  end
end

function check_showfilter(vd::Vdir_pick)
  preserve_sel_bar(vd)do vd
    vd.p.s.list=filter(i->vd.ppairs[i].cmp in show_filter,eachindex(vd.ppairs))
  end
  redraw_panes(vd) # namewidth may have changed
end
   
function browse(vd::Vdir_pick;toplevel=false,flg...)
  p=vd.p
  s=p.s
  save=Shadepop(s.begx-1,s.begy-1,2+s.rows,s.cols+1)
  fill(vd;flg...)
  check_showfilter(vd)
  c=getch()
  while true
    if c==KEY_MOUSE
      c=process_event(vd,getmouse())
      if c!=-1 && c!==nothing continue end
    elseif c in (Int('q'),Int('Q'),0x1b) 
      if !toplevel || 'y'==ok("leave vdiff") break end
    elseif c in (Int('h'),KEY_F(1)) whelp(vdhelp,"directory comparison screen")
    elseif c==KEY_CTRL('I')
      global gside=3-gside
      disp_entry(s,p.sel_bar)
    elseif c==KEY_RIGHT vd.offset+=1;show(p)
    elseif c==KEY_LEFT if vd.offset>0 vd.offset-=1;show(p) end
    elseif c in (KEY_ALT('E'),KEY_ALT('N'),KEY_ALT('T'),KEY_ALT('S'))
            update_sort(vd,'A'+c-KEY_ALT('A'))
    elseif c in (KEY_ALT('S')+512,KEY_ALT('S')+1024) 
            gside=div(c,512);update_sort(vd,'S')
    elseif c in (KEY_ALT('T')+512,KEY_ALT('T')+1024) 
            gside=div(c,512);update_sort(vd,'T')
    elseif c in Int.(('l','r','=','<','>'))
      global show_filter
      if Char(c) in show_filter 
        show_filter=replace(show_filter,string(Char(c))=>"")
      else show_filter*=Char(c)
      end
#      @@cm.heads[1].items[CMP.index(c.chr)+1].toggle
      check_showfilter(vd)
    elseif c==KEY_F(4)
      if '=' in show_filter show_filter="<>?" else show_filter="=lr<>?" end
      check_showfilter(vd)
    elseif c==KEY_F(3)
      if isnothing(current(vd,gside)) beep();c=getch();continue end
      if myisdir(current(vd,gside)) dirbrowse(curname(vd))
      else browse_file(curname(vd))
      end
    elseif c in (KEY_ENTER , KEY_CTRL('J'))
      if isnothing(current(vd,gside)) beep();c=getch();continue end
      if !isnothing(current(vd,3-gside)) check_current(vd;show=true)
      else c=KEY_F(3); continue
      end
    elseif c==Int('R')
      if isnothing(current(vd,gside)) || isnothing(current(vd,3-gside))
        beep();c=getch();continue
      end
      check_current(vd;recur=true,show=false)
    elseif c in (Int('c'), KEY_IC)
      if isnothing(current(vd,gside)) beep;c=getch();continue end 
      dest=curname(vd,3-gside)
      if cpmv(curname(vd),dest;cpopts...)
        current(vd).cmp='='
        current(vd)[3-gside]=stat(dest)
        check_showfilter(vd)
      end
    elseif c==Int('C')
      if isnothing(current(vd,gside)) || !isdir(current(vd,gside))
       beep;c=getch();continue 
      end 
      if cpmv(curname(vd),curname(vd,3-gside);cpopts...,recursive=false)
        current(vd)[3-gside]=stat(curname(vd,3-gside))
        disp_entry(s,vd.p.sel_bar)
        next_such(p->p[gside]!==nothing,vd)
        prev_such(p->p[gside]!==nothing,vd;retreat=false)
      end
    elseif c in (Int('d'), KEY_DC)
      if isnothing(current(vd,gside)) beep
      elseif myrm(curname(vd);rmopts...)
        v=PathPair(curname(vd),'=',current(vd).f)
        current(vd)[gside]=nothing
        if !isnothing(current(vd,3-gside))
          current(vd).cmp="rl"[gside]
          disp_entry(s,vd.p.sel_bar)
          next_such(p->p[gside]!==nothing,vd)
 	else
          del=pairs(vd)[p.sel_bar]
          deleteat!(vd.ppairs,del)
          deleteat!(pairs(vd),p.sel_bar) # recompute list instead?
          for i in eachindex(pairs(vd))
            if pairs(vd)[i]>del pairs(vd)[i]-=1 end
          end
          next_such(p->p[gside]!==nothing,vd;advance=false)
 	end
        prev_such(p->p[gside]!==nothing,vd;retreat=false)
        show(vd.p)
      end
    elseif c in (Int('e'),KEY_F(5))
      if isnothing(current(vd,gside)) beep()
      else exec(make_edit_command(curname(vd),0))
        check_current(vd;show=false)
      end
    elseif c in (KEY_F(9), Int('x'))
      exec(nothing,vd.name[gside])
#     reagain()
    elseif c==Int('v')
      exec(make_edit_both_command(curname(vd,1),curname(vd,2),0,0))
      check_current(vd;show=false)
    elseif c==Int('+') next_such(p->p.cmp!='=',vd)
    elseif c==Int('-') prev_such(p->p.cmp!='=',vd)
    elseif c in (KEY_F(6),Int('o'))
      res=optionmenu()
      if RECOMPUTE==res #reagain()
      elseif RECOMPUTE_DIFFS==res  && 'y'==
        ok("recompute differences (changes in options may have affected them)")
      #  reagain()
      else redraw_panes(vd)
      end
    elseif !do_key(p,c)
      c=Menus.do_key(vdmenu,c)
      if !isnothing(c)
        if c isa Function c()
        else continue
        end
      end
    end
    c=getch()
  end
  restore(save)
  return vd
end

# redraw panes and dependent menu items
function redraw_panes(vd::Vdir_pick)#;refresh=true) 
  background()
  vd.pane_width=32 # width of a panel including shade
  vd.namewidth=max(12,maximum(map(i->textwidth(vd.ppairs[i].filename),pairs(vd));init=0))
  if vd.namewidth+4>COLS()-2*vd.pane_width vd.pane_width=29 end
  vd.panes=[1,1+COLS()-vd.pane_width] # starts of panes
  vd.namewidth=min(vd.namewidth,COLS()-2*vd.pane_width-4)
  vd.name_column=min(1+vd.pane_width+div(COLS()-2*vd.pane_width-4-vd.namewidth,2),
                     COLS()-vd.namewidth-vd.pane_width-3)
  vd.cmp_column=vd.name_column+vd.namewidth
  vd.sz_width=10
  vd.tm_width=vd.pane_width-vd.sz_width-4
  if vd.height==0 vd.height=LINES()-3 end
  shaded_frame(stdscr,1,vd.name_column-1,vd.height,3+vd.namewidth)
  vd.p.s.sb.x=vd.name_column-1
  mvadd(stdscr,1,vd.name_column+4,:BOX,"entry")
#   if refresh then on_scroll else init_scroll(@name_column-1) end
# init_scroll(vd.name_column-1) # necessary if pane_width changed
  for i in 1:2
    shaded_frame(stdscr,1,vd.panes[i]-1,vd.height,vd.pane_width-1)
    mvadd(stdscr,1,vd.panes[i]+vd.sz_width,:BOX,ACS_(:TTEE))
    wmove(stdscr,2,vd.panes[i]+vd.sz_width);vline(0,vd.height-2)
    mvadd(stdscr,vd.height,vd.panes[i]+vd.sz_width,ACS_(:BTEE))
    printnormedpath(1,vd.panes[i],vd.name[i],vd.pane_width-3)
  end
  cm=vdmenu
# set the Size, Time, Name Ext indicators in their proper column
  Menus.setx(cm.heads.v[5],vd.name_column+1)
  Menus.setx(cm.heads.v[6],vd.name_column+6)
  Menus.setx(cm.heads.v[9],3+vd.panes[2])
  Menus.setx(cm.heads.v[10],18+vd.panes[2])
# show in View the cmp viewed
  for i in cm.heads.v[2].items.v[2:6]
    i.checked=Char(i.action) in show_filter
  end
# show in View signification of F4
  Menus.install(cm.heads.v[2].items.v[1],
   show_filter=="<>?" ? "&Full compare\tF4" : "&Common unequal\tF4",
   show_filter=="<>?" ?  "Show a full comparison of the directories" :
          "Show only files common to both sides and different")
  Curses.refresh(cm)
  show(vd.p)
  vd.p.s.on_scroll(vd.p.s)
end


function check_current(vd;do_not_stat=false,show=false,recur=false)
  v=current(vd)
  if !do_not_stat restat(v,vd.name) end
  if isnothing(v[1]) || isnothing(v[2]) return end
  if myisdir(v[1])!= myisdir(v[2])
    foo(i)=i ? "directory" : "file"
    werror("$(curname(vd,1)) is a $(foo(myisdir(v[1]))) but $(curname(vd,2)) is a $(foo(myisdir(v[2])))")
    return
  end
  if myisdir(v[1])
    if !show && !recur return end
    infohint(v.filename)
    son=Vdir_pick(curname(vd,1),curname(vd,2);old=haskey(v,:son) ? v.son : nothing)
    if show browse(son;show)
    elseif recur
      try
        fill(son;recur,do_not_stat)
      catch e
        werror("$e")
      end
    end
    if all(p->p.cmp=='=',son.ppairs) v.cmp='='
    else v.cmp=v[1].mtime>v[2].mtime ? '>' : '<'
    end
    check_showfilter(vd)
    v.son=son.ppairs
  else
    newcmp=higher_compare(curname(vd,1),curname(vd,2);show)
    if newcmp v.cmp='='
    else v.cmp=v[1].mtime>v[2].mtime ? '>' : '<'
    end
    move_bar_to(vd.p,vd.p.sel_bar)
# when "link" then  
#   if File.readlink(curname(vd,1))==File.readlink(curname(vd,2)) then v.cmp=?= 
#   else v.cmp=v[0].mtime>v[1].mtime ? ?> : ?<
#   end
# else werror("#{v[0].ftype} not implemented")
  end
end

function Base.fill(vd::Vdir_pick;recur=false,flg...)
  preserve_sel_bar(vd)do vd
    for (i,p) in enumerate(vd.ppairs)
  #   werror("$i:$p")
      if p.cmp!='?' continue end
      j=findfirst(==(i),pairs(vd))
      move_bar_to(vd.p,j)
  #   try 
      check_current(vd;do_not_stat=true,recur)
  #   catch Interrupt
  #     raise Interrupt if ?y==ok("comparison of "+current.filename+
  #" interrupted. Interrupt also directory comparison")
  #   end
      if !isnothing(current(vd)) && !(current(vd).cmp in show_filter) 
        deleteat!(pairs(vd),j) 
      end
    end
  end
  redraw_panes(vd)
end

# nothing did nothing
# -1 processed event
# else key to return
function process_event(d::Vdir_pick,e)
  c=process_event(vdmenu,e)
  if !isnothing(c)
    if c isa Function c(); return -1
    else return c 
    end
  end
  if !(d.p.s.begy<=e.y<=d.p.s.begy+d.p.s.rows-1 &&
       among(e,BUTTON1_PRESSED|BUTTON1_CLICKED|BUTTON1_DOUBLE_CLICKED))
    return nothing
  end
  global gside
  if d.panes[1]-1<=e.x<=d.panes[1]+d.pane_width gside=1
  elseif d.panes[2]-1<=e.x<=d.panes[2]+d.pane_width gside=2
  end
  c=process_event(d.p,e)
  if c==-1 
    if e.bstate==BUTTON1_DOUBLE_CLICKED return KEY_ENTER
    else return -1 
    end
  end
end
