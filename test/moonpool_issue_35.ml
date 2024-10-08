(* https://github.com/c-cube/moonpool/issues/35 *)

open Picos_std_finally

let () =
  Printexc.record_backtrace true;
  Picos_io_select.configure ()

let main _ =
  let@ null =
    finally Moonpool_io.Unix.close @@ fun () ->
    Moonpool_io.Unix.openfile "/dev/null" [ O_RDWR; O_CLOEXEC ] 0
  in
  let rec loop () =
    Printf.printf "Read...\n%!";
    let buf = Bytes.create 1024 in
    match Moonpool_io.Unix.read null buf 0 (Bytes.length buf) with
    | 0 -> Printf.printf "Got 0\n%!"
    | read_n ->
        Printf.printf "Got %d\n%!" read_n;
        ignore (Moonpool_io.Unix.write null buf 0 read_n : int);
        loop ()
  in
  loop ()

let () =
  Moonpool_fib.main main;
  Printf.printf "OK\n%!"
