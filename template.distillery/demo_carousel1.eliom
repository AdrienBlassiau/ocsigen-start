(* This file was generated by Ocsigen Start.
   Feel free to use it, modify it, and redistribute it as you wish. *)

(* Carousel demo *)

[%%shared
  open Eliom_content.Html.F
]

(* Service for this demo *)
let%server service =
  Eliom_service.create
    ~path:(Eliom_service.Path ["demo-carousel1"])
    ~meth:(Eliom_service.Get Eliom_parameter.unit)
    ()

(* Make service available on the client *)
let%client service = ~%service

(* Name for demo menu *)
let%shared name () = [%i18n S.demo_carousel_1]

(* Class for the page containing this demo (for internal use) *)
let%shared page_class = "os-page-demo-carousel1"

(* Page for this demo *)
let%shared page () =
  let make_page name =
    div ~a:[a_class ["demo-carousel1-page" ;
                     "demo-carousel1-page-"^name]] [pcdata "Page " ;
                                                    pcdata name]
  in
  let carousel_change_signal =
    [%client (React.E.create () :
                ([ `Goto of int | `Next | `Prev ] as 'a) React.E.t
                * (?step:React.step -> 'a -> unit)) ]
  in
  let update = [%client fst ~%carousel_change_signal] in
  let change = [%client fun a -> (snd ~%carousel_change_signal ?step:None a) ]
  in
  let carousel_pages = ["1"; "2"; "3"; "4"] in
  let length = List.length carousel_pages in
  let carousel_content = List.map make_page carousel_pages in
  let {Ot_carousel.elt = carousel; pos; vis_elts = size} =
    Ot_carousel.make ~update carousel_content
  in
  let bullets = Ot_carousel.bullets ~change ~pos ~length ~size () in
  let prev = Ot_carousel.previous ~change ~pos [] in
  let next = Ot_carousel.next ~change ~pos ~size ~length [] in
  Lwt.return
    [ h1 [%i18n demo_carousel_1]
    ; p [%i18n ot_carousel_first_example_1]
    ; p [%i18n ot_carousel_first_example_2]
    ; p [%i18n ot_carousel_first_example_3]
    ; p [%i18n ot_carousel_first_example_4]
    ; div ~a:[a_class ["demo-carousel1"]]
        [ div ~a:[a_class ["demo-carousel1-box"]]
            [ carousel ; prev ; next ; bullets ] ]
    ]
