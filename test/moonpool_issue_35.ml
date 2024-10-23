(* https://github.com/c-cube/moonpool/issues/35 *)

open Picos_std_finally

let () =
  Printexc.record_backtrace true;
  Picos_io_select.configure ()

let main _ =
  let@ zero =
    finally Moonpool_io.Unix.close @@ fun () ->
    Moonpool_io.Unix.openfile "/dev/zero" [ O_RDONLY; O_CLOEXEC ] 0
  in
  let@ null =
    finally Moonpool_io.Unix.close @@ fun () ->
    Moonpool_io.Unix.openfile "/dev/null" [ O_WRONLY; O_CLOEXEC ] 0
  in
  let buf = Bytes.create 1024 in
  let rec loop remaining =
    match
      Moonpool_io.Unix.read zero buf 0 (min (Bytes.length buf) remaining)
    with
    | 0 -> ()
    | read_n ->
        ignore (Moonpool_io.Unix.write null buf 0 read_n : int);
        loop (remaining - read_n)
  in
  loop (1024 * 1024)

let () =
  Printf.printf "Start\n%!";
  Moonpool_fib.main main;
  Printf.printf "End\n%!"
