(* Reactive sources that accept change listeners *)

con t :: Type -> Type

val create : a ::: Type -> a -> transaction (t a)

val onChange : a ::: Type -> t a -> (a -> transaction {}) -> transaction {}

val set : a ::: Type -> t a -> a -> transaction {}
val get : a ::: Type -> t a -> transaction a
val value : a ::: Type -> t a -> signal a
