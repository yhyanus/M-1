#! /bin/bash
ADA_PROJECT_PATH=/usr/local/lib/gnat:$ADA_PROJECT_PATH
export ADA_PROJECT_PATH
gnatmake -gnat2012 -Pbsmgui.gpr
cp bin/bsmgui $HOME/bin
exit
