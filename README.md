bencode
=====

A library for encoding and decoding [Bencode](https://en.wikipedia.org/wiki/Bencode).

Build
-----

    $ rebar3 compile

Usage
-----

```erlang
1> bencode:encode([1, 2, -30]).
<<"li1ei2ei-30ee">>
2> bencode:encode(#{"def" => 3, "xyz" => 2, "abc" => 1}).
<<"d3:abci1e3:defi3e3:xyzi2ee">>
3> bencode:decode(<<"li1ei2ei3ee">>).
{ok,[1,2,3]}
4> bencode:decode(<<"d7:bencode6:decode10:bittorrenti29ee">>).
{ok,#{<<"bencode">> => <<"decode">>,<<"bittorrent">> => 29}}
```
