type error = Mirage_kv.error
val pp_error : error Fmt.t

type write_error = [ Mirage_kv.write_error | `Rename_source_prefix | `Rename_source_is_root ]
val pp_write_error : write_error Fmt.t

module Pure : sig
  type t
  type key = Mirage_kv.Key.t
  val empty : Ptime.t -> unit -> t
  val get : t -> key -> (string, error) result
  val size : t -> key -> (int, error) result
  val get_partial : t -> key -> offset:int -> length:int -> (string, error) result
  val last_modified : t -> key -> (Ptime.t, error) result
  val remove : t -> key -> Ptime.t -> (t, write_error) result
  val list : t -> key -> ((string * [`Value | `Dictionary]) list, error) result

  val set : t -> key -> Ptime.t -> string -> (t, write_error) result
  val set_partial : t -> key -> Ptime.t -> offset:int -> string -> (t, write_error) result
  val rename : t -> source:key -> dest:key -> Ptime.t -> (t, write_error) result

  val equal : t -> t -> bool
  val pp : t Fmt.t
end

module Make (Clock : Mirage_clock.PCLOCK) : sig
  type nonrec error = error
  type nonrec write_error = write_error

  include Mirage_kv.RW
    with type write_error := write_error
     and type error := error

  val connect : unit -> t Lwt.t
  val pp : t Fmt.t
  val equal : t -> t -> bool
end
