# Shared by the LEAPP tools rather than a package of its own: a module that the
# .pth file imports at startup of every interpreter whose environment includes it
{
  python3,
  runCommand,
}:
python3.pkgs.toPythonModule (runCommand "leapp-writable-copies" {} ''
  install -Dm444 ${./leapp_writable_copies.py} $out/${python3.sitePackages}/leapp_writable_copies.py
  echo "import leapp_writable_copies" > $out/${python3.sitePackages}/leapp_writable_copies.pth
'')
