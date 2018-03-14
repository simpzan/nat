an iOS and macOS project used to explore packet routing and NAT implementation in PacketTunnel.

## how to run it
- run `carthage bootstrap  --no-use-binaries --cache-builds --platform mac` first,
- when open Xcode to compile and run the `NAT-iOS` app.

## environment
- MacBook Pro (Retina, 15-inch, Mid 2015), macOS 10.12.6 (16G1114)
- iPhone SE, iOS 9.3.3 (13G34)

## settings
- tun device ip is `10.25.1.1`;
- set `115.239.210.27` to includedRoutes of tun device.
- tcp server `10.25.1.1:12345` running in containing app process;
- tcp server `10.25.1.1:12344` running in tunnel process;

## what I am trying to implement or what I expect.
I am implementing a ip packet to socket byte array feature using NAT method. the same [feature] is implemented in [fqrouter] on Androd. so I hope this feature can be implemented on iOS and macOS.

the following is the expected data flow in detail.
- browser visit a page, eg. `115.239.210.27`, the request goes to tun device.
- PacketTunnel read request packet `10.25.1.1:54263 -> 115.239.210.27:80` from tun device, change it to `10.25.1.100:54263 -> 10.25.1.1:12344`, and send the modified packet back to tun device.
- the tcp server listening at `10.25.1.1:12344` in tunnel process receive the modified packet, and create a new socket to receive the request data, and forward the request to the physical network device,
- tunnel process receive response data from physical network device, send it back to the socket in last step.
- response packet `10.25.1.1:12344 -> 10.25.1.100:54263` read from tun device, change it back to `115.239.210.27:80 -> 10.25.1.1:54263`, send it back to tun device.
- browser process will receive the response data.

## what I actually happened.
1. tun **didn't** recieve the request packet according to the log. also browser can't open the page at `115.239.210.27`.
2. I make a tcp connect to `115.239.210.27:80` using `createTCPConnectionThroughTunnelToEndpoint` api, tun receive the packets and I NAT them to `10.25.1.1:12344` and send back to tun device, the tcp server listening at `10.25.1.1:12344` in PacketTunnel process **didn't** receive the new connection request. but if I NAT the packets to `10.25.1.1:12345`, and send it back to tun, the tcp server in containing app process **did** receive the packet. change `proxyServerPort` in `NAT.m` to `appProxyPort` to see this behavior.
3. I run the same code in macOS, the 2 issues are reproduced and found another 1 issue. request packets from both `createTCPConnectionToEndpoint` and `stringWithContentsOfURL` apis in PacketTunnel process go to tun device. this behavior causes packets go through tun device infinitely.


[fqrouter](https://github.com/fqrouter/fqrouter)
[feature](http://fqrouter.tumblr.com/post/51474945203/socks%E4%BB%A3%E7%90%86%E8%BD%ACvpn)