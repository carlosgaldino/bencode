-module(bencode_tests).
-include_lib("eunit/include/eunit.hrl").

decode_int_test() ->
    ?assertEqual({ok, 23}, bencode:decode(<<"i23e">>)),
    ?assertEqual({ok, -3}, bencode:decode(<<"i-3e">>)),
    ?assertEqual({ok, 0}, bencode:decode(<<"i0e">>)).

decode_string_test() ->
    ?assertEqual({ok, <<"bencode">>}, bencode:decode(<<"7:bencode">>)),
    ?assertEqual({ok, <<"bittorrent">>}, bencode:decode(<<"10:bittorrent">>)).

decode_list_test() ->
    ?assertEqual({ok, [1, 2, 3, <<"bencode">>]}, bencode:decode(<<"li1ei2ei3e7:bencodee">>)).

decode_map_test() ->
    ?assertEqual({ok, #{<<"bencode">> => <<"decode">>, <<"bittorrent">> => 29}}, bencode:decode(<<"d7:bencode6:decode10:bittorrenti29ee">>)).

decode_error_extra_test() ->
    ?assertEqual({error, extra_data}, bencode:decode(<<"li1eei3e">>)),
    ?assertEqual({error, extra_data}, bencode:decode(<<"d7:bencodei43ee10:bittorrent">>)).

decode_error_invalid_test() ->
    ?assertEqual({error, invalid_data}, bencode:decode(<<"abcde">>)),
    ?assertEqual({error, invalid_data}, bencode:decode(<<"l4:abcdi3e">>)). % missing "e" terminator for list.

encode_int_test() ->
    ?assertEqual(<<"i-3e">>, bencode:encode(-3)),
    ?assertEqual(<<"i53e">>, bencode:encode(53)),
    ?assertEqual(<<"i0e">>, bencode:encode(0)).

encode_string_test() ->
    ?assertEqual(<<"7:bencode">>, bencode:encode("bencode")),
    ?assertEqual(<<"10:bittorrent">>, bencode:encode(<<"bittorrent">>)).

encode_map_test() ->
    ?assertEqual(<<"d7:bencodei43e6:decode3:abce">>, bencode:encode(#{"bencode" => 43, "decode" => "abc"})).

encode_list_test() ->
    ?assertEqual(<<"li1ei2ei3e7:bencodee">>, bencode:encode([1, 2, 3, <<"bencode">>])).
