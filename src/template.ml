open Printf
open Cow
open Lwt

let bar cur =
  let bars = [
    "/","Home";
    "/blog/","Blog";
    "/wiki/","Wiki"; 
    "http://github.com/avsm/mirage", "Code";
    "/about/","About"
  ] in
  let one (href, title) =
    if title=cur then
      <:xml<
        <li><a class="current_page" href=$str:href$>$str:title$</a></li>
      >>
    else
      <:xml<
        <li><a href=$str:href$>$str:title$</a></li>
      >> in
  <:xml< <ul>$list:List.map one bars$</ul> >>

let t ?extra_header page title content =
  lwt tmpl = OS.Devices.find_kv_ro "templates" >>=
    function
    | None -> fail (Failure "no template device")
    | Some x -> return x in
  lwt content = content in
  match_lwt tmpl#read "/main.html" with
    | Some main_html ->
      let templates = [
        "TITLE"       , <:xml<$str:title$>>;
        "BAR"         , <:xml<$bar page$>>;
        "EXTRA_HEADER", <:xml<$opt:extra_header$>>;
        "CONTENT"     , <:xml<$content$>>;
      ] in
      Util.string_of_stream main_html >|= Html.of_string ~templates
    | None ->
      Printf.eprintf "[ERROR] Cannot find tmp/main.html\n";
      assert false

