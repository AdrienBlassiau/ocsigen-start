(* This file was generated by Ocsigen Start.
   Feel free to use it, modify it, and redistribute it as you wish. *)

(** Demo for shared reactive content *)

(* Service for this demo *)
let%server service =
  Eliom_service.create
    ~path:(Eliom_service.Path ["demo-react"])
    ~meth:(Eliom_service.Get Eliom_parameter.unit)
    ()

(* Make service available on the client *)
let%client service = ~%service

(* Name for demo menu *)
let%shared name = "Reactive programming"

(* Class for the page containing this demo (for internal use) *)
let%shared page_class = "os-page-demo-react"

(* Make a text input field that calls [f s] for each [s] submitted *)
let%shared make_form msg f =
  let inp = Eliom_content.Html.D.Raw.input ()
  and btn = Eliom_content.Html.(
    D.button ~a:[D.a_class ["button"]] [D.pcdata msg]
  ) in
  ignore [%client
    ((Lwt.async @@ fun () ->
      let btn = Eliom_content.Html.To_dom.of_element ~%btn
      and inp = Eliom_content.Html.To_dom.of_input ~%inp in
      Lwt_js_events.clicks btn @@ fun _ _ ->
      let v = Js.to_string inp##.value in
      let%lwt () = ~%f v in
      inp##.value := Js.string "";
      Lwt.return ())
     : unit)
  ];
  Eliom_content.Html.D.div [inp; btn]

(* Page for this demo *)
let%shared page () =
  (* Client reactive list, initially empty.
     It can be defined either from client or server side,
     (depending on whether this code is executed client or server-side).
     Use Eliom_shared.ReactiveData.RList for lists or
     Eliom_shared.React.S for other data types.
  *)
  let l, h = Eliom_shared.ReactiveData.RList.create [] in
  let inp =
    (* Form that performs a cons (client-side). *)
    make_form "add"
      [%client
        ((fun v -> Lwt.return (Eliom_shared.ReactiveData.RList.cons v ~%h))
         : string -> unit Lwt.t)
      ]
  and l =
    (* Produce <li> items from l contents.
       The shared function will first be called once server or client-side
       to compute the initial page. It will then be called client-side
       every time the reactive list changes to update the
       page automatically. *)
    Eliom_shared.ReactiveData.RList.map
      [%shared
        ((fun s -> Eliom_content.Html.(
           D.li [D.pcdata s]
         )) : _ -> _)
      ]
      l
  in
  Lwt.return Eliom_content.Html.[
    F.p [ F.pcdata "This is an example of page with reactive content."]
  ; F.p [ F.pcdata "It defines a (client-side) reactive list. \
                    You can add elements in this list via the input form. \
                    The page is updated automatically \
                    when the value of the reactive list changes."]
  ; F.p [ F.pcdata "The reactive page is generated either server-side \
                    (for example when you are using a Web browser \
                    and you reload this page) \
                    or client-side (on mobile app or if you already were \
                    in this app before coming to this page)."]
  ; inp
  ; F.div [R.ul l]
  ]