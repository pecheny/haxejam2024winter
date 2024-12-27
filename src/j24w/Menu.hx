package j24w;

import al.layouts.PortionLayout;
import Main.Lifecycle;
import fancy.domkit.Dkit.BaseDkit;

class Menu extends BaseDkit {
 @:once var l:Lifecycle;
 static var SRC = <menu vl={PortionLayout.instance}>
    <button(b().v(sfr, 0.1).b()) text={"new game"} onClick={()->l.newGame()} />
    <button(b().v(sfr, 0.1).b()) text={"continue"} onClick={()->l.resume()} />
 </menu> 
}