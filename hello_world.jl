#
# Copyright 2022 Clemens Cords
# Created on 04.05.2022 by clem (mail@clemens-cords.com)
#

#ccall(:system, Int32, (Cstring,), "clear")
Base.atreplinit((_) -> (ccall(:system, Int32, (Cstring,), "clear")))
