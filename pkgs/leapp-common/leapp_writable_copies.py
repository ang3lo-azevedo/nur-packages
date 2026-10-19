# The LEAPP tools copy their report assets with shutil.copy2 and copytree, which
# carry over the read-only modes of the Nix store and leave reports that cannot
# be deleted. Every copy they make is turned owner-writable after its modes are set.
# Loaded at interpreter start by leapp_writable_copies.pth.
import os
import shutil

_copymode = shutil.copymode
_copystat = shutil.copystat


def _make_writable(dst):
    if os.path.islink(dst):
        return
    try:
        os.chmod(dst, os.stat(dst).st_mode | 0o200)
    except OSError:
        pass


def copymode(src, dst, *, follow_symlinks=True):
    _copymode(src, dst, follow_symlinks=follow_symlinks)
    _make_writable(dst)


def copystat(src, dst, *, follow_symlinks=True):
    _copystat(src, dst, follow_symlinks=follow_symlinks)
    _make_writable(dst)


shutil.copymode = copymode
shutil.copystat = copystat
