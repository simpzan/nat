a macOS project to explore NAT implementation in PacketTunnel.

run `carthage bootstrap  --no-use-binaries --cache-builds --platform mac` first, when open Xcode to compile and run the app.

filter `PacketTunnel` keyword in Console app to see logs from both the app and appExtension.
`PacketTunnel` is appExtension process, `PacketTunnelNAT` is the app process.
