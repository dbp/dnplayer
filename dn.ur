(* Note: Date is the date string used in the urls, as the most
   convenient serialization, Offset is seconds into the show *)
table u : {Token : string, Date : string, Offset : float} PRIMARY KEY Token
cookie c : {Token : string}
           
val date_format = "%Y-%m%d"

(* this is awful kludgy, but the alternative is to write a date library,
   which I'm not ready to do yet *)
fun before_nine t =
    let val hr = timef "%H" t in
        case hr of
            "01" => True
          | "02" => True
          | "03" => True
          | "04" => True
          | "05" => True
          | "06" => True
          | "07" => True
          | "08" => True
          | _    => False 
    end
    
fun recent_show t =
   let val seconds_day = 24*60*60 in
   let val nt = (if before_nine t then (addSeconds t (-seconds_day)) else t) in
   let val wd = timef "%u" nt in
   case wd of
       "6" => addSeconds nt (-seconds_day)
     | "7" => addSeconds nt (-(2*seconds_day))
     | _ => nt
   end
   end
   end

fun est_now () =
    n <- now;
    return (addSeconds n (-(4*60*60)))
   
(* like above; linking to cmath would be better, but since I only
   need an approximation, this is fine *)
fun log26_approx n c : int =
    if c < 26 then n else
    log26_approx (n+1) (c / 26)


(* Handlers for creating and persisting token *)
fun new_token () : transaction string =
    count <- oneRowE1 (SELECT COUNT( * ) FROM u);
    token <- Random.lower_str (6 + (log26_approx 0 count));
    used <- hasRows (SELECT * FROM u WHERE (u.Token = {[token]}));
    if used then new_token () else return token

fun set_token token =
    setCookie c {Value = {Token = token},
                 Expires = None,
                 Secure = False}
    
fun clear_token () =
    clearCookie c


(* html fragments *)
fun heading () = 
    <xml>
        <meta name="viewport" content="width=device-width"/>
        <link rel="stylesheet" typ="text/css" href="http://dbpmail.net/css/default.css"/>
        <link rel="stylesheet" typ="text/css" href="http://lab.dbpmail.net/dn/main.css"/>
    </xml>

fun about () =
    <xml>
      <p>
      This is a player for the news program
      <a href="http://democracynow.org">Democracy Now!</a>
      that remembers how much you have watched.
    </p>
    </xml>
    
fun footer () =
    <xml>
      <p>Created by <a href="http://dbpmail.net">Daniel Patterson</a>.
        <br/>
        View the <a href="http://hub.darcs.net/dbp/dnplayer">Source</a>.</p>
    </xml>

(********************
 * Web Code Follows *
 ********************)

(* Welcome! *)
fun main () =
    mc <- getCookie c;
    case mc of
        Some cv => redirect (url (player cv.Token))
      | None => 
        return (<xml>
          <head>
            {heading ()}
          </head>
          <body>
            <h2><a href="http://democracynow.org">Democracy Now!</a> Player</h2>
            {about ()}
            <p>
              You can listen to headlines on your way to work on your phone,
              pick up the first segment during lunch on your computer at work, and
              finish the show in the evening, without worrying what device you are
              on or whether you have time to watch the whole thing.
            </p>
            <h3>How it works</h3>
            <ol>
              <li>
                <form>
                  To start, if you've not created a player on any device:
                  <submit action={create_player} value="Create Player"/>
                </form>
              </li>
              <li>Otherwise, visit the url for the player you created (it should look like
                something <code>http://.../player/hcegaoe</code>) on this device
                to synchronize your devices. You only need to do this once per device, after than
                just visit the home page and we'll load your player.
              </li>
            </ol>

            <h3>Compatibility</h3>
            <p>This currently works with Chrome (on computers and Android) and iPhones/iPads.</p>  
            {footer ()}
          </body>
        </xml>)

(* Create a new player for a user, then send them to it *)
and create_player () =
    n <- est_now ();
    token <- new_token ();
    dml (INSERT INTO u (Token, Date, Offset)
         VALUES ({[token]}, {[timef date_format (recent_show n)]}, 0.0));
    set_token token;
    redirect (url (player token))
    

(* The player handler, deciding what show to render, etc *)
and player token =
    n <- est_now ();
    op <- oneOrNoRows1 (SELECT * FROM u WHERE (u.Token = {[token]}));
    case op of
        None =>
        clear_token ();
        redirect (url (main ()))
      | Some pi =>
        set_token token;
        let val show = recent_show n in
        let val fmtted_date = (timef date_format show) in
            (if fmtted_date <> pi.Date then
                (* Need to switch to new day *)
                dml (UPDATE u SET Date = {[fmtted_date]}, Offset = 0.0 WHERE Token = {[token]})
            else
                return ());
            render token show fmtted_date (if fmtted_date = pi.Date then pi.Offset else 0.0)
        end
        end

(* The player UI *)
and render token date fmtted_date offset =
    os <- SourceL.create offset;
    player_id <- fresh;
    let val video_url = bless (strcat "http://dncdn.dvlabs.com/ipod/dn"
                                      (strcat fmtted_date ".mp4")) in
    let val audio_url = bless (strcat "http://traffic.libsyn.com/democracynow/dn"
                                      (strcat fmtted_date "-1.mp3")) in
        return <xml>
          <head>
            {heading ()}
          </head>
          <body onload={init token player_id os (SourceL.set os) video_url audio_url}>
            <h2><a href="http://democracynow.org">Democracy Now!</a> Player</h2>
            {about ()}
            <h3>{[timef "%A, %B %e, %Y" date]}</h3>
            <div id={player_id}>
              <h3>This player won't work without Javascript; Sorry!</h3>
            </div>
            <br/><br/><br/>
            <form>
              <submit action={start_over token} value="Start Show Over"/>
            </form>
            <form>
              <submit action={forget} value="Forget This Device"/>
            </form>
            {footer ()}
        </body></xml>
    end
    end

(* Drop the cookie, so that client will not auto-redirect to player *)
and forget () =
    clear_token ();
    redirect (url (main ()))

(* Because of browser quirks, this is the only way to get to an earlier time, synchronized *)
and start_over token () =
    dml (UPDATE u SET Offset = 0.0 WHERE Token = {[token]});
    redirect (url (player token))

(* Set up everything on the client side, and call into FFI JS code *)
and init token player_id os set_offset video_url audio_url =
    SourceL.onChange os (fn offset => rpc (update token offset));
    offset <- SourceL.get os;
    onConnectFail (return ());
    Dnjs.init player_id offset set_offset video_url audio_url

(* On rpc from client, update the offset, provided we are increasing the offset *)
and update token offset =
    dml (UPDATE u SET Offset = {[offset]} WHERE Token = {[token]} AND {[offset]} > Offset)

