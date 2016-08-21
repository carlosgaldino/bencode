-module(bencode).

%% API exports
-export([decode/1, encode/1]).

%%====================================================================
%% API functions
%%====================================================================
decode(Data) ->
    try dec(Data) of
        {Out, <<>>} ->
            {ok, Out};
        {_, <<_/binary>>} ->
            {error, extra_data}
    catch
        _Error:_Reason ->
            {error, invalid_data}
    end.

encode(Data) ->
    iolist_to_binary(enc(Data)).

%%====================================================================
%% Internal functions
%%====================================================================
dec(<<$i, Rest/binary>>) ->
    decode_int(Rest, []);
dec(<<$l, Rest/binary>>) ->
    decode_list(Rest, []);
dec(<<$d, Rest/binary>>) ->
    decode_map(Rest, #{});
dec(String) ->
    decode_str(String, []).

decode_int(<<$e, Rest/binary>>, Acc) ->
    {list_to_integer(lists:reverse(Acc)), Rest};
decode_int(<<X, Rest/binary>>, Acc) ->
    decode_int(Rest, [X|Acc]).

decode_list(<<$e, Rest/binary>>, Acc) ->
    {lists:reverse(Acc), Rest};
decode_list(Data, Acc) ->
    {Res, Tail} = dec(Data),
    decode_list(Tail, [Res|Acc]).

decode_map(<<$e, Rest/binary>>, Acc) ->
    {Acc, Rest};
decode_map(Data, Acc) ->
    {Key, Tail} = dec(Data),
    {Value, Tail2} = dec(Tail),
    decode_map(Tail2, Acc#{Key => Value}).

decode_str(<<$:, Rest/binary>>, Acc) ->
    Len = list_to_integer(lists:reverse(Acc)),
    <<Str:Len/binary, Tail/binary>> = Rest,
    {Str, Tail};
decode_str(<<Len, Rest/binary>>, Acc) ->
    decode_str(Rest, [Len|Acc]).

enc(Int) when is_integer(Int) ->
    [$i, integer_to_list(Int), $e];
enc(Map) when is_map(Map) ->
    [$d, transform(Map), $e];
enc(BitString) when is_bitstring(BitString) ->
    [integer_to_list(byte_size(BitString)), $:, BitString];
enc(Data) ->
    case io_lib:printable_list(Data) of
        true -> enc_str(Data);
        false -> enc_list(Data)
    end.

enc_str(String) ->
    [integer_to_list(length(String)), $:, String].

enc_list(List) ->
    [$l, lists:map(fun(X) -> enc(X) end, List), $e].

transform(Map) ->
    MList = lists:keysort(1, maps:to_list(Map)),
    [[encode(K), encode(V)] || {K, V} <- MList].
