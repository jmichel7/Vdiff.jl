module Vdiff
export vdiff
include("Curses.jl")
include("util.jl")
include("Color.jl")
include("button.jl")
include("shade.jl")
include("ok.jl")
include("about.jl")
include("scrolist.jl")
include("whelp.jl")
include("scrolbar.jl")
include("filedesc.jl")
include("pick.jl")
include("option.jl")
include("attprint.jl")
include("colormenu.jl")
include("par.jl")
include("bufregex.jl")
include("field.jl")
include("editbox.jl")
include("Menus.jl")
include("browse.jl")
include("cputil.jl")
include("optmenu.jl")
include("dirpick.jl")
include("diffhs.jl")
include("vdirdiff.jl")
include("fdiff.jl")

function vdiff(n0,n1;flg...)
  n0=expanduser(n0); n1=expanduser(n1)
  for n in (n0,n1) if !ispath(n) error("no such file or directory:$n") end end
  initscr2()
  if LINES()<24 || COLS() <80 
    endwin()
    error("vdiff needs at least 24 lines and 80 columns: detected $(LINES())x$(COLS())") 
  end
  Color.init(schemes[1][:value]...) # in case no option file
  read_options(cfgname)
  if isfile(n0) && isfile(n1) higher_compare(n0,n1;show=true)
  elseif isdir(n0) && isdir(n1) 
    vd=Vdir_pick(n0,n1)
    browse(vd::Vdir_pick;toplevel=true,flg...)
  elseif isdir(n1) p=joinpath(n1,basename(n0))
    if !(ispath(p)) error("no such file or directory:$p") end
    higher_compare(n0,p;show=true)
  else p=joinpath(n0,basename(n1))
    if !(ispath(p)) error("no such file or directory:$p") end
    higher_compare(p,n1;show=true)
  end
  endwin()
end
end
