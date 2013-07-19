con t a = {Source : source a,
           OnSet : source (a -> transaction {})}

fun create [a] (i : a) =
    s <- source i;
    f <- source (fn _ => return ());

    return {Source = s,
            OnSet = f}

fun onChange [a] (t : t a) f =
    old <- get t.OnSet;
    set t.OnSet (fn x => (old x; f x))

fun set [a] (t : t a) (v : a) =
    Basis.set t.Source v;
    f <- get t.OnSet;
    f v

fun get [a] (t : t a) = Basis.get t.Source

fun value [a] (t : t a) = signal t.Source
