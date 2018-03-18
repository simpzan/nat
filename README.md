an iOS and macOS project used to explore packet routing and NAT implementation in PacketTunnel.

## how to run it
- open Xcode and compile/run the `NAT-iOS` target.

## environment
- MacBook Pro (Retina, 15-inch, Mid 2015), macOS 10.12.6 (16G1114)
- MacBook Air (13-inch, Mid 2012), 10.12.6 (16G29)
- iPhone SE, iOS 9.3.3 (13G34)
- iPhone X, iOS 11.1.1 (15B150)

## settings
- tun device ip is `10.25.1.1`;
- set `115.239.210.27` to includedRoutes of tun device.
- tcp server `10.25.1.1:12345` running in containing app process;
- tcp server `10.25.1.1:12344` running in tunnel process;

## what I am trying to implement or what I expect.
I am implementing an ip packet to socket byte array feature using NAT method. this [feature](http://fqrouter.tumblr.com/post/51474945203/socks%E4%BB%A3%E7%90%86%E8%BD%ACvpn) is implemented in [fqrouter](https://github.com/fqrouter/fqrouter) on Androd. so I hope this feature can be implemented on iOS and macOS as well.

the following is the expected data flow in detail.
- browser visit a page, eg. `115.239.210.27`, the request goes to tun device.
- PacketTunnel read request packet `10.25.1.1:54263 -> 115.239.210.27:80` from tun device, change it to `10.25.1.100:54263 -> 10.25.1.1:12344`, and send the modified packet back to tun device.
- the tcp server listening at `10.25.1.1:12344` in tunnel process receive the modified packet, and create a new socket to receive the request data, and forward the request to the physical network device,
- tunnel process receive response data from physical network device, send it back to the socket in last step.
- response packet `10.25.1.1:12344 -> 10.25.1.100:54263` read from tun device, change it back to `115.239.210.27:80 -> 10.25.1.1:54263`, send it back to tun device.
- browser process will receive the response data.

## what actually happened or what the issues are.
1. tun **didn't** recieve the request packet according to the log.
click `ContainingAppTest` button to test this behavior.
2. I make a tcp connect to `115.239.210.27:80` using `createTCPConnectionThroughTunnelToEndpoint` api, tun receive the packets and I NAT them to `10.25.1.1:12344` and send back to tun device, the tcp server listening at `10.25.1.1:12344` in PacketTunnel process **didn't** receive the new connection request.
click `ExtensionTest.ThroughTunnelToEndpoint` button to test this behavior. the following is the log from iPhone X.
```
NAT2extension.log:5836:Mar 14 22:12:13 simpzans-iPhone PacketTunnel-iOS[700] <Notice>: -[TunnelServer testTcpConnectionThroughTunnel]
NAT2extension.log:5837:Mar 14 22:12:13 simpzans-iPhone PacketTunnel-iOS[700] <Notice>: error Error Domain=NSPOSIXErrorDomain Code=57 "Socket is not connected"
NAT2extension.log:5838:Mar 14 22:12:13 simpzans-iPhone PacketTunnel-iOS[700] <Notice>: in 10.25.1.1:52086 -> 115.239.210.27:80
NAT2extension.log:5839:Mar 14 22:12:13 simpzans-iPhone PacketTunnel-iOS[700] <Notice>: out 10.25.1.100:52086 -> 10.25.1.1:12344
NAT2extension.log:5840:Mar 14 22:12:14 simpzans-iPhone PacketTunnel-iOS[700] <Notice>: in 10.25.1.1:52086 -> 115.239.210.27:80
NAT2extension.log:5841:Mar 14 22:12:14 simpzans-iPhone PacketTunnel-iOS[700] <Notice>: out 10.25.1.100:52086 -> 10.25.1.1:12344
NAT2extension.log:5843:Mar 14 22:12:15 simpzans-iPhone PacketTunnel-iOS[700] <Notice>: in 10.25.1.1:52086 -> 115.239.210.27:80
NAT2extension.log:5844:Mar 14 22:12:15 simpzans-iPhone PacketTunnel-iOS[700] <Notice>: out 10.25.1.100:52086 -> 10.25.1.1:12344
```

but if I NAT the packets to `10.25.1.1:12345`, and send it back to tun, the tcp server in containing app process **did** receive the packet. change `proxyServerPort` in `NAT.m` to `appProxyPort` and click `ExtensionTest.ThroughTunnelToEndpoint` to see this behavior. the following is the log from iPhone X.
```
NAT2app.log:2289:Mar 14 22:13:26 simpzans-iPhone PacketTunnel-iOS[709] <Notice>: -[TunnelServer testTcpConnectionThroughTunnel]
NAT2app.log:2290:Mar 14 22:13:26 simpzans-iPhone PacketTunnel-iOS[709] <Notice>: in 10.25.1.1:52135 -> 115.239.210.27:80
NAT2app.log:2291:Mar 14 22:13:26 simpzans-iPhone PacketTunnel-iOS[709] <Notice>: out 10.25.1.100:52135 -> 10.25.1.1:12345
NAT2app.log:2292:Mar 14 22:13:26 simpzans-iPhone PacketTunnel-iOS[709] <Notice>: error Error Domain=NSPOSIXErrorDomain Code=57 "Socket is not connected"
NAT2app.log:2293:Mar 14 22:13:26 simpzans-iPhone PacketTunnel-iOS[709] <Notice>: in 10.25.1.1:12345 -> 10.25.1.100:52135
NAT2app.log:2294:Mar 14 22:13:26 simpzans-iPhone PacketTunnel-iOS[709] <Notice>: out 115.239.210.27:80 -> 10.25.1.1:52135
NAT2app.log:2295:Mar 14 22:13:26 simpzans-iPhone PacketTunnel-iOS[709] <Notice>: in 10.25.1.1:52135 -> 115.239.210.27:80
NAT2app.log:2296:Mar 14 22:13:26 simpzans-iPhone PacketTunnel-iOS[709] <Notice>: out 10.25.1.100:52135 -> 10.25.1.1:12345
NAT2app.log:2297:Mar 14 22:13:26 simpzans-iPhone NAT-iOS[708] <Notice>: -[ProxyServer socket:didAcceptNewSocket:]
NAT2app.log:2298:Mar 14 22:13:26 simpzans-iPhone PacketTunnel-iOS[709] <Notice>: in 10.25.1.1:12345 -> 10.25.1.100:52135
NAT2app.log:2299:Mar 14 22:13:26 simpzans-iPhone PacketTunnel-iOS[709] <Notice>: out 115.239.210.27:80 -> 10.25.1.1:52135
NAT2app.log:2300:Mar 14 22:13:26 simpzans-iPhone PacketTunnel-iOS[709] <Notice>: in 10.25.1.1:12345 -> 10.25.1.100:52135
NAT2app.log:2301:Mar 14 22:13:26 simpzans-iPhone PacketTunnel-iOS[709] <Notice>: out 115.239.210.27:80 -> 10.25.1.1:52135
NAT2app.log:2302:Mar 14 22:13:26 simpzans-iPhone PacketTunnel-iOS[709] <Notice>: in 10.25.1.1:12345 -> 10.25.1.100:52135
NAT2app.log:2303:Mar 14 22:13:26 simpzans-iPhone PacketTunnel-iOS[709] <Notice>: out 115.239.210.27:80 -> 10.25.1.1:52135
NAT2app.log:2304:Mar 14 22:13:26 simpzans-iPhone PacketTunnel-iOS[709] <Notice>: in 10.25.1.1:52135 -> 115.239.210.27:80
NAT2app.log:2305:Mar 14 22:13:26 simpzans-iPhone PacketTunnel-iOS[709] <Notice>: out 10.25.1.100:52135 -> 10.25.1.1:12345
NAT2app.log:2306:Mar 14 22:13:26 simpzans-iPhone PacketTunnel-iOS[709] <Notice>: in 10.25.1.1:52135 -> 115.239.210.27:80
```
3. I run the same code in macOS, the 2 issues are reproduced and found another 1 issue. request packets from both `createTCPConnectionToEndpoint` and `stringWithContentsOfURL` apis in PacketTunnel process go to tun device. this behavior causes packets go through tun device infinitely. run `NAT` target to test these behaviors on macOS.

## debug support files
- `NAT2extension.iphonex.log` file in `DebugSupport` dir is the log from iPhone X, NAT to tcp server in PacketTunnel process.
- `NAT2app.iphonex.log`, NAT to tcp server in app process.
- all source code at `https://github.com/simpzan/nat`